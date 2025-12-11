import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../bindings/vips_bindings_generated.dart' hide VipsDirection;
import '../vips_image.dart';
import '../vips_variadic_bindings.dart';

/// Extension providing image transformation operations.
///
/// 提供图像变换操作的扩展。
///
/// This extension includes resize, rotate, crop, thumbnail, flip,
/// embed, extractArea, and smartCrop operations.
/// 此扩展包含 resize、rotate、crop、thumbnail、flip、
/// embed、extractArea 和 smartCrop 操作。
extension VipsTransformExtension on VipsImageWrapper {
  /// Resizes the image by a scale factor.
  ///
  /// 按比例因子调整图像大小。
  ///
  /// [scale] is the resize factor (e.g., 0.5 for half size, 2.0 for double).
  /// [scale] 是调整大小的因子（例如 0.5 表示一半大小，2.0 表示两倍）。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper resize(double scale) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.resize(pointer, outPtr, scale);

      if (result != 0) {
        throw VipsException(
          'Failed to resize image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'resize');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Rotates the image by an angle in degrees.
  ///
  /// 按角度旋转图像。
  ///
  /// [angle] is the rotation angle in degrees (positive = counter-clockwise).
  /// [angle] 是旋转角度（度数，正值 = 逆时针）。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper rotate(double angle) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.rotate(pointer, outPtr, angle);

      if (result != 0) {
        throw VipsException(
          'Failed to rotate image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'rotate');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Crops a region from the image.
  ///
  /// 从图像裁剪一个区域。
  ///
  /// [left], [top] specify the top-left corner of the crop region.
  /// [left]、[top] 指定裁剪区域的左上角。
  ///
  /// [width], [height] specify the size of the crop region.
  /// [width]、[height] 指定裁剪区域的大小。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper crop(int left, int top, int width, int height) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result =
          variadicBindings.crop(pointer, outPtr, left, top, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to crop image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'crop');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Creates a thumbnail of the image with a target width.
  ///
  /// 创建指定宽度的图像缩略图。
  ///
  /// This is optimized for creating thumbnails - it will shrink the image
  /// as it loads, making it much faster than loading then resizing.
  /// 这是为创建缩略图优化的 - 它会在加载时缩小图像，
  /// 比先加载再调整大小快得多。
  ///
  /// [targetWidth] is the desired width in pixels. Height is calculated
  /// to maintain aspect ratio.
  /// [targetWidth] 是期望的宽度（像素）。高度会自动计算以保持宽高比。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper thumbnail(int targetWidth) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.thumbnailImage(pointer, outPtr, targetWidth);

      if (result != 0) {
        throw VipsException(
          'Failed to create thumbnail. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'thumbnail');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Flips the image horizontally or vertically.
  ///
  /// 水平或垂直翻转图像。
  ///
  /// [direction] determines the flip direction:
  /// [direction] 决定翻转方向：
  ///
  /// - [VipsDirection.horizontal] (0): flip left-right / 左右翻转
  /// - [VipsDirection.vertical] (1): flip top-bottom / 上下翻转
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper flip(VipsDirection direction) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.flip(pointer, outPtr, direction.index);

      if (result != 0) {
        throw VipsException(
          'Failed to flip image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'flip');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Embeds the image in a larger canvas.
  ///
  /// 将图像嵌入到更大的画布中。
  ///
  /// [x], [y] specify the position of the image in the new canvas.
  /// [x]、[y] 指定图像在新画布中的位置。
  ///
  /// [width], [height] specify the size of the new canvas.
  /// [width]、[height] 指定新画布的大小。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper embed(int x, int y, int width, int height) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result =
          variadicBindings.embed(pointer, outPtr, x, y, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to embed image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'embed');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Extracts an area from the image (alias for crop).
  ///
  /// 从图像提取一个区域（crop 的别名）。
  ///
  /// [left], [top] specify the top-left corner.
  /// [left]、[top] 指定左上角。
  ///
  /// [width], [height] specify the size of the area.
  /// [width]、[height] 指定区域的大小。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper extractArea(int left, int top, int width, int height) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result =
          variadicBindings.extractArea(pointer, outPtr, left, top, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to extract area. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'extractArea');
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Smart crops the image to the specified size.
  ///
  /// 智能裁剪图像到指定大小。
  ///
  /// Uses attention-based cropping to find the most interesting part
  /// of the image.
  /// 使用基于注意力的裁剪来找到图像中最有趣的部分。
  ///
  /// [width], [height] specify the target size.
  /// [width]、[height] 指定目标大小。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper smartCrop(int width, int height) {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.smartcrop(pointer, outPtr, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to smart crop image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'smartCrop');
    } finally {
      calloc.free(outPtr);
    }
  }
}
