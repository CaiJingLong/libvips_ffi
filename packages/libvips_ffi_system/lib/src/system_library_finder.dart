import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// 系统包管理器信息
class PackageManagerInfo {
  /// 包管理器名称
  final String name;

  /// 包管理器命令
  final String command;

  /// 安装 libvips 的命令
  final String installCommand;

  /// 库文件路径列表
  final List<String> libraryPaths;

  /// 是否已安装
  final bool isInstalled;

  /// libvips 版本 (如果已安装)
  final String? vipsVersion;

  PackageManagerInfo({
    required this.name,
    required this.command,
    required this.installCommand,
    required this.libraryPaths,
    required this.isInstalled,
    this.vipsVersion,
  });

  @override
  String toString() {
    return 'PackageManagerInfo('
        'name: $name, '
        'installed: $isInstalled, '
        'version: $vipsVersion, '
        'paths: $libraryPaths)';
  }
}

/// 系统库查找器
///
/// 根据系统包管理器查找 libvips 库。
class SystemLibraryFinder {
  /// 查找所有可用的包管理器
  static Future<List<PackageManagerInfo>> findPackageManagers() async {
    final platform = VipsPlatform.current;

    switch (platform) {
      case VipsPlatform.macos:
        return _findMacosPackageManagers();
      case VipsPlatform.linux:
        return _findLinuxPackageManagers();
      case VipsPlatform.windows:
        return _findWindowsPackageManagers();
      default:
        return [];
    }
  }

  /// 查找 libvips 库路径
  ///
  /// 返回找到的第一个有效库路径，如果未找到返回 null。
  static Future<String?> findLibraryPath() async {
    final managers = await findPackageManagers();

    for (final manager in managers) {
      if (manager.isInstalled) {
        for (final path in manager.libraryPaths) {
          if (File(path).existsSync()) {
            return path;
          }
        }
      }
    }

    return null;
  }

  /// 获取安装建议
  static Future<String> getInstallSuggestion() async {
    final platform = VipsPlatform.current;

    switch (platform) {
      case VipsPlatform.macos:
        return 'Install via Homebrew: brew install vips\n'
            'Or via MacPorts: sudo port install vips';
      case VipsPlatform.linux:
        return 'Install via apt: sudo apt install libvips-dev\n'
            'Or via dnf: sudo dnf install vips-devel\n'
            'Or via pacman: sudo pacman -S libvips';
      case VipsPlatform.windows:
        return 'Install via vcpkg: vcpkg install libvips\n'
            'Or via Chocolatey: choco install libvips\n'
            'Or download from: https://github.com/libvips/build-win64-mxe/releases';
      default:
        return 'Please install libvips for your platform.';
    }
  }

  // ============ macOS ============

  static Future<List<PackageManagerInfo>> _findMacosPackageManagers() async {
    final managers = <PackageManagerInfo>[];

    // Homebrew
    final homebrewInfo = await _checkHomebrew();
    if (homebrewInfo != null) {
      managers.add(homebrewInfo);
    }

    // MacPorts
    final macportsInfo = await _checkMacPorts();
    if (macportsInfo != null) {
      managers.add(macportsInfo);
    }

    return managers;
  }

