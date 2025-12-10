/// Direction for flip operations.
///
/// 翻转操作的方向。
enum VipsDirection {
  /// Flip left-right (horizontal).
  ///
  /// 左右翻转（水平）。
  horizontal,

  /// Flip top-bottom (vertical).
  ///
  /// 上下翻转（垂直）。
  vertical,
}

/// Colour space / interpretation.
///
/// 色彩空间 / 解释。
///
/// This enum represents the various colour spaces and interpretations
/// that libvips supports for image processing.
/// 此枚举表示 libvips 支持的各种色彩空间和图像处理解释。
enum VipsInterpretation {
  /// Error value. / 错误值。
  error(-1),

  /// Many-band image. / 多通道图像。
  multiband(0),

  /// Some kind of single-band image. / 某种单通道图像。
  bw(1),

  /// Histogram or lookup table. / 直方图或查找表。
  histogram(10),

  /// The first three bands are CIE XYZ. / 前三个通道是 CIE XYZ。
  xyz(12),

  /// Pixels are in CIE Lab space. / 像素在 CIE Lab 空间中。
  lab(13),

  /// The first four bands are in CMYK space. / 前四个通道在 CMYK 空间中。
  cmyk(15),

  /// Pixels are CIE LCh space. / 像素在 CIE LCh 空间中。
  labq(16),

  /// Pixels are sRGB. / 像素是 sRGB。
  srgb(22),

  /// Pixels are CIE Yxy. / 像素是 CIE Yxy。
  yxy(23),

  /// Image is in fourier space. / 图像在傅里叶空间中。
  fourier(24),

  /// Generic RGB space. / 通用 RGB 空间。
  rgb(25),

  /// A generic single-channel image. / 通用单通道图像。
  grey16(27),

  /// A generic many-band image. / 通用多通道图像。
  matrix(28),

  /// Pixels are scRGB. / 像素是 scRGB。
  scrgb(29),

  /// Pixels are HSV. / 像素是 HSV。
  hsv(30),

  /// Pixels are in CIE LCh space. / 像素在 CIE LCh 空间中。
  lch(31),

  /// CIE CMC(l:c). / CIE CMC(l:c)。
  cmc(32),

  /// Pixels are in CIE Labs space. / 像素在 CIE Labs 空间中。
  labs(33),

  /// Pixels are sRGB with alpha. / 像素是带 alpha 的 sRGB。
  srgba(34);

  /// Creates a [VipsInterpretation] with the given [value].
  ///
  /// 使用给定的 [value] 创建 [VipsInterpretation]。
  const VipsInterpretation(this.value);

  /// The integer value of this interpretation.
  ///
  /// 此解释的整数值。
  final int value;
}
