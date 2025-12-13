/// Flutter FFI bindings for libvips image processing library.
///
/// libvips 图像处理库的 Flutter FFI 绑定。
///
/// This library provides Dart bindings for the libvips image processing
/// library, allowing you to perform high-performance image operations
/// in Flutter applications.
/// 此库为 libvips 图像处理库提供 Dart 绑定，允许你在 Flutter 应用程序中
/// 执行高性能图像操作。
///
/// ## Getting Started / 入门
///
/// First, initialize the library:
/// 首先，初始化库：
///
/// ```dart
/// import 'package:libvips_ffi/libvips_ffi.dart';
///
/// void main() {
///   initVips();
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
///
/// ## Asynchronous API / 异步 API
///
/// For async operations that don't block the UI thread, use:
/// 对于不阻塞 UI 线程的异步操作，使用：
///
/// - [VipsCompute] - Simple one-off operations using Flutter's compute.
///   简单的一次性操作，使用 Flutter 的 compute。
/// - [VipsImageAsync] - Persistent isolate for batch processing.
///   用于批量处理的持久 isolate。
///
/// ## Supported Operations / 支持的操作
///
/// - **Resize / 调整大小** - Scale images up or down / 放大或缩小图像
/// - **Thumbnail / 缩略图** - Efficient thumbnail generation / 高效缩略图生成
/// - **Rotate / 旋转** - Rotate by any angle / 按任意角度旋转
/// - **Crop / 裁剪** - Extract regions from images / 从图像提取区域
/// - **Flip / 翻转** - Horizontal or vertical flip / 水平或垂直翻转
/// - **Blur / 模糊** - Gaussian blur / 高斯模糊
/// - **Sharpen / 锐化** - Unsharp masking / 反锐化蒙版
/// - **Colour space / 色彩空间** - Convert between colour spaces / 色彩空间转换
/// - **Brightness/Contrast / 亮度/对比度** - Adjust image levels / 调整图像级别
/// - And more... / 更多...
library libvips_ffi;

// Re-export everything from core package
// 重新导出 core 包的所有内容
export 'package:libvips_ffi_core/libvips_ffi_core.dart';

// Export platform loader and initVips function
// 导出平台加载器和 initVips 函数
export 'src/platform_loader.dart' show PlatformVipsLoader, initVips;

// Export compute-based async API (simpler, uses Flutter's compute).
// 导出基于 compute 的异步 API（更简单，使用 Flutter 的 compute）。
export 'src/vips_compute.dart' show VipsCompute, VipsComputeResult;

// Export isolate-based async API for batch processing.
// 导出基于 isolate 的异步 API，用于批量处理。
export 'src/vips_isolate.dart' show VipsImageAsync, VipsImageData;
