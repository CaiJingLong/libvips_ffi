import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'bindings/vips_bindings_generated.dart';
import 'vips_core.dart';

/// GObject-based operation caller for libvips.
///
/// 基于 GObject 的 libvips 操作调用器。
///
/// This class provides a way to call libvips operations without using
/// variadic functions, which are problematic with Dart FFI.
/// 此类提供了一种调用 libvips 操作的方式，避免使用 Dart FFI 有问题的 variadic 函数。
class VipsOperation {
  /// Call a libvips operation with an input image and get output image.
  ///
  /// 调用 libvips 操作，输入图像并获取输出图像。
  static ffi.Pointer<VipsImage> callWithImage(
    String operationName,
    ffi.Pointer<VipsImage> input, {
    Map<String, String> stringArgs = const {},
    Map<String, double> doubleArgs = const {},
    Map<String, int> intArgs = const {},
  }) {
    clearVipsError();

    final opNamePtr = operationName.toNativeUtf8();
    try {
      // Create operation
      final op = vipsBindings.vips_operation_new(opNamePtr.cast());
      if (op == ffi.nullptr) {
        throw VipsException(
          'Failed to create operation: $operationName. ${getVipsError()}',
        );
      }

      // Set input image using GValue
      _setImageProperty(op.cast(), 'in', input);

      // Set string arguments
      for (final entry in stringArgs.entries) {
        final result = _setStringArgument(op.cast(), entry.key, entry.value);
        if (result != 0) {
          vipsBindings.g_object_unref(op.cast());
          throw VipsException(
            'Failed to set argument ${entry.key}=${entry.value}. ${getVipsError()}',
          );
        }
      }

      // Set double arguments
      for (final entry in doubleArgs.entries) {
        _setDoubleProperty(op.cast(), entry.key, entry.value);
      }

      // Set int arguments
      for (final entry in intArgs.entries) {
        _setIntProperty(op.cast(), entry.key, entry.value);
      }

      // Build and execute operation
      final builtOp = vipsBindings.vips_cache_operation_build(op);
      if (builtOp == ffi.nullptr) {
        vipsBindings.g_object_unref(op.cast());
        throw VipsException(
          'Failed to build operation: $operationName. ${getVipsError()}',
        );
      }

      // Get output image
      final outputImage = _getImageProperty(builtOp.cast(), 'out');
      if (outputImage == ffi.nullptr) {
        vipsBindings.vips_object_unref_outputs(builtOp.cast());
        vipsBindings.g_object_unref(builtOp.cast());
        throw VipsException(
          'Failed to get output from operation: $operationName. ${getVipsError()}',
        );
      }

      // Ref the output before unreffing the operation
      vipsBindings.g_object_ref(outputImage.cast());

      // Cleanup operation
      vipsBindings.vips_object_unref_outputs(builtOp.cast());
      vipsBindings.g_object_unref(builtOp.cast());

      return outputImage;
    } finally {
      calloc.free(opNamePtr);
    }
  }

  /// Call a generic operation with only int arguments.
  static ffi.Pointer<VipsImage> callWithIntArgs(
    String operationName,
    ffi.Pointer<VipsImage> input,
    Map<String, int> intArgs,
  ) {
    return callWithImage(operationName, input, intArgs: intArgs);
  }

  /// Call crop operation.
  static ffi.Pointer<VipsImage> callCrop(
    ffi.Pointer<VipsImage> input,
    int left,
    int top,
    int width,
    int height,
  ) {
    return callWithIntArgs('crop', input, {
      'left': left,
      'top': top,
      'width': width,
      'height': height,
    });
  }

  /// Call extract_area operation (same as crop).
  static ffi.Pointer<VipsImage> callExtractArea(
    ffi.Pointer<VipsImage> input,
    int left,
    int top,
    int width,
    int height,
  ) {
    return callWithIntArgs('extract_area', input, {
      'left': left,
      'top': top,
      'width': width,
      'height': height,
    });
  }

