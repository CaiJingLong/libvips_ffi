import 'dart:ffi';
import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// macOS 库加载器
///
/// 加载预编译的 macOS libvips 库。
/// 当预编译库不可用时，会回退到系统库。
class MacosVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    // 首先尝试加载预编译库 (通过 Flutter plugin 机制)
    // TODO: 当预编译库可用时，实现此逻辑

    // 回退到系统库
    return SystemVipsLoader().load();
  }

  @override
  bool isAvailable() {
    if (!Platform.isMacOS) return false;
    try {
      load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// 初始化 libvips (macOS)
///
/// 使用预编译库或系统库初始化 libvips。
void initVipsMacos([String appName = 'libvips_ffi']) {
  initVipsWithLoader(MacosVipsLoader(), appName);
}
