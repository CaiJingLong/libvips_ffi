import 'dart:ffi';
import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// Linux 库加载器
class LinuxVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    // TODO: 当预编译库可用时，实现此逻辑
    // 回退到系统库
    return DynamicLibrary.open('libvips.so.42');
  }

  @override
  bool isAvailable() {
    if (!Platform.isLinux) return false;
    try {
      load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// 初始化 libvips (Linux)
void initVipsLinux([String appName = 'libvips_ffi']) {
  initVipsWithLoader(LinuxVipsLoader(), appName);
}