  /// Call smartcrop operation.
  static ffi.Pointer<VipsImage> callSmartcrop(
    ffi.Pointer<VipsImage> input,
    int width,
    int height,
  ) {
    return callWithIntArgs('smartcrop', input, {
      'width': width,
      'height': height,
    });
  }

  /// Call flip operation.
  static ffi.Pointer<VipsImage> callFlip(
    ffi.Pointer<VipsImage> input,
    int direction,
  ) {
    return callWithIntArgs('flip', input, {'direction': direction});
  }

  /// Call rotate operation.
  static ffi.Pointer<VipsImage> callRotate(
    ffi.Pointer<VipsImage> input,
    double angle,
  ) {
    return callWithImage('rotate', input, doubleArgs: {'angle': angle});
  }

  /// Call thumbnail_image operation.
  static ffi.Pointer<VipsImage> callThumbnailImage(
    ffi.Pointer<VipsImage> input,
    int width,
  ) {
    return callWithIntArgs('thumbnail_image', input, {'width': width});
  }

  /// Call embed operation.
  static ffi.Pointer<VipsImage> callEmbed(
    ffi.Pointer<VipsImage> input,
    int x,
    int y,
    int width,
    int height,
  ) {
    return callWithIntArgs('embed', input, {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    });
  }

  /// Call gravity operation.
  static ffi.Pointer<VipsImage> callGravity(
    ffi.Pointer<VipsImage> input,
    int direction,
    int width,
    int height,
  ) {
    return callWithIntArgs('gravity', input, {
      'direction': direction,
      'width': width,
      'height': height,
    });
  }

  /// Call gaussblur operation.
  static ffi.Pointer<VipsImage> callGaussblur(
    ffi.Pointer<VipsImage> input,
    double sigma,
  ) {
    return callWithImage('gaussblur', input, doubleArgs: {'sigma': sigma});
  }

  /// Call sharpen operation.
  static ffi.Pointer<VipsImage> callSharpen(ffi.Pointer<VipsImage> input) {
    return callWithImage('sharpen', input);
  }

  /// Call invert operation.
  static ffi.Pointer<VipsImage> callInvert(ffi.Pointer<VipsImage> input) {
    return callWithImage('invert', input);
  }

  /// Call colourspace operation.
  static ffi.Pointer<VipsImage> callColourspace(
    ffi.Pointer<VipsImage> input,
    int space,
  ) {
    return callWithIntArgs('colourspace', input, {'space': space});
  }

  /// Call linear operation (for brightness/contrast).
  static ffi.Pointer<VipsImage> callLinear(
    ffi.Pointer<VipsImage> input,
    double a,
    double b,
  ) {
    // linear needs array arguments, use string args
    return callWithImage(
      'linear',
      input,
      stringArgs: {'a': '[$a]', 'b': '[$b]'},
    );
  }

  /// Call autorot operation.
  static ffi.Pointer<VipsImage> callAutorot(ffi.Pointer<VipsImage> input) {
    return callWithImage('autorot', input);
  }

  /// Call flatten operation.
  static ffi.Pointer<VipsImage> callFlatten(ffi.Pointer<VipsImage> input) {
    return callWithImage('flatten', input);
  }

  /// Call gamma operation.
  static ffi.Pointer<VipsImage> callGamma(ffi.Pointer<VipsImage> input) {
    return callWithImage('gamma', input);
  }

  /// Call cast operation.
  static ffi.Pointer<VipsImage> callCast(
    ffi.Pointer<VipsImage> input,
    int format,
  ) {
    return callWithIntArgs('cast', input, {'format': format});
  }

  /// Call linear1 operation.
  static ffi.Pointer<VipsImage> callLinear1(
    ffi.Pointer<VipsImage> input,
    double a,
    double b,
  ) {
    return callWithImage('linear1', input, doubleArgs: {'a': a, 'b': b});
  }

