# libvips_ffi_loader

Dynamic library loader for libvips_ffi with callback-based download support.

## Features

- Download libvips binaries on demand
- Callback-based progress reporting
- Platform-specific library management

## Usage

```dart
import 'package:libvips_ffi_loader/libvips_ffi_loader.dart';

void main() async {
  final loader = VipsLibraryLoader();
  
  // Check if library exists
  if (!await loader.libraryExists()) {
    // Download with progress callback
    await loader.downloadLibrary(
      onProgress: (received, total) {
        print('Download: ${(received / total * 100).toStringAsFixed(1)}%');
      },
    );
  }
  
  // Initialize
  await loader.initVips();
}
```

## Related Packages

- [libvips_ffi_core](https://pub.dev/packages/libvips_ffi_core) - Core FFI bindings
