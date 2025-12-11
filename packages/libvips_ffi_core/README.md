# libvips_ffi_core

Pure Dart FFI bindings for [libvips](https://www.libvips.org/) image processing library. No Flutter dependency.

## Features

- Pure Dart implementation (no Flutter required)
- Image loading/saving (JPEG, PNG, WebP, TIFF, etc.)
- Image transformations (resize, rotate, crop, flip)
- Image filters (blur, sharpen, invert)
- Color space conversions
- Uses VarArgs for variadic function calls (Dart 3.0+)

## Requirements

- Dart SDK >= 3.5.0
- libvips library installed on the system

## Usage

```dart
import 'package:libvips_ffi_core/libvips_ffi_core.dart';

void main() {
  // Initialize with a pre-loaded library
  initVipsCore(DynamicLibrary.open('libvips.dylib'));
  
  // Load and process image
  final image = VipsImageWrapper.fromFile('input.jpg');
  final resized = image.resize(0.5);
  resized.writeToFile('output.jpg');
  
  // Cleanup
  resized.dispose();
  image.dispose();
  shutdownVips();
}
```

## Related Packages

- [libvips_ffi](https://pub.dev/packages/libvips_ffi) - Flutter mobile support
- [libvips_ffi_desktop](https://pub.dev/packages/libvips_ffi_desktop) - Desktop meta package
- [libvips_ffi_system](https://pub.dev/packages/libvips_ffi_system) - System package manager loader
