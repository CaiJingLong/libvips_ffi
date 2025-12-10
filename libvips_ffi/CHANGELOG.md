# Changelog

All notable changes to this project will be documented in this file.

## Version Format

`<plugin_version>+<libvips_version>`

- Plugin version follows [Semantic Versioning](https://semver.org/)
- Build metadata (`+8.16.0`) indicates the bundled libvips version

---

## 0.0.1+8.16.0

### Features

- **High-performance image processing** using libvips FFI bindings
- **Cross-platform support** for Android (arm64-v8a, armeabi-v7a, x86_64) and iOS
- **Sync API** via `VipsImageWrapper` for direct image operations
- **Async API** via `VipsImageAsync` using Dart Isolates to avoid UI blocking
- **Compute API** via `VipsCompute` using Flutter's `compute()` for one-off operations

### Image Operations

- Load/save images from files and memory buffers
- Resize, thumbnail, rotate, crop, flip
- Gaussian blur, sharpen, invert
- Brightness and contrast adjustment
- Auto-rotate based on EXIF orientation
- Smart crop (attention-based)
- Colorspace conversion (grayscale, sRGB, etc.)
- Format conversion (JPEG, PNG, WebP, etc.)

### Supported Platforms

- **Android**: arm64-v8a, armeabi-v7a, x86_64 (all 64-bit libraries are 16KB aligned for Android 15+ compatibility)
- **iOS**: arm64 (device), arm64 (simulator on Apple Silicon Mac)
  - Minimum iOS version: 12.0
  - Note: x86_64 simulator (Intel Mac) is not supported
