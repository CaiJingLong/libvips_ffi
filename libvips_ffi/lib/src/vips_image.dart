import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'bindings/vips_bindings_generated.dart';
import 'vips_library.dart';

/// Global libvips bindings instance.
final VipsBindings _bindings = VipsBindings(vipsLibrary);

// Custom function types for variadic functions that need NULL termination
typedef _VipsImageNewFromFileNative = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef _VipsImageNewFromFileDart = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsImageWriteToFileNative = ffi.Int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef _VipsImageWriteToFileDart = int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsImageWriteToBufferNative = ffi.Int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> suffix,
  ffi.Pointer<ffi.Pointer<ffi.Void>> buf,
  ffi.Pointer<ffi.Size> size,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef _VipsImageWriteToBufferDart = int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> suffix,
  ffi.Pointer<ffi.Pointer<ffi.Void>> buf,
  ffi.Pointer<ffi.Size> size,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsImageNewFromBufferNative = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Void> buf,
  ffi.Size len,
  ffi.Pointer<ffi.Char> optionString,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef _VipsImageNewFromBufferDart = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Void> buf,
  int len,
  ffi.Pointer<ffi.Char> optionString,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsResizeNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double scale,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsResizeDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double scale,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsRotateNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double angle,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsRotateDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double angle,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsCropNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int left,
  ffi.Int top,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsCropDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int left,
  int top,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsThumbnailImageNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsThumbnailImageDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsThumbnailNative = ffi.Int Function(
  ffi.Pointer<ffi.Char> filename,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsThumbnailDart = int Function(
  ffi.Pointer<ffi.Char> filename,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsThumbnailBufferNative = ffi.Int Function(
  ffi.Pointer<ffi.Void> buf,
  ffi.Size len,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsThumbnailBufferDart = int Function(
  ffi.Pointer<ffi.Void> buf,
  int len,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsFlipNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int direction,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsFlipDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int direction,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsGaussblurNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double sigma,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsGaussblurDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double sigma,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsSharpenNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsSharpenDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsInvertNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsInvertDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsFlattenNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsFlattenDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsGammaNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsGammaDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsAutorotNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsAutorotDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsSmartcropNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsSmartcropDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsGravityNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int direction,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsGravityDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int direction,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsEmbedNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int x,
  ffi.Int y,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsEmbedDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int x,
  int y,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsExtractAreaNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int left,
  ffi.Int top,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsExtractAreaDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int left,
  int top,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsColourspaceNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int space,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsColourspaceDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int space,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsCastNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int format,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsCastDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int format,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsCopyNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsCopyDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef _VipsLinear1Native = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double a,
  ffi.Double b,
  ffi.Pointer<ffi.Void> terminator,
);
typedef _VipsLinear1Dart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double a,
  double b,
  ffi.Pointer<ffi.Void> terminator,
);

/// Custom bindings for variadic functions that need NULL termination
class _VipsVariadicBindings {
  final ffi.DynamicLibrary _lib;
  
  _VipsVariadicBindings(this._lib);
  
  late final _vipsImageNewFromFile = _lib
      .lookup<ffi.NativeFunction<_VipsImageNewFromFileNative>>('vips_image_new_from_file')
      .asFunction<_VipsImageNewFromFileDart>();
  
  late final _vipsImageWriteToFile = _lib
      .lookup<ffi.NativeFunction<_VipsImageWriteToFileNative>>('vips_image_write_to_file')
      .asFunction<_VipsImageWriteToFileDart>();
  
  late final _vipsImageWriteToBuffer = _lib
      .lookup<ffi.NativeFunction<_VipsImageWriteToBufferNative>>('vips_image_write_to_buffer')
      .asFunction<_VipsImageWriteToBufferDart>();
  
  late final _vipsImageNewFromBuffer = _lib
      .lookup<ffi.NativeFunction<_VipsImageNewFromBufferNative>>('vips_image_new_from_buffer')
      .asFunction<_VipsImageNewFromBufferDart>();
  
  late final _vipsResize = _lib
      .lookup<ffi.NativeFunction<_VipsResizeNative>>('vips_resize')
      .asFunction<_VipsResizeDart>();
  
  late final _vipsRotate = _lib
      .lookup<ffi.NativeFunction<_VipsRotateNative>>('vips_rotate')
      .asFunction<_VipsRotateDart>();
  
  late final _vipsCrop = _lib
      .lookup<ffi.NativeFunction<_VipsCropNative>>('vips_crop')
      .asFunction<_VipsCropDart>();
  
  late final _vipsThumbnailImage = _lib
      .lookup<ffi.NativeFunction<_VipsThumbnailImageNative>>('vips_thumbnail_image')
      .asFunction<_VipsThumbnailImageDart>();
  
  late final _vipsThumbnail = _lib
      .lookup<ffi.NativeFunction<_VipsThumbnailNative>>('vips_thumbnail')
      .asFunction<_VipsThumbnailDart>();
  
  late final _vipsThumbnailBuffer = _lib
      .lookup<ffi.NativeFunction<_VipsThumbnailBufferNative>>('vips_thumbnail_buffer')
      .asFunction<_VipsThumbnailBufferDart>();
  
  ffi.Pointer<VipsImage> imageNewFromFile(ffi.Pointer<ffi.Char> name) {
    return _vipsImageNewFromFile(name, ffi.nullptr);
  }
  
  int imageWriteToFile(ffi.Pointer<VipsImage> image, ffi.Pointer<ffi.Char> name) {
    return _vipsImageWriteToFile(image, name, ffi.nullptr);
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
  
  int resize(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double scale,
  ) {
    return _vipsResize(in1, out, scale, ffi.nullptr);
  }
  
  int rotate(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double angle,
  ) {
    return _vipsRotate(in1, out, angle, ffi.nullptr);
  }
  
  int crop(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int left,
    int top,
    int width,
    int height,
  ) {
    return _vipsCrop(in1, out, left, top, width, height, ffi.nullptr);
  }
  
  int thumbnailImage(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int width,
  ) {
    return _vipsThumbnailImage(in1, out, width, ffi.nullptr);
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
  
  // Additional image processing functions
  
  late final _vipsFlip = _lib
      .lookup<ffi.NativeFunction<_VipsFlipNative>>('vips_flip')
      .asFunction<_VipsFlipDart>();
  
  late final _vipsGaussblur = _lib
      .lookup<ffi.NativeFunction<_VipsGaussblurNative>>('vips_gaussblur')
      .asFunction<_VipsGaussblurDart>();
  
  late final _vipsSharpen = _lib
      .lookup<ffi.NativeFunction<_VipsSharpenNative>>('vips_sharpen')
      .asFunction<_VipsSharpenDart>();
  
  late final _vipsInvert = _lib
      .lookup<ffi.NativeFunction<_VipsInvertNative>>('vips_invert')
      .asFunction<_VipsInvertDart>();
  
  late final _vipsFlatten = _lib
      .lookup<ffi.NativeFunction<_VipsFlattenNative>>('vips_flatten')
      .asFunction<_VipsFlattenDart>();
  
  late final _vipsGamma = _lib
      .lookup<ffi.NativeFunction<_VipsGammaNative>>('vips_gamma')
      .asFunction<_VipsGammaDart>();
  
  late final _vipsAutorot = _lib
      .lookup<ffi.NativeFunction<_VipsAutorotNative>>('vips_autorot')
      .asFunction<_VipsAutorotDart>();
  
  late final _vipsSmartcrop = _lib
      .lookup<ffi.NativeFunction<_VipsSmartcropNative>>('vips_smartcrop')
      .asFunction<_VipsSmartcropDart>();
  
  late final _vipsGravity = _lib
      .lookup<ffi.NativeFunction<_VipsGravityNative>>('vips_gravity')
      .asFunction<_VipsGravityDart>();
  
  late final _vipsEmbed = _lib
      .lookup<ffi.NativeFunction<_VipsEmbedNative>>('vips_embed')
      .asFunction<_VipsEmbedDart>();
  
  late final _vipsExtractArea = _lib
      .lookup<ffi.NativeFunction<_VipsExtractAreaNative>>('vips_extract_area')
      .asFunction<_VipsExtractAreaDart>();
  
  late final _vipsColourspace = _lib
      .lookup<ffi.NativeFunction<_VipsColourspaceNative>>('vips_colourspace')
      .asFunction<_VipsColourspaceDart>();
  
  late final _vipsCast = _lib
      .lookup<ffi.NativeFunction<_VipsCastNative>>('vips_cast')
      .asFunction<_VipsCastDart>();
  
  late final _vipsCopy = _lib
      .lookup<ffi.NativeFunction<_VipsCopyNative>>('vips_copy')
      .asFunction<_VipsCopyDart>();
  
  late final _vipsLinear1 = _lib
      .lookup<ffi.NativeFunction<_VipsLinear1Native>>('vips_linear1')
      .asFunction<_VipsLinear1Dart>();
  
  int flip(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int direction,
  ) {
    return _vipsFlip(in1, out, direction, ffi.nullptr);
  }
  
  int gaussblur(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double sigma,
  ) {
    return _vipsGaussblur(in1, out, sigma, ffi.nullptr);
  }
  
  int sharpen(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    return _vipsSharpen(in1, out, ffi.nullptr);
  }
  
  int invert(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    return _vipsInvert(in1, out, ffi.nullptr);
  }
  
  int flatten(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    return _vipsFlatten(in1, out, ffi.nullptr);
  }
  
  int gamma(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    return _vipsGamma(in1, out, ffi.nullptr);
  }
  
  int autorot(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    return _vipsAutorot(in1, out, ffi.nullptr);
  }
  
  int smartcrop(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int width,
    int height,
  ) {
    return _vipsSmartcrop(in1, out, width, height, ffi.nullptr);
  }
  
  int gravity(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int direction,
    int width,
    int height,
  ) {
    return _vipsGravity(in1, out, direction, width, height, ffi.nullptr);
  }
  
  int embed(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int x,
    int y,
    int width,
    int height,
  ) {
    return _vipsEmbed(in1, out, x, y, width, height, ffi.nullptr);
  }
  
  int extractArea(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int left,
    int top,
    int width,
    int height,
  ) {
    return _vipsExtractArea(in1, out, left, top, width, height, ffi.nullptr);
  }
  
  int colourspace(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int space,
  ) {
    return _vipsColourspace(in1, out, space, ffi.nullptr);
  }
  
  int cast(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    int format,
  ) {
    return _vipsCast(in1, out, format, ffi.nullptr);
  }
  
  int copy(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ) {
    return _vipsCopy(in1, out, ffi.nullptr);
  }
  
  int linear1(
    ffi.Pointer<VipsImage> in1,
    ffi.Pointer<ffi.Pointer<VipsImage>> out,
    double a,
    double b,
  ) {
    return _vipsLinear1(in1, out, a, b, ffi.nullptr);
  }
}

/// Custom variadic bindings instance
final _VipsVariadicBindings _variadicBindings = _VipsVariadicBindings(vipsLibrary);

/// Whether libvips has been initialized.
bool _initialized = false;

/// Initialize libvips.
///
/// This must be called before using any other libvips functions.
/// It's safe to call multiple times - subsequent calls are no-ops.
///
/// Throws [VipsException] if initialization fails.
void initVips([String appName = 'libvips_ffi']) {
  if (_initialized) return;

  final appNamePtr = appName.toNativeUtf8();
  try {
    final result = _bindings.vips_init(appNamePtr.cast());
    if (result != 0) {
      throw VipsException('Failed to initialize libvips: ${getVipsError()}');
    }
    _initialized = true;
  } finally {
    calloc.free(appNamePtr);
  }
}

/// Shutdown libvips and free resources.
///
/// Call this when you're done using libvips.
void shutdownVips() {
  if (!_initialized) return;
  _bindings.vips_shutdown();
  _initialized = false;
}

/// Get the current libvips error message.
String? getVipsError() {
  final errorPtr = _bindings.vips_error_buffer();
  if (errorPtr == ffi.nullptr) return null;
  
  try {
    // Try to decode as UTF-8, but handle potential encoding issues
    return errorPtr.cast<Utf8>().toDartString();
  } catch (e) {
    // If UTF-8 decoding fails, try to read as raw bytes and convert
    // This can happen if the error message contains non-UTF-8 characters
    try {
      // Read bytes until null terminator
      final bytes = <int>[];
      var i = 0;
      while (true) {
        final byte = errorPtr.cast<ffi.Uint8>()[i];
        if (byte == 0) break;
        bytes.add(byte);
        i++;
        if (i > 4096) break; // Safety limit
      }
      // Replace invalid UTF-8 sequences
      return String.fromCharCodes(bytes.where((b) => b < 128));
    } catch (_) {
      return 'Error reading vips error buffer';
    }
  }
}

/// Clear the libvips error buffer.
void clearVipsError() {
  _bindings.vips_error_clear();
}

/// Get libvips version information.
///
/// [flag] determines what version info to return:
/// - 0: major version
/// - 1: minor version
/// - 2: micro version
/// - 3: library current
/// - 4: library revision
/// - 5: library age
int vipsVersion(int flag) {
  return _bindings.vips_version(flag);
}

/// Get libvips version as a string (e.g., "8.15.0").
String get vipsVersionString {
  return '${vipsVersion(0)}.${vipsVersion(1)}.${vipsVersion(2)}';
}

/// Exception thrown by libvips operations.
class VipsException implements Exception {
  final String message;

  VipsException(this.message);

  @override
  String toString() => 'VipsException: $message';
}

/// High-level wrapper for VipsImage.
///
/// This class provides a safe, Dart-friendly interface to libvips images.
/// Resources are automatically managed - call [dispose] when done.
class VipsImageWrapper {
  final ffi.Pointer<VipsImage> _pointer;
  bool _disposed = false;

  VipsImageWrapper._(this._pointer);

  /// Whether this image has been disposed.
  bool get isDisposed => _disposed;

  /// Whether the underlying pointer is null.
  bool get isNull => _pointer == ffi.nullptr;

  /// Get the underlying pointer (for advanced use).
  ///
  /// Throws [StateError] if the image has been disposed.
  ffi.Pointer<VipsImage> get pointer {
    _checkDisposed();
    return _pointer;
  }

  /// Load an image from a file.
  ///
  /// Throws [VipsException] if loading fails.
  factory VipsImageWrapper.fromFile(String filename) {
    initVips();
    clearVipsError();

    final filenamePtr = filename.toNativeUtf8();
    try {
      // Use custom binding with NULL terminator for variadic function
      final imagePtr = _variadicBindings.imageNewFromFile(filenamePtr.cast());

      if (imagePtr == ffi.nullptr) {
        final error = getVipsError();
        clearVipsError();
        throw VipsException(
          'Failed to load image: $filename. ${error ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(imagePtr);
    } finally {
      calloc.free(filenamePtr);
    }
  }

  /// Load an image from memory buffer.
  ///
  /// [data] is the image data in any supported format (JPEG, PNG, etc.).
  /// [optionString] can specify format options.
  ///
  /// Throws [VipsException] if loading fails.
  factory VipsImageWrapper.fromBuffer(
    Uint8List data, {
    String optionString = '',
  }) {
    initVips();
    clearVipsError();

    final dataPtr = calloc<ffi.Uint8>(data.length);
    final optionPtr = optionString.toNativeUtf8();

    try {
      // Copy data to native memory
      for (var i = 0; i < data.length; i++) {
        dataPtr[i] = data[i];
      }

      // Use custom binding with NULL terminator for variadic function
      final imagePtr = _variadicBindings.imageNewFromBuffer(
        dataPtr.cast(),
        data.length,
        optionPtr.cast(),
      );

      if (imagePtr == ffi.nullptr) {
        throw VipsException(
          'Failed to load image from buffer. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(imagePtr);
    } finally {
      calloc.free(dataPtr);
      calloc.free(optionPtr);
    }
  }

  /// Get image width in pixels.
  int get width {
    _checkDisposed();
    return _bindings.vips_image_get_width(_pointer);
  }

  /// Get image height in pixels.
  int get height {
    _checkDisposed();
    return _bindings.vips_image_get_height(_pointer);
  }

  /// Get number of bands (channels) in the image.
  int get bands {
    _checkDisposed();
    return _bindings.vips_image_get_bands(_pointer);
  }

  /// Write the image to a file.
  ///
  /// The format is determined by the file extension.
  ///
  /// Throws [VipsException] if writing fails.
  void writeToFile(String filename) {
    _checkDisposed();
    clearVipsError();

    final filenamePtr = filename.toNativeUtf8();
    try {
      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.imageWriteToFile(_pointer, filenamePtr.cast());

      if (result != 0) {
        throw VipsException(
          'Failed to write image: $filename. ${getVipsError() ?? "Unknown error"}',
        );
      }
    } finally {
      calloc.free(filenamePtr);
    }
  }

  /// Write the image to a memory buffer.
  ///
  /// [suffix] determines the format (e.g., '.jpg', '.png', '.webp').
  ///
  /// Returns the encoded image data.
  /// Throws [VipsException] if encoding fails.
  Uint8List writeToBuffer(String suffix) {
    _checkDisposed();
    clearVipsError();

    final suffixPtr = suffix.toNativeUtf8();
    final bufPtr = calloc<ffi.Pointer<ffi.Void>>();
    final sizePtr = calloc<ffi.Size>();

    try {
      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.imageWriteToBuffer(
        _pointer,
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
      _bindings.g_free(bufPtr.value);

      return data;
    } finally {
      calloc.free(suffixPtr);
      calloc.free(bufPtr);
      calloc.free(sizePtr);
    }
  }

  // ============ Image Processing Operations ============

  /// Resize the image by a scale factor.
  ///
  /// [scale] is the resize factor (e.g., 0.5 for half size, 2.0 for double).
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper resize(double scale) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.resize(_pointer, outPtr, scale);

      if (result != 0) {
        throw VipsException(
          'Failed to resize image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Rotate the image by an angle in degrees.
  ///
  /// [angle] is the rotation angle in degrees (positive = counter-clockwise).
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper rotate(double angle) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.rotate(_pointer, outPtr, angle);

      if (result != 0) {
        throw VipsException(
          'Failed to rotate image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Crop a region from the image.
  ///
  /// [left], [top] specify the top-left corner of the crop region.
  /// [width], [height] specify the size of the crop region.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper crop(int left, int top, int width, int height) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.crop(_pointer, outPtr, left, top, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to crop image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Create a thumbnail of the image with a target width.
  ///
  /// This is optimized for creating thumbnails - it will shrink the image
  /// as it loads, making it much faster than loading then resizing.
  ///
  /// [targetWidth] is the desired width in pixels. Height is calculated
  /// to maintain aspect ratio.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper thumbnail(int targetWidth) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.thumbnailImage(_pointer, outPtr, targetWidth);

      if (result != 0) {
        throw VipsException(
          'Failed to create thumbnail. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  // ============ Static Factory Methods ============

  /// Create a thumbnail directly from a file path.
  ///
  /// This is more efficient than loading then thumbnailing, as it
  /// shrinks the image during load.
  ///
  /// [filename] is the path to the image file.
  /// [targetWidth] is the desired width in pixels.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  static VipsImageWrapper thumbnailFromFile(String filename, int targetWidth) {
    initVips();
    clearVipsError();

    final filenamePtr = filename.toNativeUtf8();
    final outPtr = calloc<ffi.Pointer<VipsImage>>();

    try {
      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.thumbnail(filenamePtr.cast(), outPtr, targetWidth);

      if (result != 0) {
        throw VipsException(
          'Failed to create thumbnail from file: $filename. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(filenamePtr);
      calloc.free(outPtr);
    }
  }

  /// Create a thumbnail directly from a memory buffer.
  ///
  /// This is more efficient than loading then thumbnailing, as it
  /// shrinks the image during load.
  ///
  /// [data] is the image data in any supported format.
  /// [targetWidth] is the desired width in pixels.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  static VipsImageWrapper thumbnailFromBuffer(Uint8List data, int targetWidth) {
    initVips();
    clearVipsError();

    final dataPtr = calloc<ffi.Uint8>(data.length);
    final outPtr = calloc<ffi.Pointer<VipsImage>>();

    try {
      // Copy data to native memory
      for (var i = 0; i < data.length; i++) {
        dataPtr[i] = data[i];
      }

      // Use custom binding with NULL terminator for variadic function
      final result = _variadicBindings.thumbnailBuffer(
        dataPtr.cast(),
        data.length,
        outPtr,
        targetWidth,
      );

      if (result != 0) {
        throw VipsException(
          'Failed to create thumbnail from buffer. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(dataPtr);
      calloc.free(outPtr);
    }
  }

  // ============ Additional Image Processing Operations ============

  /// Flip the image horizontally or vertically.
  ///
  /// [direction] determines the flip direction:
  /// - [VipsDirection.horizontal] (0): flip left-right
  /// - [VipsDirection.vertical] (1): flip top-bottom
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper flip(VipsDirection direction) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.flip(_pointer, outPtr, direction.index);

      if (result != 0) {
        throw VipsException(
          'Failed to flip image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Apply Gaussian blur to the image.
  ///
  /// [sigma] is the standard deviation of the Gaussian (larger = more blur).
  /// Typical values are 1.0 to 10.0.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper gaussianBlur(double sigma) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.gaussblur(_pointer, outPtr, sigma);

      if (result != 0) {
        throw VipsException(
          'Failed to blur image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Sharpen the image using unsharp masking.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper sharpen() {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.sharpen(_pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to sharpen image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Invert the image colors (create a negative).
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper invert() {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.invert(_pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to invert image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Flatten an image with alpha channel to RGB.
  ///
  /// The alpha channel is removed and the image is composited against
  /// a white background.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper flatten() {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.flatten(_pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to flatten image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Apply gamma correction to the image.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper gamma() {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.gamma(_pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to apply gamma. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Auto-rotate the image based on EXIF orientation tag.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper autoRotate() {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.autorot(_pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to auto-rotate image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Smart crop the image to the specified size.
  ///
  /// Uses attention-based cropping to find the most interesting part
  /// of the image.
  ///
  /// [width], [height] specify the target size.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper smartCrop(int width, int height) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.smartcrop(_pointer, outPtr, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to smart crop image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Embed the image in a larger canvas.
  ///
  /// [x], [y] specify the position of the image in the new canvas.
  /// [width], [height] specify the size of the new canvas.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper embed(int x, int y, int width, int height) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.embed(_pointer, outPtr, x, y, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to embed image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Extract an area from the image (alias for crop).
  ///
  /// [left], [top] specify the top-left corner.
  /// [width], [height] specify the size of the area.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper extractArea(int left, int top, int width, int height) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.extractArea(_pointer, outPtr, left, top, width, height);

      if (result != 0) {
        throw VipsException(
          'Failed to extract area. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Convert the image to a different colour space.
  ///
  /// [space] is the target colour space (see [VipsInterpretation]).
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper colourspace(VipsInterpretation space) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.colourspace(_pointer, outPtr, space.value);

      if (result != 0) {
        throw VipsException(
          'Failed to convert colour space. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Apply a linear transformation to the image: out = in * a + b.
  ///
  /// [a] is the multiplier (e.g., 1.2 for 20% brighter).
  /// [b] is the offset (e.g., 10 to add brightness).
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper linear(double a, double b) {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.linear1(_pointer, outPtr, a, b);

      if (result != 0) {
        throw VipsException(
          'Failed to apply linear transformation. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Adjust brightness of the image.
  ///
  /// [factor] is the brightness factor:
  /// - 1.0 = no change
  /// - > 1.0 = brighter
  /// - < 1.0 = darker
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  VipsImageWrapper brightness(double factor) {
    return linear(factor, 0);
  }

  /// Adjust contrast of the image.
  ///
  /// [factor] is the contrast factor:
  /// - 1.0 = no change
  /// - > 1.0 = more contrast
  /// - < 1.0 = less contrast
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  VipsImageWrapper contrast(double factor) {
    // Contrast adjustment: out = (in - 128) * factor + 128
    return linear(factor, 128 * (1 - factor));
  }

  /// Create a copy of the image.
  ///
  /// Returns a new [VipsImageWrapper]. Remember to dispose it when done.
  /// Throws [VipsException] if the operation fails.
  VipsImageWrapper copy() {
    _checkDisposed();
    clearVipsError();

    final outPtr = calloc<ffi.Pointer<VipsImage>>();
    try {
      final result = _variadicBindings.copy(_pointer, outPtr);

      if (result != 0) {
        throw VipsException(
          'Failed to copy image. ${getVipsError() ?? "Unknown error"}',
        );
      }

      return VipsImageWrapper._(outPtr.value);
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Release the image resources.
  ///
  /// After calling dispose, this object should not be used anymore.
  void dispose() {
    if (_disposed) return;
    _bindings.g_object_unref(_pointer.cast());
    _disposed = true;
  }

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('VipsImage has been disposed');
    }
  }
}

/// Direction for flip operations.
enum VipsDirection {
  /// Flip left-right (horizontal).
  horizontal,
  /// Flip top-bottom (vertical).
  vertical,
}

/// Colour space / interpretation.
enum VipsInterpretation {
  /// Error value.
  error(-1),
  /// Many-band image.
  multiband(0),
  /// Some kind of single-band image.
  bw(1),
  /// Histogram or lookup table.
  histogram(10),
  /// The first three bands are CIE XYZ.
  xyz(12),
  /// Pixels are in CIE Lab space.
  lab(13),
  /// The first four bands are in CMYK space.
  cmyk(15),
  /// Pixels are in CIE LCh space.
  labq(16),
  /// Pixels are sRGB.
  srgb(22),
  /// Pixels are CIE Yxy.
  yxy(23),
  /// Image is in fourier space.
  fourier(24),
  /// Generic RGB space.
  rgb(25),
  /// A generic single-channel image.
  grey16(27),
  /// A generic many-band image.
  matrix(28),
  /// Pixels are scRGB.
  scrgb(29),
  /// Pixels are HSV.
  hsv(30),
  /// Pixels are in CIE LCh space.
  lch(31),
  /// CIE CMC(l:c).
  cmc(32),
  /// Pixels are in CIE Labs space.
  labs(33),
  /// Pixels are sRGB with alpha.
  srgba(34);

  const VipsInterpretation(this.value);
  final int value;
}
