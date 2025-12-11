/// Pre-compiled libvips for macOS.
///
/// macOS 预编译的 libvips。
///
/// This package provides pre-compiled libvips binaries for macOS.
/// 此包提供 macOS 预编译的 libvips 二进制文件。
///
/// ## Usage / 使用方法
///
/// Simply add this package to your dependencies:
/// 只需将此包添加到依赖项：
///
/// ```yaml
/// dependencies:
///   libvips_ffi_macos: ^1.0.0
/// ```
///
/// Then use the core API:
/// 然后使用核心 API：
///
/// ```dart
/// import 'package:libvips_ffi_macos/libvips_ffi_macos.dart';
///
/// void main() {
///   initVipsMacos();
///   // Use libvips...
///   shutdownVips();
/// }
/// ```
library libvips_ffi_macos;

// Re-export core package
export 'package:libvips_ffi_core/libvips_ffi_core.dart';

// Export macOS-specific loader
export 'src/macos_loader.dart' show MacosVipsLoader, initVipsMacos;
