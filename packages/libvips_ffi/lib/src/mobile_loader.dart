import 'dart:ffi';
import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// 移动端库加载器
class MobileVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libvips.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    throw UnsupportedError(
      'MobileVipsLoader only supports Android and iOS. '
      'Use desktop packages for ${Platform.operatingSystem}.',
    );
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
}

/// 初始化 libvips (移动端便捷方法)
/// 保持与旧 API 兼容
void initVips([String appName = 'libvips_ffi']) {
  initVipsWithLoader(MobileVipsLoader(), appName);
}
