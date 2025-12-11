# libvips_ffi_macos

Pre-compiled libvips for macOS. Part of the libvips_ffi package family.

## Features

- Pre-compiled libvips binaries for macOS
- Supports both Intel (x64) and Apple Silicon (arm64)
- Automatic architecture detection

## Usage

```dart
import 'package:libvips_ffi_macos/libvips_ffi_macos.dart';

void main() {
  initVipsMacos();
  
  // Use libvips...
  
  shutdownVips();
}
```

## Note

This package contains placeholder structure. Pre-compiled binaries need to be added before publishing.

## Related Packages

- [libvips_ffi_core](https://pub.dev/packages/libvips_ffi_core) - Core FFI bindings
- [libvips_ffi_desktop](https://pub.dev/packages/libvips_ffi_desktop) - Desktop meta package
