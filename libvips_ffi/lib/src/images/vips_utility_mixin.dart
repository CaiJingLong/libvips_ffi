import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../bindings/vips_bindings_generated.dart';
import '../vips_core.dart';
import 'vips_image_base.dart';

/// Mixin providing image utility operations.
///
/// 提供图像工具操作的 mixin。
///
/// This mixin includes copy operation.
/// 此 mixin 包含 copy 操作。
mixin VipsUtilityMixin on VipsImageBase, VipsBindingsAccess {
  /// Creates a copy of the image.
  ///
  /// 创建图像的副本。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  dynamic copy() {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = bindings.copy(pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to copy image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return createFromPointer(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }
}