  /// Call copy operation.
  static ffi.Pointer<VipsImage> callCopy(ffi.Pointer<VipsImage> input) {
    return callWithImage('copy', input);
  }

  // ============ Helper Methods ============

  static int _setStringArgument(
    ffi.Pointer<GObject> obj,
    String name,
    String value,
  ) {
    final namePtr = name.toNativeUtf8();
    final valuePtr = value.toNativeUtf8();
    try {
      return vipsBindings.vips_object_set_argument_from_string(
        obj.cast(),
        namePtr.cast(),
        valuePtr.cast(),
      );
    } finally {
      calloc.free(namePtr);
      calloc.free(valuePtr);
    }
  }

  static void _setImageProperty(
    ffi.Pointer<GObject> obj,
    String name,
    ffi.Pointer<VipsImage> image,
  ) {
    final namePtr = name.toNativeUtf8();
    final gvalue = calloc<GValue>();
    try {
      vipsBindings.g_value_init(gvalue, vipsBindings.vips_image_get_type());
      vipsBindings.g_value_set_object(gvalue, image.cast());
      vipsBindings.g_object_set_property(obj, namePtr.cast(), gvalue);
      vipsBindings.g_value_unset(gvalue);
    } finally {
      calloc.free(namePtr);
      calloc.free(gvalue);
    }
  }

  static ffi.Pointer<VipsImage> _getImageProperty(
    ffi.Pointer<GObject> obj,
    String name,
  ) {
    final namePtr = name.toNativeUtf8();
    final gvalue = calloc<GValue>();
    try {
      vipsBindings.g_value_init(gvalue, vipsBindings.vips_image_get_type());
      vipsBindings.g_object_get_property(obj, namePtr.cast(), gvalue);
      final image = vipsBindings.g_value_get_object(gvalue);
      vipsBindings.g_value_unset(gvalue);
      return image.cast();
    } finally {
      calloc.free(namePtr);
      calloc.free(gvalue);
    }
  }

  static void _setDoubleProperty(
    ffi.Pointer<GObject> obj,
    String name,
    double value,
  ) {
    final namePtr = name.toNativeUtf8();
    final gvalue = calloc<GValue>();
    try {
      vipsBindings.g_value_init(gvalue, _gTypeDouble);
      vipsBindings.g_value_set_double(gvalue, value);
      vipsBindings.g_object_set_property(obj, namePtr.cast(), gvalue);
      vipsBindings.g_value_unset(gvalue);
    } finally {
      calloc.free(namePtr);
      calloc.free(gvalue);
    }
  }

  static void _setIntProperty(
    ffi.Pointer<GObject> obj,
    String name,
    int value,
  ) {
    final namePtr = name.toNativeUtf8();
    final gvalue = calloc<GValue>();
    try {
      vipsBindings.g_value_init(gvalue, _gTypeInt);
      vipsBindings.g_value_set_int(gvalue, value);
      vipsBindings.g_object_set_property(obj, namePtr.cast(), gvalue);
      vipsBindings.g_value_unset(gvalue);
    } finally {
      calloc.free(namePtr);
      calloc.free(gvalue);
    }
  }

  // GType constants (from GLib)
  // G_TYPE_INT = 6 << 2 = 24
  // G_TYPE_DOUBLE = 15 << 2 = 60
  static const int _gTypeInt = 24;
  static const int _gTypeDouble = 60;

