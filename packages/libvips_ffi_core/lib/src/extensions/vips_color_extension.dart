import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../bindings/vips_bindings_generated.dart' hide VipsInterpretation;
import '../vips_image.dart';
import '../vips_variadic_bindings.dart';

/// Extension providing image color operations.
///
/// 提供图像颜色操作的扩展。
///
/// This extension includes colourspace, linear, brightness, and contrast operations.
/// 此扩展包含 colourspace、linear、brightness 和 contrast 操作。
extension VipsColorExtension on VipsImageWrapper {
  /// Converts the image to a different colour space.
  ///
  /// 将图像转换为不同的色彩空间。
  ///
  /// [space] is the target colour space (see [VipsInterpretation]).
  /// [space] 是目标色彩空间（参见 [VipsInterpretation]）。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper colourspace(VipsInterpretation space) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.colourspace(pointer, outPtr, space.value);

      if (result != 0) {
        throw VipsException(
          'Failed to convert colour space. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'colourspace');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Applies a linear transformation to the image: out = in * a + b.
  ///
  /// 对图像应用线性变换：out = in * a + b。
  ///
  /// [a] is the multiplier (e.g., 1.2 for 20% brighter).
  /// [a] 是乘数（例如 1.2 表示亮度增加 20%）。
  ///
  /// [b] is the offset (e.g., 10 to add brightness).
  /// [b] 是偏移量（例如 10 表示增加亮度）。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper linear(double a, double b) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.linear1(pointer, outPtr, a, b);

      if (result != 0) {
        throw VipsException(
          'Failed to apply linear transformation. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'linear');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Adjusts brightness of the image.
  ///
  /// 调整图像亮度。
  ///
  /// [factor] is the brightness factor:
  /// [factor] 是亮度因子：
  ///
  /// - 1.0 = no change / 无变化
  /// - > 1.0 = brighter / 更亮
  /// - < 1.0 = darker / 更暗
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  VipsImageWrapper brightness(double factor) {
    return linear(factor, 0);
  }

  /// Adjusts contrast of the image.
  ///
  /// 调整图像对比度。
  ///
  /// [factor] is the contrast factor:
  /// [factor] 是对比度因子：
  ///
  /// - 1.0 = no change / 无变化
  /// - > 1.0 = more contrast / 更高对比度
  /// - < 1.0 = less contrast / 更低对比度
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  VipsImageWrapper contrast(double factor) {
    // Contrast adjustment: out = (in - 128) * factor + 128
    return linear(factor, 128 * (1 - factor));
  }
}
