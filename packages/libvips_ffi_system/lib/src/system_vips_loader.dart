import 'dart:ffi';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

import 'system_library_finder.dart';

/// 系统包管理器库加载器
///
/// 自动检测系统包管理器安装的 libvips 库。
/// 支持：
/// - macOS: Homebrew, MacPorts
/// - Linux: apt, dnf, pacman
/// - Windows: vcpkg, Chocolatey
class SystemPackageVipsLoader implements VipsLibraryLoader {
  String? _cachedPath;

  @override
  DynamicLibrary load() {
    if (_cachedPath != null) {
      return DynamicLibrary.open(_cachedPath!);
    }

    // 同步查找 - 使用 SystemVipsLoader 的逻辑作为回退
    return SystemVipsLoader().load();
  }

  @override
  bool isAvailable() {
    try {
      load();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 异步加载 - 推荐使用
  ///
  /// 会检测系统包管理器并找到正确的库路径。
  Future<DynamicLibrary> loadAsync() async {
    final path = await SystemLibraryFinder.findLibraryPath();
    if (path != null) {
      _cachedPath = path;
      return DynamicLibrary.open(path);
    }

    // 回退到系统默认路径
    return SystemVipsLoader().load();
  }

  /// 获取检测到的包管理器信息
  Future<List<PackageManagerInfo>> getPackageManagers() {
    return SystemLibraryFinder.findPackageManagers();
  }

  /// 获取安装建议
  Future<String> getInstallSuggestion() {
    return SystemLibraryFinder.getInstallSuggestion();
  }
}

/// 异步初始化 libvips (使用系统包管理器)
///
/// 自动检测系统包管理器安装的 libvips。
/// 如果未找到，会抛出异常并提供安装建议。
Future<void> initVipsSystemAsync([String appName = 'libvips_ffi']) async {
  final loader = SystemPackageVipsLoader();
  final library = await loader.loadAsync();
  initVipsWithLibrary(library, appName);
}

/// 检查系统是否已安装 libvips
///
/// 返回检测到的包管理器信息列表。
Future<List<PackageManagerInfo>> checkVipsInstallation() {
  return SystemLibraryFinder.findPackageManagers();
}

/// 获取 libvips 安装建议
Future<String> getVipsInstallSuggestion() {
  return SystemLibraryFinder.getInstallSuggestion();
}
