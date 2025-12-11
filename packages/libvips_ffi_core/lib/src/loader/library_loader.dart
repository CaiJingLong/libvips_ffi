import 'dart:ffi';
import 'dart:io';

import '../platform_types.dart';

/// 抽象库加载器接口
abstract class VipsLibraryLoader {
  /// 加载 libvips 动态库
  DynamicLibrary load();

  /// 检查库是否可用
  bool isAvailable();
}

/// 系统库加载器 - 从系统路径加载 libvips
class SystemVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    final platform = VipsPlatform.current;

    switch (platform) {
      case VipsPlatform.macos:
        return _loadMacOS();
      case VipsPlatform.linux:
        return DynamicLibrary.open('libvips.so.42');
      case VipsPlatform.windows:
        return DynamicLibrary.open('libvips-42.dll');
      default:
        throw UnsupportedError(
          'SystemVipsLoader does not support ${platform.name}. '
          'Use platform-specific loader for mobile.',
        );
    }
  }

  DynamicLibrary _loadMacOS() {
    final paths = [
      '/opt/homebrew/lib/libvips.dylib', // Apple Silicon Homebrew
      '/usr/local/lib/libvips.dylib', // Intel Homebrew
      '/opt/local/lib/libvips.dylib', // MacPorts
      'libvips.dylib', // 系统路径
    ];

    for (final path in paths) {
      try {
        return DynamicLibrary.open(path);
      } catch (_) {
        continue;
      }
    }

    throw StateError(
      'Could not find libvips on macOS. '
      'Install via: brew install vips',
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

/// 自定义路径加载器
class PathVipsLoader implements VipsLibraryLoader {
  final String libraryPath;

  PathVipsLoader(this.libraryPath);

  @override
  DynamicLibrary load() => DynamicLibrary.open(libraryPath);

  @override
  bool isAvailable() => File(libraryPath).existsSync();
}

/// 直接使用 DynamicLibrary 的加载器
class DirectVipsLoader implements VipsLibraryLoader {
  final DynamicLibrary library;

  DirectVipsLoader(this.library);

  @override
  DynamicLibrary load() => library;

  @override
  bool isAvailable() => true;
}
