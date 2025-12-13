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

/// 初始化 libvips
///
/// [loader] - 可选的自定义加载器。如果不提供：
///   - 移动端（Android/iOS）使用 MobileVipsLoader
///   - 桌面端使用 SystemVipsLoader
///
/// 如需使用预编译库，请传入平台特定的加载器（如 WindowsVipsLoader）。
void initVips({
  VipsLibraryLoader? loader,
  String appName = 'libvips_ffi',
}) {
  final effectiveLoader = loader ?? _getDefaultLoader();
  initVipsWithLoader(effectiveLoader, appName);
}

VipsLibraryLoader _getDefaultLoader() {
  if (Platform.isAndroid || Platform.isIOS) {
    return MobileVipsLoader();
  } else {
    return SystemVipsLoader();
  }
}
