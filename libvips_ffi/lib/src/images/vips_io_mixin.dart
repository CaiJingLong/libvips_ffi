import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../vips_core.dart';
import 'vips_image_base.dart';

/// Mixin providing image I/O operations.
///
/// 提供图像 I/O 操作的 mixin。
///
/// This mixin includes writeToFile and writeToBuffer operations.
/// 此 mixin 包含 writeToFile 和 writeToBuffer 操作。
mixin VipsIOMixin on VipsImageBase, VipsBindingsAccess {
  /// Writes the image to a file.
  ///
  /// 将图像写入文件。
  ///
  /// The format is determined by the file extension.
  /// 格式由文件扩展名决定。
  ///
  /// [filename] is the path to write the image to.
  /// [filename] 是要写入图像的路径。
  ///
  /// Throws [VipsException] if writing fails.
  /// 如果写入失败，则抛出 [VipsException]。
  void writeToFile(String filename) {
    checkDisposed();
    clearVipsError();

    final filenamePtr = filename.toNativeUtf8();
    try {
      final result = bindings.imageWriteToFile(pointer, filenamePtr.cast());

      if (result != 0) {
        throw VipsException(
          'Failed to write image: $filename. ${getVipsError() ?? "Unknown error"}',
        );
      }
    } finally {
      calloc.free(filenamePtr);
    }
  }

  /// Writes the image to a memory buffer.
  ///
  /// 将图像写入内存缓冲区。
  ///
  /// [suffix] determines the format (e.g., '.jpg', '.png', '.webp').
  /// [suffix] 决定格式（例如 '.jpg'、'.png'、'.webp'）。
  ///
  /// Returns the encoded image data.
  /// 返回编码后的图像数据。
  ///
  /// Throws [VipsException] if encoding fails.
  /// 如果编码失败，则抛出 [VipsException]。
  Uint8List writeToBuffer(String suffix) {
    checkDisposed();
    clearVipsError();

    final suffixPtr = suffix.toNativeUtf8();
    final bufPtr = calloc<ffi.Pointer<ffi.Void>>();
    final sizePtr = calloc<ffi.Size>();

    try {
      final result = bindings.imageWriteToBuffer(
        pointer,
        suffixPtr.cast(),
        bufPtr,
        sizePtr,
      );

      if (result != 0) {
        throw VipsException(
          'Failed to write image to buffer. ${getVipsError() ?? "Unknown error"}',
        );
      }

      final size = sizePtr.value;
      final data = Uint8List(size);
      final dataPtr = bufPtr.value.cast<ffi.Uint8>();

      for (var i = 0; i < size; i++) {
        data[i] = dataPtr[i];
      }

      // Free the buffer allocated by vips
      stdBindings.g_free(bufPtr.value);

      return data;
    } finally {
      calloc.free(suffixPtr);
      calloc.free(bufPtr);
      calloc.free(sizePtr);
    }
  }
}
