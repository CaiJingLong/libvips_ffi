import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../bindings/vips_bindings_generated.dart';
import '../vips_image.dart';
import '../vips_variadic_bindings.dart';

/// Extension providing image utility operations.
///
/// 提供图像工具操作的扩展。
///
/// This extension includes copy operation.
/// 此扩展包含 copy 操作。
extension VipsUtilityExtension on VipsImageWrapper {
  /// Creates a copy of the image.
  ///
  /// 创建图像的副本。
  ///
  /// Returns a new image. Remember to dispose it when done.
  /// 返回新图像。完成后记得调用 dispose。
  ///
  /// Throws [VipsException] if the operation fails.
  /// 如果操作失败，则抛出 [VipsException]。
  VipsImageWrapper copy() {
    checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = variadicBindings.copy(pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to copy image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper.fromPointer(outPtr.value, label: 'copy');
    } finally {
      calloc.free(outPtr);
    }
  }
}
