/// Flutter FFI bindings for libvips image processing library.
///
/// This library provides Dart bindings for the libvips image processing
/// library, allowing you to perform high-performance image operations
/// in Flutter applications.
///
/// ## Getting Started
///
/// First, initialize the library:
///
/// ```dart
/// import 'package:libvips_ffi/libvips_ffi.dart';
///
/// void main() {
///   initVips();
///   // Your code here
///   shutdownVips();
/// }
/// ```
library libvips_ffi;

export 'src/vips_image.dart'
    show
        VipsImageWrapper,
        VipsException,
        VipsDirection,
        VipsInterpretation,
        initVips,
        shutdownVips,
        getVipsError,
        clearVipsError,
        vipsVersion,
        vipsVersionString;

// Export async API for running operations in isolate
export 'src/vips_isolate.dart' show VipsImageAsync, VipsImageData;

// Export compute-based async API (simpler, uses Flutter's compute)
export 'src/vips_compute.dart' show VipsCompute, VipsComputeResult;

// Export raw bindings for advanced users
export 'src/bindings/vips_bindings_generated.dart' show VipsBindings;
export 'src/vips_library.dart' show vipsLibrary, loadVipsLibrary;
