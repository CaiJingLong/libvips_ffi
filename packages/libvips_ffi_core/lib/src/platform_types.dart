import 'dart:io';

/// 支持的平台
enum VipsPlatform {
  macos('macos', 'dylib'),
  windows('windows', 'dll'),
  linux('linux', 'so'),
  android('android', 'so'),
  ios('ios', '');

  final String name;
  final String libraryExtension;

  const VipsPlatform(this.name, this.libraryExtension);

  /// 获取当前平台
  static VipsPlatform get current {
    if (Platform.isMacOS) return VipsPlatform.macos;
    if (Platform.isWindows) return VipsPlatform.windows;
    if (Platform.isLinux) return VipsPlatform.linux;
    if (Platform.isAndroid) return VipsPlatform.android;
    if (Platform.isIOS) return VipsPlatform.ios;
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  /// 是否为桌面平台
  bool get isDesktop => this == macos || this == windows || this == linux;

  /// 是否为移动平台
  bool get isMobile => this == android || this == ios;
}

/// CPU 架构
enum VipsArch {
  arm64('arm64'),
  x64('x64'),
  arm('arm'),
  x86('x86');

  final String name;

  const VipsArch(this.name);

  /// 获取当前架构
  static VipsArch get current {
    // Dart 目前没有直接获取 CPU 架构的 API
    // 通过 Platform.version 推断
    final version = Platform.version.toLowerCase();
    if (version.contains('arm64') || version.contains('aarch64')) {
      return VipsArch.arm64;
    }
    if (version.contains('arm')) {
      return VipsArch.arm;
    }
    if (version.contains('x64') ||
        version.contains('x86_64') ||
        version.contains('amd64')) {
      return VipsArch.x64;
    }
    return VipsArch.x64; // 默认假设 x64
  }
}
