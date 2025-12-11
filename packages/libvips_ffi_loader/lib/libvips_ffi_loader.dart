/// Dynamic library loader for libvips_ffi with callback-based download support.
///
/// libvips_ffi 的动态库加载器，支持基于回调的下载。
///
/// This package provides a way to dynamically load libvips at runtime,
/// allowing developers to implement their own download and caching logic.
/// 此包提供了在运行时动态加载 libvips 的方式，
/// 允许开发者实现自己的下载和缓存逻辑。
///
/// ## Usage / 使用方法
///
/// ```dart
/// import 'package:libvips_ffi_loader/libvips_ffi_loader.dart';
///
/// Future<void> main() async {
///   await VipsLoader.init(
///     provider: (request) async {
///       final cacheDir = request.suggestedCacheDir;
///       final libPath = '$cacheDir/${request.libraryFileName}';
///
///       // Check cache
///       if (await File(libPath).exists()) {
///         return libPath;
///       }
///
///       // Download from your CDN
///       final url = 'https://my-cdn.com/libs/'
///           '${request.platformArchIdentifier}/'
///           'libvips.zip';
///       await downloadAndExtract(url, cacheDir);
///
///       return libPath;
///     },
///     onStateChanged: (state) => print('Loading state: $state'),
///   );
///
///   // Now you can use libvips
///   final image = VipsImageWrapper.fromFile('input.jpg');
///   // ...
/// }
/// ```
library libvips_ffi_loader;

// Re-export core package for convenience
export 'package:libvips_ffi_core/libvips_ffi_core.dart';

// Export loader types
export 'src/loader_types.dart'
    show
        VipsLibraryRequest,
        VipsLoadingState,
        VipsLibraryProvider,
        VipsLoadingCallback;

// Export loader
export 'src/vips_loader.dart' show VipsLoader, recommendedVipsVersion;
