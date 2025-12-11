import 'dart:ffi';
import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// Windows 库加载器
class WindowsVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    // TODO: 当预编译库可用时，实现此逻辑
    // 回退到系统库
    return DynamicLibrary.open('libvips-42.dll');
  }

  @override
  bool isAvailable() {
    if (!Platform.isWindows) return false;
    try {
      load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// 初始化 libvips (Windows)
void initVipsWindows([String appName = 'libvips_ffi']) {
  initVipsWithLoader(WindowsVipsLoader(), appName);
}
