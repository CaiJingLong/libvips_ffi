import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../vips_core.dart';
import '../vips_image.dart';
import '../vips_variadic_bindings.dart';

/// Extension providing image I/O operations.
///
/// 提供图像 I/O 操作的扩展。
///
/// This extension includes writeToFile and writeToBuffer operations.
/// 此扩展包含 writeToFile 和 writeToBuffer 操作。
extension VipsIOExtension on VipsImageWrapper {
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
      final result = variadicBindings.imageWriteToFile(pointer, filenamePtr.cast());

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
      final result = variadicBindings.imageWriteToBuffer(
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
      final dataPtr = bufPtr.value.cast<ffi.Uint8>();
      // Use batch copy from native memory (much faster than byte-by-byte)
      // 使用批量拷贝从原生内存复制（比逐字节拷贝快得多）
      final data = Uint8List.fromList(dataPtr.asTypedList(size));

      // Free the buffer allocated by vips
      vipsBindings.g_free(bufPtr.value);

      return data;
    } finally {
      calloc.free(suffixPtr);
      calloc.free(bufPtr);
      calloc.free(sizePtr);
    }
  }
}
