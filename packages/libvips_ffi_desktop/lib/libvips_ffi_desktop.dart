/// Desktop support for libvips_ffi (macOS, Windows, Linux).
///
/// libvips_ffi 桌面端支持（macOS、Windows、Linux）。
///
/// This is a meta package that includes all desktop platform packages.
/// 这是一个元包，包含所有桌面平台包。
///
/// ## Usage / 使用方法
///
/// ```yaml
/// dependencies:
///   libvips_ffi_desktop: ^1.0.0
/// ```
///
/// ```dart
/// import 'package:libvips_ffi_desktop/libvips_ffi_desktop.dart';
///
/// void main() {
///   initVipsDesktop();
///   // Use libvips...
///   shutdownVips();
/// }
/// ```
library libvips_ffi_desktop;

import 'dart:io';

import 'package:libvips_ffi_linux/libvips_ffi_linux.dart';
import 'package:libvips_ffi_macos/libvips_ffi_macos.dart';
import 'package:libvips_ffi_windows/libvips_ffi_windows.dart';

// Re-export core package
export 'package:libvips_ffi_core/libvips_ffi_core.dart';

// Re-export platform packages
export 'package:libvips_ffi_macos/libvips_ffi_macos.dart'
    show MacosVipsLoader, initVipsMacos;
export 'package:libvips_ffi_windows/libvips_ffi_windows.dart'
    show WindowsVipsLoader, initVipsWindows;
export 'package:libvips_ffi_linux/libvips_ffi_linux.dart'
    show LinuxVipsLoader, initVipsLinux;

/// 初始化 libvips (桌面端自动选择平台)
///
/// 根据当前平台自动选择对应的加载器。
void initVipsDesktop([String appName = 'libvips_ffi']) {
  if (Platform.isMacOS) {
    initVipsMacos(appName);
  } else if (Platform.isWindows) {
    initVipsWindows(appName);
  } else if (Platform.isLinux) {
    initVipsLinux(appName);
  } else {
    throw UnsupportedError(
      'libvips_ffi_desktop does not support ${Platform.operatingSystem}. '
      'Use libvips_ffi for mobile platforms.',
    );
  }
}
