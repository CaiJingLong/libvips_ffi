# libvips_ffi

Flutter FFI bindings for [libvips](https://www.libvips.org/) - a fast image processing library.

## Features

- High-performance image processing using libvips
- Cross-platform support (Android & iOS)
- Simple, Dart-friendly API
- Auto-generated FFI bindings using ffigen
- Platform-specific library loading handled automatically
- Async API using Dart Isolates to avoid UI blocking

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  libvips_ffi:
    git:
      url: https://github.com/CaiJingLong/libvips_ffi
      path: flutter_vips
```

### Platform Setup

#### Android

Place precompiled libvips `.so` files in `android/src/main/jniLibs/`:

```text
android/src/main/jniLibs/
├── arm64-v8a/
│   └── libvips.so
├── armeabi-v7a/
│   └── libvips.so
└── x86_64/
    └── libvips.so
```

Download from: <https://github.com/AiHrt/libvips-android-build/releases>

#### iOS

Place `vips.xcframework` in `ios/Frameworks/`:

```text
ios/Frameworks/
└── vips.xcframework/
```

Download from: <https://github.com/CaiJingLong/libvips_precompile_mobile/releases>

## Usage

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

void main() {
  // Initialize libvips (called automatically on first use)
  initVips();

  // Check version
  print('libvips version: $vipsVersionString');

  // Load an image
  final image = VipsImageWrapper.fromFile('/path/to/image.jpg');

  // Get image info
  print('Size: ${image.width}x${image.height}');
  print('Bands: ${image.bands}');

  // Save to a different format
  image.writeToFile('/path/to/output.png');

  // Or get as bytes
  final pngBytes = image.writeToBuffer('.png');

  // Don't forget to dispose
  image.dispose();

  // Shutdown when done (optional)
  shutdownVips();
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

## License

LGPL-2.1 (same as libvips)