  static Future<PackageManagerInfo?> _checkHomebrew() async {
    try {
      // 检查 brew 是否存在
      final brewResult = await Process.run('which', ['brew']);
      if (brewResult.exitCode != 0) return null;

      final brewPath = (brewResult.stdout as String).trim();
      if (brewPath.isEmpty) return null;

      // 获取 Homebrew prefix
      final prefixResult = await Process.run('brew', ['--prefix']);
      final prefix = (prefixResult.stdout as String).trim();

      // 检查 vips 是否已安装
      final listResult = await Process.run('brew', ['list', 'vips']);
      final isInstalled = listResult.exitCode == 0;

      String? version;
      if (isInstalled) {
        final versionResult = await Process.run('brew', ['info', 'vips', '--json=v2']);
        if (versionResult.exitCode == 0) {
          // 简单提取版本号
          final output = versionResult.stdout as String;
          final versionMatch = RegExp(r'"version":\s*"([^"]+)"').firstMatch(output);
          version = versionMatch?.group(1);
        }
      }

      // 可能的库路径
      final libraryPaths = [
        '$prefix/lib/libvips.dylib',
        '$prefix/opt/vips/lib/libvips.dylib',
        '/opt/homebrew/lib/libvips.dylib', // Apple Silicon
        '/usr/local/lib/libvips.dylib', // Intel
      ];

      return PackageManagerInfo(
        name: 'Homebrew',
        command: 'brew',
        installCommand: 'brew install vips',
        libraryPaths: libraryPaths,
        isInstalled: isInstalled,
        vipsVersion: version,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<PackageManagerInfo?> _checkMacPorts() async {
    try {
      final portResult = await Process.run('which', ['port']);
      if (portResult.exitCode != 0) return null;

      // 检查 vips 是否已安装
      final listResult = await Process.run('port', ['installed', 'vips']);
      final isInstalled =
          listResult.exitCode == 0 && (listResult.stdout as String).contains('vips');

      return PackageManagerInfo(
        name: 'MacPorts',
        command: 'port',
        installCommand: 'sudo port install vips',
        libraryPaths: ['/opt/local/lib/libvips.dylib'],
        isInstalled: isInstalled,
      );
    } catch (_) {
      return null;
    }
  }

  // ============ Linux ============

  static Future<List<PackageManagerInfo>> _findLinuxPackageManagers() async {
    final managers = <PackageManagerInfo>[];

    // apt (Debian/Ubuntu)
    final aptInfo = await _checkApt();
    if (aptInfo != null) managers.add(aptInfo);

    // dnf (Fedora/RHEL)
    final dnfInfo = await _checkDnf();
    if (dnfInfo != null) managers.add(dnfInfo);

    // pacman (Arch)
    final pacmanInfo = await _checkPacman();
    if (pacmanInfo != null) managers.add(pacmanInfo);

    return managers;
  }

  static Future<PackageManagerInfo?> _checkApt() async {
    try {
      final aptResult = await Process.run('which', ['apt']);
      if (aptResult.exitCode != 0) return null;

      // 检查 libvips 是否已安装
      final dpkgResult = await Process.run('dpkg', ['-l', 'libvips42']);
      final isInstalled = dpkgResult.exitCode == 0;

      return PackageManagerInfo(
        name: 'apt',
        command: 'apt',
        installCommand: 'sudo apt install libvips-dev',
        libraryPaths: [
          '/usr/lib/x86_64-linux-gnu/libvips.so.42',
          '/usr/lib/aarch64-linux-gnu/libvips.so.42',
          '/usr/lib/libvips.so.42',
        ],
        isInstalled: isInstalled,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<PackageManagerInfo?> _checkDnf() async {
    try {
      final dnfResult = await Process.run('which', ['dnf']);
      if (dnfResult.exitCode != 0) return null;

      // 检查 vips 是否已安装
      final rpmResult = await Process.run('rpm', ['-q', 'vips']);
      final isInstalled = rpmResult.exitCode == 0;

      return PackageManagerInfo(
        name: 'dnf',
        command: 'dnf',
        installCommand: 'sudo dnf install vips-devel',
        libraryPaths: [
          '/usr/lib64/libvips.so.42',
          '/usr/lib/libvips.so.42',
        ],
        isInstalled: isInstalled,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<PackageManagerInfo?> _checkPacman() async {
    try {
      final pacmanResult = await Process.run('which', ['pacman']);
      if (pacmanResult.exitCode != 0) return null;

      // 检查 libvips 是否已安装
      final queryResult = await Process.run('pacman', ['-Q', 'libvips']);
      final isInstalled = queryResult.exitCode == 0;

      return PackageManagerInfo(
        name: 'pacman',
        command: 'pacman',
        installCommand: 'sudo pacman -S libvips',
        libraryPaths: ['/usr/lib/libvips.so.42'],
        isInstalled: isInstalled,
      );
    } catch (_) {
      return null;
    }
  }

  // ============ Windows ============

  static Future<List<PackageManagerInfo>> _findWindowsPackageManagers() async {
    final managers = <PackageManagerInfo>[];

    // vcpkg
    final vcpkgInfo = await _checkVcpkg();
    if (vcpkgInfo != null) managers.add(vcpkgInfo);

    // Chocolatey
    final chocoInfo = await _checkChocolatey();
    if (chocoInfo != null) managers.add(chocoInfo);

    return managers;
  }

  static Future<PackageManagerInfo?> _checkVcpkg() async {
    try {
      final vcpkgRoot = Platform.environment['VCPKG_ROOT'];
      if (vcpkgRoot == null || vcpkgRoot.isEmpty) return null;

      final libraryPaths = [
        '$vcpkgRoot/installed/x64-windows/bin/libvips-42.dll',
        '$vcpkgRoot/installed/x64-windows/bin/vips-42.dll',
      ];

      final isInstalled = libraryPaths.any((p) => File(p).existsSync());

      return PackageManagerInfo(
        name: 'vcpkg',
        command: 'vcpkg',
        installCommand: 'vcpkg install libvips:x64-windows',
        libraryPaths: libraryPaths,
        isInstalled: isInstalled,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<PackageManagerInfo?> _checkChocolatey() async {
    try {
      final chocoResult = await Process.run('where', ['choco']);
      if (chocoResult.exitCode != 0) return null;

      // Chocolatey 安装的 libvips 通常在 PATH 中
      final libraryPaths = [
        'C:\\ProgramData\\chocolatey\\lib\\libvips\\tools\\libvips-42.dll',
        'libvips-42.dll', // 在 PATH 中
      ];

      return PackageManagerInfo(
        name: 'Chocolatey',
        command: 'choco',
        installCommand: 'choco install libvips',
        libraryPaths: libraryPaths,
        isInstalled: false, // 需要实际检查
      );
    } catch (_) {
      return null;
    }
  }
}