  /// Load an image from file using GObject API.
  ///
  /// 使用 GObject API 从文件加载图像。
  static ffi.Pointer<VipsImage> loadFromFile(String filename) {
    clearVipsError();

    // Use the appropriate loader based on file type
    final loaderName = _findLoader(filename);
    if (loaderName == null) {
      throw VipsException('No loader found for file: $filename');
    }

    final opNamePtr = loaderName.toNativeUtf8();
    final filenamePtr = filename.toNativeUtf8();
    try {
      final op = vipsBindings.vips_operation_new(opNamePtr.cast());
      if (op == ffi.nullptr) {
        throw VipsException(
          'Failed to create loader operation: $loaderName. ${getVipsError()}',
        );
      }

      // Set filename argument
      final result = _setStringArgument(op.cast(), 'filename', filename);
      if (result != 0) {
        vipsBindings.g_object_unref(op.cast());
        throw VipsException(
          'Failed to set filename. ${getVipsError()}',
        );
      }

      // Build and execute operation
      final builtOp = vipsBindings.vips_cache_operation_build(op);
      if (builtOp == ffi.nullptr) {
        vipsBindings.g_object_unref(op.cast());
        throw VipsException(
          'Failed to load image: $filename. ${getVipsError()}',
        );
      }

      // Get output image
      final outputImage = _getImageProperty(builtOp.cast(), 'out');
      if (outputImage == ffi.nullptr) {
        vipsBindings.vips_object_unref_outputs(builtOp.cast());
        vipsBindings.g_object_unref(builtOp.cast());
        throw VipsException(
          'Failed to get loaded image. ${getVipsError()}',
        );
      }

      // Ref the output before unreffing the operation
      vipsBindings.g_object_ref(outputImage.cast());

      // Cleanup operation
      vipsBindings.vips_object_unref_outputs(builtOp.cast());
      vipsBindings.g_object_unref(builtOp.cast());

      return outputImage;
    } finally {
      calloc.free(opNamePtr);
      calloc.free(filenamePtr);
    }
  }

  /// Find the appropriate loader for a file.
  static String? _findLoader(String filename) {
    final filenamePtr = filename.toNativeUtf8();
    try {
      final loaderPtr = vipsBindings.vips_foreign_find_load(filenamePtr.cast());
      if (loaderPtr == ffi.nullptr) {
        return null;
      }
      return loaderPtr.cast<Utf8>().toDartString();
    } finally {
      calloc.free(filenamePtr);
    }
  }

  /// Save an image to file using GObject API.
  ///
  /// 使用 GObject API 保存图像到文件。
  static void saveToFile(ffi.Pointer<VipsImage> image, String filename) {
    clearVipsError();

    // Use the appropriate saver based on file type
    final saverName = _findSaver(filename);
    if (saverName == null) {
      throw VipsException('No saver found for file: $filename');
    }

    final opNamePtr = saverName.toNativeUtf8();
    try {
      final op = vipsBindings.vips_operation_new(opNamePtr.cast());
      if (op == ffi.nullptr) {
        throw VipsException(
          'Failed to create saver operation: $saverName. ${getVipsError()}',
        );
      }

      // Set input image
      _setImageProperty(op.cast(), 'in', image);

      // Set filename argument
      final result = _setStringArgument(op.cast(), 'filename', filename);
      if (result != 0) {
        vipsBindings.g_object_unref(op.cast());
        throw VipsException(
          'Failed to set filename. ${getVipsError()}',
        );
      }

      // Build and execute operation
      final builtOp = vipsBindings.vips_cache_operation_build(op);
      if (builtOp == ffi.nullptr) {
        vipsBindings.g_object_unref(op.cast());
        throw VipsException(
          'Failed to save image: $filename. ${getVipsError()}',
        );
      }

      // Cleanup operation
      vipsBindings.vips_object_unref_outputs(builtOp.cast());
      vipsBindings.g_object_unref(builtOp.cast());
    } finally {
      calloc.free(opNamePtr);
    }
  }

  /// Find the appropriate saver for a file.
  static String? _findSaver(String filename) {
    final filenamePtr = filename.toNativeUtf8();
    try {
      final saverPtr = vipsBindings.vips_foreign_find_save(filenamePtr.cast());
      if (saverPtr == ffi.nullptr) {
        return null;
      }
      return saverPtr.cast<Utf8>().toDartString();
    } finally {
      calloc.free(filenamePtr);
    }
  }
}
