# libvips_ffi

This is the English README for the libvips_ffi package.
中文文档请参见：
[README_CN.md](https://github.com/CaiJingLong/libvips_ffi/blob/main/libvips_ffi/README_CN.md)

Flutter FFI bindings for [libvips](https://www.libvips.org/) - a fast image processing library.

## Version

Version format: `<plugin_version>+<libvips_version>`

- Plugin version follows [Semantic Versioning](https://semver.org/)
- Build metadata (e.g., `+8.16.0`) indicates the bundled libvips version

Example: `0.0.1+8.16.0` means plugin version 0.0.1 with libvips 8.16.0

## Features

- High-performance image processing using libvips
- Cross-platform support:
  - Android: arm64-v8a, armeabi-v7a, x86_64 (16KB aligned for Android 15+)
  - iOS: arm64 device & simulator (iOS 12.0+, Apple Silicon Mac simulator only)
- Simple, Dart-friendly API
- Auto-generated FFI bindings using ffigen
- Platform-specific library loading handled automatically
- Async API using Dart Isolates to avoid UI blocking

## Library Size

| Platform | Download Size |
|----------|---------------|
| Android (arm64-v8a) | ~3.20 MB |
| iOS (arm64) | ~7.48 MB |

For detailed size breakdown by architecture, see:
[Native Library Sizes](https://github.com/CaiJingLong/libvips_ffi/blob/main/docs/NATIVE_LIBRARY_SIZES.md)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  libvips_ffi:
    git:
      url: https://github.com/CaiJingLong/libvips_ffi
      path: libvips_ffi
```

## Quick Start

### Basic Usage (Sync API)

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

void main() {
  // Initialize libvips (called automatically on first use)
  initVips();

  // Check version
  print('libvips version: $vipsVersionString');

  // Load an image
  final image = VipsImageWrapper.fromFile('/path/to/image.jpg');
  print('Size: ${image.width}x${image.height}');

  // Process image
  final resized = image.resize(0.5);  // 50% size
  final blurred = resized.gaussianBlur(3.0);

  // Save result
  blurred.writeToFile('/path/to/output.jpg');

  // Always dispose when done (in reverse order)
  blurred.dispose();
  resized.dispose();
  image.dispose();

  shutdownVips();
}
```

### Flutter Usage (Async API - Recommended)

**Important:** Use the async API in Flutter to avoid blocking the UI thread.

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

// Simple one-off operations using VipsCompute
Future<void> processImage() async {
  // Resize image (runs in isolate, doesn't block UI)
  final result = await VipsCompute.resizeFile('input.jpg', 0.5);
  
  // result.data contains the processed image bytes
  // result.width, result.height contain dimensions
  
  // Display in Flutter
  Image.memory(result.data);
}

// More operations
Future<void> moreExamples() async {
  // Thumbnail (most efficient for previews)
  final thumb = await VipsCompute.thumbnailFile('input.jpg', 200);
  
  // Rotate
  final rotated = await VipsCompute.rotateFile('input.jpg', 90);
  
  // Blur
  final blurred = await VipsCompute.blurFile('input.jpg', 5.0);
  
  // Custom operation chain
  final custom = await VipsCompute.processFile('input.jpg', (img) {
    final step1 = img.resize(0.5);
    final step2 = step1.gaussianBlur(2.0);
    step1.dispose();  // Clean up intermediate
    return step2;
  });
}
```

### Common Operations

```dart
// Resize by scale factor
final resized = image.resize(0.5);  // 50% of original

// Create thumbnail (maintains aspect ratio)
final thumb = image.thumbnail(200);  // 200px width

// Rotate by angle
final rotated = image.rotate(90);  // 90 degrees

// Crop region
final cropped = image.crop(100, 100, 200, 200);  // left, top, width, height

// Flip
final flippedH = image.flip(VipsDirection.horizontal);
final flippedV = image.flip(VipsDirection.vertical);

// Blur
final blurred = image.gaussianBlur(5.0);  // sigma value

// Sharpen
final sharpened = image.sharpen();

// Adjust brightness (1.0 = no change, >1 = brighter)
final brighter = image.brightness(1.3);

// Adjust contrast
final highContrast = image.contrast(1.5);

// Convert to grayscale
final gray = image.colourspace(VipsInterpretation.bw);

// Smart crop (focus on interesting area)
final smartCropped = image.smartCrop(300, 300);

// Auto-rotate based on EXIF
final autoRotated = image.autoRotate();
```

### Memory Management

```dart
// Always dispose images when done
final image = VipsImageWrapper.fromFile('input.jpg');
try {
  final result = image.resize(0.5);
  try {
    result.writeToFile('output.jpg');
  } finally {
    result.dispose();
  }
} finally {
  image.dispose();
}

// Check for memory leaks (development only)
if (VipsPointerManager.instance.hasLeaks) {
  print(VipsPointerManager.instance.getLeakReport());
}
```

## Advanced Usage

For advanced users who need direct access to libvips functions:

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

// Access raw bindings
final bindings = VipsBindings(vipsLibrary);

// Call any libvips function directly
// bindings.vips_thumbnail(...);
```

## Regenerating Bindings

If you need to regenerate the FFI bindings:

```bash
dart run ffigen --config ffigen.yaml
```

## Native binaries locations (Android / iOS)

For transparency, the original build / prebuilt locations of the native libraries are listed below.
These precompiled binaries are built and published via GitHub Actions in the linked repositories above.

Upstream build repository links:
- Android: [MobiPkg/Compile build run](https://github.com/MobiPkg/Compile/actions/runs/20085520935)
- iOS: [libvips_precompile_mobile build run](https://github.com/CaiJingLong/libvips_precompile_mobile/actions/runs/19779932583)

- **Android**  
  The original Android build artifacts and related build configuration are located under:  
  `libvips_ffi/android/`  
  This includes the Gradle configuration and sources used to produce the Android native libraries.

- **iOS**  
  The precompiled iOS frameworks and related configuration are located under:  
  `libvips_ffi/ios/Frameworks/`  
  along with the CocoaPods specification file:  
  `libvips_ffi/ios/libvips_ffi.podspec`  
  These are the prebuilt binaries and metadata used for iOS integration.

## Disclaimer

**This project is provided "as is" without warranty of any kind.** The maintainer does not guarantee any maintenance schedule, bug fixes, or feature updates. Use at your own risk.

- No guaranteed response time for issues or pull requests
- No guaranteed compatibility with future Flutter/Dart versions
- No guaranteed security updates for bundled native libraries

Please evaluate the risks before using this library in production environments.

## License

The main code in this project is provided under the Apache License 2.0.
Parts of the codebase are derived from upstream projects and continue to be governed by their original licenses.
Please refer to the corresponding upstream source files and bundled license texts for the exact terms that apply to those components.
