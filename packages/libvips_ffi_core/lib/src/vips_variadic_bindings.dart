// ignore_for_file: unused_field
// Unused fields are kept for potential future use or fallback to variadic calls
// 保留未使用的字段以备将来使用或回退到 variadic 调用

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'bindings/vips_bindings_generated.dart';
import 'vips_ffi_types.dart';
import 'vips_core.dart';
import 'vips_operation.dart' as op;

/// Custom bindings for variadic functions that need NULL termination.
///
/// 需要 NULL 终止的可变参数函数的自定义绑定。
///
/// These bindings wrap libvips C functions that use variadic arguments,
/// providing proper NULL termination for safe FFI calls.
/// 这些绑定封装了使用可变参数的 libvips C 函数，
/// 为安全的 FFI 调用提供正确的 NULL 终止。
class VipsVariadicBindings {
  final ffi.DynamicLibrary _lib;

  VipsVariadicBindings(this._lib);

  // ============ Image I/O Functions ============
  // ============ 图像 I/O 函数 ============

  late final _vipsImageNewFromFile = _lib
      .lookup<ffi.NativeFunction<VipsImageNewFromFileNative>>(
          'vips_image_new_from_file')
      .asFunction<VipsImageNewFromFileDart>();

  late final _vipsImageWriteToFile = _lib
      .lookup<ffi.NativeFunction<VipsImageWriteToFileNative>>(
          'vips_image_write_to_file')
      .asFunction<VipsImageWriteToFileDart>();

  late final _vipsImageWriteToBuffer = _lib
      .lookup<ffi.NativeFunction<VipsImageWriteToBufferNative>>(
          'vips_image_write_to_buffer')
      .asFunction<VipsImageWriteToBufferDart>();

  late final _vipsImageNewFromBuffer = _lib
      .lookup<ffi.NativeFunction<VipsImageNewFromBufferNative>>(
          'vips_image_new_from_buffer')
      .asFunction<VipsImageNewFromBufferDart>();

  ffi.Pointer<VipsImage> imageNewFromFile(ffi.Pointer<ffi.Char> name) {
    // Use GObject API to avoid variadic function issues
    final filename = name.cast<Utf8>().toDartString();
    return op.VipsOperation.loadFromFile(filename);
  }

