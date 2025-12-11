/// Pure Dart FFI bindings for libvips image processing library.
///
/// libvips 图像处理库的纯 Dart FFI 绑定。
///
/// This library provides Dart bindings for the libvips image processing
/// library without any Flutter dependency.
/// 此库为 libvips 图像处理库提供纯 Dart 绑定，无 Flutter 依赖。
///
/// ## Getting Started / 入门
///
/// First, initialize the library:
/// 首先，初始化库：
///
/// ```dart
/// import 'package:libvips_ffi_core/libvips_ffi_core.dart';
///
/// void main() {
///   // Use system libvips (desktop)
///   initVipsSystem();
///
///   // Or use custom path
///   // initVipsWithLoader(PathVipsLoader('/path/to/libvips.dylib'));
///
///   // Your code here / 你的代码
///   shutdownVips();
/// }
/// ```
///
/// ## Synchronous API / 同步 API
///
/// Use [VipsImageWrapper] for synchronous image processing:
/// 使用 [VipsImageWrapper] 进行同步图像处理：
///
/// ```dart
/// final image = VipsImageWrapper.fromFile('input.jpg');
/// final resized = image.resize(0.5);
/// resized.writeToFile('output.jpg');
/// resized.dispose();
/// image.dispose();
/// ```
library libvips_ffi_core;

// Export core image processing API.
// 导出核心图像处理 API。
export 'src/vips_image.dart';

// Export raw bindings for advanced users.
// 为高级用户导出原始绑定。
export 'src/bindings/vips_bindings_generated.dart' show VipsBindings;

// Export library loading utilities.
// 导出库加载工具。
export 'src/vips_core.dart'
    show
        vipsBindings,
        vipsLibrary,
        initVipsSystem,
        initVipsWithLoader,
        initVipsWithLibrary,
        shutdownVips,
        getVipsError,
        clearVipsError,
        vipsVersion,
        vipsVersionString,
        VipsException;

export 'src/loader/library_loader.dart'
    show VipsLibraryLoader, SystemVipsLoader, PathVipsLoader, DirectVipsLoader;

export 'src/platform_types.dart' show VipsPlatform, VipsArch;
