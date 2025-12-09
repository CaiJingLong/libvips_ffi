import 'package:flutter/foundation.dart';

import 'vips_image.dart';

/// Parameters for compute operations
class _ComputeParams {
  final String? filePath;
  final Uint8List? imageData;
  final Map<String, dynamic> args;

  _ComputeParams({
    this.filePath,
    this.imageData,
    required this.args,
  });
}

/// Result from compute operations
class VipsComputeResult {
  final Uint8List data;
  final int width;
  final int height;
  final int bands;

  VipsComputeResult({
    required this.data,
    required this.width,
    required this.height,
    required this.bands,
  });
}

/// High-level async API using Flutter's compute function.
/// 
/// This is simpler than the isolate-based API and suitable for
/// one-off operations. For batch processing, consider using
/// [VipsImageAsync] instead.
class VipsCompute {
  /// Load and process an image from file
  static Future<VipsComputeResult> processFile(
    String filePath,
    VipsImageWrapper Function(VipsImageWrapper) operation,
  ) async {
    return compute(_processFileIsolate, _ProcessFileParams(filePath, operation));
  }

  /// Process image data
  static Future<VipsComputeResult> processData(
    Uint8List imageData,
    VipsImageWrapper Function(VipsImageWrapper) operation,
  ) async {
    return compute(_processDataIsolate, _ProcessDataParams(imageData, operation));
  }

  // ============ Convenience methods ============

  /// Resize image from file
  static Future<VipsComputeResult> resizeFile(String filePath, double scale) {
    return compute(_resizeFile, _ComputeParams(filePath: filePath, args: {'scale': scale}));
  }

  /// Resize image from data
  static Future<VipsComputeResult> resizeData(Uint8List data, double scale) {
    return compute(_resizeData, _ComputeParams(imageData: data, args: {'scale': scale}));
  }

  /// Create thumbnail from file
  static Future<VipsComputeResult> thumbnailFile(String filePath, int width) {
    return compute(_thumbnailFile, _ComputeParams(filePath: filePath, args: {'width': width}));
  }

  /// Create thumbnail from data
  static Future<VipsComputeResult> thumbnailData(Uint8List data, int width) {
    return compute(_thumbnailData, _ComputeParams(imageData: data, args: {'width': width}));
  }

  /// Rotate image from file
  static Future<VipsComputeResult> rotateFile(String filePath, double angle) {
    return compute(_rotateFile, _ComputeParams(filePath: filePath, args: {'angle': angle}));
  }

  /// Rotate image from data
  static Future<VipsComputeResult> rotateData(Uint8List data, double angle) {
    return compute(_rotateData, _ComputeParams(imageData: data, args: {'angle': angle}));
  }

  /// Crop image from file
  static Future<VipsComputeResult> cropFile(String filePath, int left, int top, int width, int height) {
    return compute(_cropFile, _ComputeParams(filePath: filePath, args: {
      'left': left, 'top': top, 'width': width, 'height': height,
    }));
  }

  /// Crop image from data
  static Future<VipsComputeResult> cropData(Uint8List data, int left, int top, int width, int height) {
    return compute(_cropData, _ComputeParams(imageData: data, args: {
      'left': left, 'top': top, 'width': width, 'height': height,
    }));
  }

  /// Flip image from file
  static Future<VipsComputeResult> flipFile(String filePath, VipsDirection direction) {
    return compute(_flipFile, _ComputeParams(filePath: filePath, args: {'direction': direction.index}));
  }

  /// Flip image from data
  static Future<VipsComputeResult> flipData(Uint8List data, VipsDirection direction) {
    return compute(_flipData, _ComputeParams(imageData: data, args: {'direction': direction.index}));
  }

  /// Gaussian blur from file
  static Future<VipsComputeResult> blurFile(String filePath, double sigma) {
    return compute(_blurFile, _ComputeParams(filePath: filePath, args: {'sigma': sigma}));
  }

  /// Gaussian blur from data
  static Future<VipsComputeResult> blurData(Uint8List data, double sigma) {
    return compute(_blurData, _ComputeParams(imageData: data, args: {'sigma': sigma}));
  }

  /// Sharpen from file
  static Future<VipsComputeResult> sharpenFile(String filePath) {
    return compute(_sharpenFile, _ComputeParams(filePath: filePath, args: {}));
  }

  /// Sharpen from data
  static Future<VipsComputeResult> sharpenData(Uint8List data) {
    return compute(_sharpenData, _ComputeParams(imageData: data, args: {}));
  }

  /// Invert from file
  static Future<VipsComputeResult> invertFile(String filePath) {
    return compute(_invertFile, _ComputeParams(filePath: filePath, args: {}));
  }

  /// Invert from data
  static Future<VipsComputeResult> invertData(Uint8List data) {
    return compute(_invertData, _ComputeParams(imageData: data, args: {}));
  }

  /// Brightness adjustment from file
  static Future<VipsComputeResult> brightnessFile(String filePath, double factor) {
    return compute(_brightnessFile, _ComputeParams(filePath: filePath, args: {'factor': factor}));
  }