  int imageWriteToFile(
      ffi.Pointer<VipsImage> image, ffi.Pointer<ffi.Char> name) {
    // Use GObject API to avoid variadic function issues
    try {
      final filename = name.cast<Utf8>().toDartString();
      op.VipsOperation.saveToFile(image, filename);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int imageWriteToBuffer(
    ffi.Pointer<VipsImage> image,
    ffi.Pointer<ffi.Char> suffix,
    ffi.Pointer<ffi.Pointer<ffi.Void>> buf,
    ffi.Pointer<ffi.Size> size,
  ) {
    return _vipsImageWriteToBuffer(image, suffix, buf, size, ffi.nullptr);
  }

  ffi.Pointer<VipsImage> imageNewFromBuffer(
    ffi.Pointer<ffi.Void> buf,
    int len,
    ffi.Pointer<ffi.Char> optionString,
  ) {
    return _vipsImageNewFromBuffer(buf, len, optionString, ffi.nullptr);
  }

  // ============ Transform Functions ============
  // ============ 变换函数 ============

  late final _vipsResize = _lib
      .lookup<ffi.NativeFunction<VipsResizeNative>>('vips_resize')
      .asFunction<VipsResizeDart>();

  late final _vipsRotate = _lib
      .lookup<ffi.NativeFunction<VipsRotateNative>>('vips_rotate')
      .asFunction<VipsRotateDart>();

  late final _vipsCrop = _lib
      .lookup<ffi.NativeFunction<VipsCropNative>>('vips_crop')
      .asFunction<VipsCropDart>();

  late final _vipsThumbnailImage = _lib
      .lookup<ffi.NativeFunction<VipsThumbnailImageNative>>(
          'vips_thumbnail_image')
      .asFunction<VipsThumbnailImageDart>();

  late final _vipsThumbnail = _lib
      .lookup<ffi.NativeFunction<VipsThumbnailNative>>('vips_thumbnail')
      .asFunction<VipsThumbnailDart>();

  late final _vipsThumbnailBuffer = _lib
      .lookup<ffi.NativeFunction<VipsThumbnailBufferNative>>(
          'vips_thumbnail_buffer')
      .asFunction<VipsThumbnailBufferDart>();

  late final _vipsFlip = _lib
      .lookup<ffi.NativeFunction<VipsFlipNative>>('vips_flip')
      .asFunction<VipsFlipDart>();

  late final _vipsEmbed = _lib
      .lookup<ffi.NativeFunction<VipsEmbedNative>>('vips_embed')
      .asFunction<VipsEmbedDart>();

  late final _vipsExtractArea = _lib
      .lookup<ffi.NativeFunction<VipsExtractAreaNative>>('vips_extract_area')
      .asFunction<VipsExtractAreaDart>();

  late final _vipsSmartcrop = _lib
      .lookup<ffi.NativeFunction<VipsSmartcropNative>>('vips_smartcrop')
      .asFunction<VipsSmartcropDart>();

  late final _vipsGravity = _lib
      .lookup<ffi.NativeFunction<VipsGravityNative>>('vips_gravity')
      .asFunction<VipsGravityDart>();

  int resize(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double scale,
  ) {
    // Use GObject API to avoid variadic function issues
    try {
      final result = op.VipsOperation.callWithImage(
        'resize',
        in1,
        doubleArgs: {'scale': scale},
      );
      out.value = result;
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int rotate(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double angle,
  ) {
    try {
      out.value = op.VipsOperation.callRotate(in1, angle);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int crop(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int left,
    int top,
    int width,
    int height,
  ) {
    try {
      out.value = op.VipsOperation.callCrop(in1, left, top, width, height);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int thumbnailImage(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int width,
  ) {
    try {
      out.value = op.VipsOperation.callThumbnailImage(in1, width);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int thumbnail(
    ffi.Pointer<ffi.Char> filename,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int width,
  ) {
    return _vipsThumbnail(filename, out, width, ffi.nullptr);
  }

  int thumbnailBuffer(
    ffi.Pointer<ffi.Void> buf,
    int len,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int width,
  ) {
    return _vipsThumbnailBuffer(buf, len, out, width, ffi.nullptr);
  }

  int flip(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int direction,
  ) {
    try {
      out.value = op.VipsOperation.callFlip(in1, direction);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int embed(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int x,
    int y,
    int width,
    int height,
  ) {
    try {
      out.value = op.VipsOperation.callEmbed(in1, x, y, width, height);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int extractArea(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int left,
    int top,
    int width,
    int height,
  ) {
    try {
      out.value = op.VipsOperation.callExtractArea(in1, left, top, width, height);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int smartcrop(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int width,
    int height,
  ) {
    try {
      out.value = op.VipsOperation.callSmartcrop(in1, width, height);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int gravity(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int direction,
    int width,
    int height,
  ) {
    try {
      out.value = op.VipsOperation.callGravity(in1, direction, width, height);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  // ============ Filter Functions ============
  // ============ 滤镜函数 ============

  late final _vipsGaussblur = _lib
      .lookup<ffi.NativeFunction<VipsGaussblurNative>>('vips_gaussblur')
      .asFunction<VipsGaussblurDart>();

  late final _vipsSharpen = _lib
      .lookup<ffi.NativeFunction<VipsSharpenNative>>('vips_sharpen')
      .asFunction<VipsSharpenDart>();

  late final _vipsInvert = _lib
      .lookup<ffi.NativeFunction<VipsInvertNative>>('vips_invert')
      .asFunction<VipsInvertDart>();

  late final _vipsFlatten = _lib
      .lookup<ffi.NativeFunction<VipsFlattenNative>>('vips_flatten')
      .asFunction<VipsFlattenDart>();

  late final _vipsGamma = _lib
      .lookup<ffi.NativeFunction<VipsGammaNative>>('vips_gamma')
      .asFunction<VipsGammaDart>();

  late final _vipsAutorot = _lib
      .lookup<ffi.NativeFunction<VipsAutorotNative>>('vips_autorot')
      .asFunction<VipsAutorotDart>();

  int gaussblur(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double sigma,
  ) {
    try {
      out.value = op.VipsOperation.callGaussblur(in1, sigma);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int sharpen(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    try {
      out.value = op.VipsOperation.callSharpen(in1);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int invert(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    try {
      out.value = op.VipsOperation.callInvert(in1);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int flatten(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    try {
      out.value = op.VipsOperation.callFlatten(in1);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int gamma(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    try {
      out.value = op.VipsOperation.callGamma(in1);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int autorot(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    try {
      out.value = op.VipsOperation.callAutorot(in1);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  // ============ Color Functions ============
  // ============ 颜色函数 ============

  late final _vipsColourspace = _lib
      .lookup<ffi.NativeFunction<VipsColourspaceNative>>('vips_colourspace')
      .asFunction<VipsColourspaceDart>();

  late final _vipsCast = _lib
      .lookup<ffi.NativeFunction<VipsCastNative>>('vips_cast')
      .asFunction<VipsCastDart>();

  late final _vipsLinear1 = _lib
      .lookup<ffi.NativeFunction<VipsLinear1Native>>('vips_linear1')
      .asFunction<VipsLinear1Dart>();

  int colourspace(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int space,
  ) {
    try {
      out.value = op.VipsOperation.callColourspace(in1, space);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int cast(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int format,
  ) {
    try {
      out.value = op.VipsOperation.callCast(in1, format);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  int linear1(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double a,
    double b,
  ) {
    try {
      out.value = op.VipsOperation.callLinear1(in1, a, b);
      return 0;
    } catch (_) {
      return -1;
    }
  }

  // ============ Utility Functions ============
  // ============ 工具函数 ============

  late final _vipsCopy = _lib
      .lookup<ffi.NativeFunction<VipsCopyNative>>('vips_copy')
      .asFunction<VipsCopyDart>();

  int copy(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    try {
      out.value = op.VipsOperation.callCopy(in1);
      return 0;
    } catch (_) {
      return -1;
    }
  }
}

/// Global variadic bindings instance (lazy initialized).
///
/// 全局可变参数绑定实例（延迟初始化）。
VipsVariadicBindings? _variadicBindings;

/// Get the variadic bindings instance.
VipsVariadicBindings get variadicBindings {
  return _variadicBindings ??= VipsVariadicBindings(vipsLibrary);
}
