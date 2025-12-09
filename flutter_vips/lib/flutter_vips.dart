/// Flutter FFI bindings for libvips image processing library.
///
/// This library provides Dart bindings for libvips, a fast image processing
/// library. It supports loading, manipulating, and saving images in various
/// formats.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:flutter_vips/flutter_vips.dart';
///
/// void main() {
///   // Initialize libvips (called automatically, but can be explicit)
///   initVips();
///
///   // Load an image
///   final image = VipsImageWrapper.fromFile('/path/to/image.jpg');
///
///   // Get image info
///   print('Size: ${image.width}x${image.height}');
///   print('Bands: ${image.bands}');
///
///   // Save to a different format
///   image.writeToFile('/path/to/output.png');
///
///   // Don't forget to dispose
///   image.dispose();
///
///   // Shutdown when done (optional)
///   shutdownVips();
/// }
/// ```
library flutter_vips;

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