  /// Brightness adjustment from data
  static Future<VipsComputeResult> brightnessData(Uint8List data, double factor) {
    return compute(_brightnessData, _ComputeParams(imageData: data, args: {'factor': factor}));
  }

  /// Contrast adjustment from file
  static Future<VipsComputeResult> contrastFile(String filePath, double factor) {
    return compute(_contrastFile, _ComputeParams(filePath: filePath, args: {'factor': factor}));
  }

  /// Contrast adjustment from data
  static Future<VipsComputeResult> contrastData(Uint8List data, double factor) {
    return compute(_contrastData, _ComputeParams(imageData: data, args: {'factor': factor}));
  }

  /// Auto rotate from file
  static Future<VipsComputeResult> autoRotateFile(String filePath) {
    return compute(_autoRotateFile, _ComputeParams(filePath: filePath, args: {}));
  }

  /// Auto rotate from data
  static Future<VipsComputeResult> autoRotateData(Uint8List data) {
    return compute(_autoRotateData, _ComputeParams(imageData: data, args: {}));
  }
}

// ============ Isolate entry points ============

class _ProcessFileParams {
  final String filePath;
  final VipsImageWrapper Function(VipsImageWrapper) operation;
  _ProcessFileParams(this.filePath, this.operation);
}

class _ProcessDataParams {
  final Uint8List imageData;
  final VipsImageWrapper Function(VipsImageWrapper) operation;
  _ProcessDataParams(this.imageData, this.operation);
}

VipsComputeResult _processFileIsolate(_ProcessFileParams params) {
  initVips();
  final image = VipsImageWrapper.fromFile(params.filePath);
  final result = params.operation(image);
  final data = result.writeToBuffer('.png');
  final output = VipsComputeResult(
    data: data,
    width: result.width,
    height: result.height,
    bands: result.bands,
  );
  result.dispose();
  image.dispose();
  return output;
}

VipsComputeResult _processDataIsolate(_ProcessDataParams params) {
  initVips();
  final image = VipsImageWrapper.fromBuffer(params.imageData);
  final result = params.operation(image);
  final data = result.writeToBuffer('.png');
  final output = VipsComputeResult(
    data: data,
    width: result.width,
    height: result.height,
    bands: result.bands,
  );
  result.dispose();
  image.dispose();
  return output;
}

// Helper to process from file
VipsComputeResult _processFromFile(String filePath, VipsImageWrapper Function(VipsImageWrapper) op) {
  initVips();
  final image = VipsImageWrapper.fromFile(filePath);
  final result = op(image);
  final data = result.writeToBuffer('.png');
  final output = VipsComputeResult(
    data: data,
    width: result.width,
    height: result.height,
    bands: result.bands,
  );
  result.dispose();
  image.dispose();
  return output;
}

// Helper to process from data
VipsComputeResult _processFromData(Uint8List imageData, VipsImageWrapper Function(VipsImageWrapper) op) {
  initVips();
  final image = VipsImageWrapper.fromBuffer(imageData);
  final result = op(image);
  final data = result.writeToBuffer('.png');
  final output = VipsComputeResult(
    data: data,
    width: result.width,
    height: result.height,
    bands: result.bands,
  );
  result.dispose();
  image.dispose();
  return output;
}

// Specific operation isolate functions
VipsComputeResult _resizeFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.resize(p.args['scale'] as double));

VipsComputeResult _resizeData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.resize(p.args['scale'] as double));

VipsComputeResult _thumbnailFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.thumbnail(p.args['width'] as int));

VipsComputeResult _thumbnailData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.thumbnail(p.args['width'] as int));

VipsComputeResult _rotateFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.rotate(p.args['angle'] as double));

VipsComputeResult _rotateData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.rotate(p.args['angle'] as double));

VipsComputeResult _cropFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.crop(
      p.args['left'] as int,
      p.args['top'] as int,
      p.args['width'] as int,
      p.args['height'] as int,
    ));

VipsComputeResult _cropData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.crop(
      p.args['left'] as int,
      p.args['top'] as int,
      p.args['width'] as int,
      p.args['height'] as int,
    ));

VipsComputeResult _flipFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.flip(VipsDirection.values[p.args['direction'] as int]));

VipsComputeResult _flipData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.flip(VipsDirection.values[p.args['direction'] as int]));

VipsComputeResult _blurFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.gaussianBlur(p.args['sigma'] as double));

VipsComputeResult _blurData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.gaussianBlur(p.args['sigma'] as double));

VipsComputeResult _sharpenFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.sharpen());

VipsComputeResult _sharpenData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.sharpen());

VipsComputeResult _invertFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.invert());

VipsComputeResult _invertData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.invert());

VipsComputeResult _brightnessFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.brightness(p.args['factor'] as double));

VipsComputeResult _brightnessData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.brightness(p.args['factor'] as double));

VipsComputeResult _contrastFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.contrast(p.args['factor'] as double));

VipsComputeResult _contrastData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.contrast(p.args['factor'] as double));

VipsComputeResult _autoRotateFile(_ComputeParams p) =>
    _processFromFile(p.filePath!, (img) => img.autoRotate());

VipsComputeResult _autoRotateData(_ComputeParams p) =>
    _processFromData(p.imageData!, (img) => img.autoRotate());
