import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../bindings/vips_bindings_generated.dart';
import '../vips_image.dart';
import '../vips_variadic_bindings.dart';

/// Extension providing image filter operations.
///
/// 提供图像滤镜操作的扩展。
///
/// This extension includes gaussianBlur, sharpen, invert, flatten,
/// gamma, and autoRotate operations.
/// 此扩展包含 gaussianBlur、sharpen、invert、flatten、
/// gamma 和 autoRotate 操作。
extension VipsFilterExtension on VipsImageWrapper {
  /// Applies Gaussian blur to the image.
  ///
  /// 对图像应用高斯模糊。
  ///
  /// [sigma] is the standard deviation of the Gaussian (larger = more blur).
  /// Typical values are 1.0 to 10.0.
  /// [sigma] 是高斯分布的标准差（越大 = 越模糊）。
  /// 典型值为 1.0 到 10.0。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper gaussianBlur(double sigma) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.gaussblur(pointer, outPtr, sigma);

      if (result != 0) {
        throw VipsException(
          'Failed to blur image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'gaussianBlur');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Sharpens the image using unsharp masking.
  ///
  /// 使用反锐化蒙版锐化图像。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper sharpen() {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.sharpen(pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to sharpen image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'sharpen');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Inverts the image colors (creates a negative).
  ///
  /// 反转图像颜色（创建负片效果）。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper invert() {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.invert(pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to invert image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'invert');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Flattens an image with alpha channel to RGB.
  ///
  /// 将带有 alpha 通道的图像平坦化为 RGB。
  ///
  /// The alpha channel is removed and the image is composited against
  /// a white background.
  /// alpha 通道被移除，图像与白色背景合成。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper flatten() {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.flatten(pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to flatten image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'flatten');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Applies gamma correction to the image.
  ///
  /// 对图像应用伽马校正。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper gamma() {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.gamma(pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to apply gamma. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'gamma');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Auto-rotates the image based on EXIF orientation tag.
  ///
  /// 根据 EXIF 方向标签自动旋转图像。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper autoRotate() {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.autorot(pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to auto-rotate image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'autoRotate');
    } finally {
      calloc.free(outPtr);
    }
  }
}
