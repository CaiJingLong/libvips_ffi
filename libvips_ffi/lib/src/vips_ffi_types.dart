import 'dart:ffi' as ffi;

import 'bindings/vips_bindings_generated.dart';

// Custom function types for variadic functions that need NULL termination.
// 需要 NULL 终止的可变参数函数的自定义函数类型。

typedef VipsImageNewFromFileNative = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef VipsImageNewFromFileDart = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsImageWriteToFileNative = ffi.Int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef VipsImageWriteToFileDart = int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> name,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsImageWriteToBufferNative = ffi.Int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> suffix,
  ffi.Pointer<ffi.Pointer<ffi.Void>> buf,
  ffi.Pointer<ffi.Size> size,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef VipsImageWriteToBufferDart = int Function(
  ffi.Pointer<VipsImage> image,
  ffi.Pointer<ffi.Char> suffix,
  ffi.Pointer<ffi.Pointer<ffi.Void>> buf,
  ffi.Pointer<ffi.Size> size,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsImageNewFromBufferNative = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Void> buf,
  ffi.Size len,
  ffi.Pointer<ffi.Char> optionString,
  ffi.Pointer<ffi.Void> terminator, // NULL terminator
);
typedef VipsImageNewFromBufferDart = ffi.Pointer<VipsImage> Function(
  ffi.Pointer<ffi.Void> buf,
  int len,
  ffi.Pointer<ffi.Char> optionString,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsResizeNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double scale,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsResizeDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double scale,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsRotateNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double angle,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsRotateDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double angle,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsCropNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int left,
  ffi.Int top,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsCropDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int left,
  int top,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsThumbnailImageNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsThumbnailImageDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsThumbnailNative = ffi.Int Function(
  ffi.Pointer<ffi.Char> filename,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsThumbnailDart = int Function(
  ffi.Pointer<ffi.Char> filename,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsThumbnailBufferNative = ffi.Int Function(
  ffi.Pointer<ffi.Void> buf,
  ffi.Size len,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsThumbnailBufferDart = int Function(
  ffi.Pointer<ffi.Void> buf,
  int len,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsFlipNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int direction,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsFlipDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int direction,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsGaussblurNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double sigma,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsGaussblurDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double sigma,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsSharpenNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsSharpenDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsInvertNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsInvertDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsFlattenNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsFlattenDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsGammaNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsGammaDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsAutorotNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsAutorotDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsSmartcropNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsSmartcropDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsGravityNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int direction,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsGravityDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int direction,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsEmbedNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int x,
  ffi.Int y,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsEmbedDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int x,
  int y,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsExtractAreaNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int left,
  ffi.Int top,
  ffi.Int width,
  ffi.Int height,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsExtractAreaDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int left,
  int top,
  int width,
  int height,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsColourspaceNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int space,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsColourspaceDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int space,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsCastNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Int format,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsCastDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  int format,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsCopyNative = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsCopyDart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Pointer<ffi.Void> terminator,
);

typedef VipsLinear1Native = ffi.Int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  ffi.Double a,
  ffi.Double b,
  ffi.Pointer<ffi.Void> terminator,
);
typedef VipsLinear1Dart = int Function(
  ffi.Pointer<VipsImage> in1,
  ffi.Pointer<ffi.Pointer<VipsImage>> out,
  double a,
  double b,
  ffi.Pointer<ffi.Void> terminator,
);
