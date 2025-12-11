import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

import 'mobile_loader.dart';

/// Message types for isolate communication.
///
/// isolate 通信的消息类型。
enum _IsolateMessageType {
  loadFromFile,
  loadFromBuffer,
  resize,
  thumbnail,
  thumbnailFromFile,
  thumbnailFromBuffer,
  rotate,
  crop,
  flip,
  gaussianBlur,
  sharpen,
  invert,
  flatten,
  gamma,
  autoRotate,
  smartCrop,
  embed,
  extractArea,
  colourspace,
  linear,
  brightness,
  contrast,
  copy,
  writeToBuffer,
  writeToFile,
}

/// Request message for isolate.
///
/// isolate 的请求消息。
class _IsolateRequest {
  final _IsolateMessageType type;
  final SendPort responsePort;
  final Map<String, dynamic> params;

  _IsolateRequest({
    required this.type,
    required this.responsePort,
    required this.params,
  });
}

/// Response message from isolate.
///
/// 来自 isolate 的响应消息。
class _IsolateResponse {
  final bool success;
  final dynamic result;
  final String? error;

  _IsolateResponse.success(this.result)
      : success = true,
        error = null;

  _IsolateResponse.error(this.error)
      : success = false,
        result = null;
}

/// Image data that can be passed between isolates.
///
/// 可以在 isolate 之间传递的图像数据。
///
/// This class holds the processed image data along with its dimensions,
/// allowing safe transfer between isolates.
/// 此类保存处理后的图像数据及其尺寸，允许在 isolate 之间安全传输。
class VipsImageData {
  /// The image data in PNG format.
  ///
  /// PNG 格式的图像数据。
  final Uint8List data;

  /// The width of the image in pixels.
  ///
  /// 图像的宽度（像素）。
  final int width;

  /// The height of the image in pixels.
  ///
  /// 图像的高度（像素）。
  final int height;

  /// The number of bands (channels) in the image.
  ///
  /// 图像的通道数。
  final int bands;

  /// Creates a [VipsImageData] with the given parameters.
  ///
  /// 使用给定的参数创建 [VipsImageData]。
  VipsImageData({
    required this.data,
    required this.width,
    required this.height,
    required this.bands,
  });
}

/// Async wrapper for VipsImageWrapper that runs operations in an isolate.
///
/// 在 isolate 中运行操作的 VipsImageWrapper 异步封装。
///
/// This class provides an async API for image processing operations that
/// run in a background isolate, keeping the main UI thread responsive.
/// 此类提供了在后台 isolate 中运行的图像处理操作的异步 API，
/// 保持主 UI 线程的响应性。
///
/// The isolate is automatically initialized on first use and can be
/// shut down with [shutdown].
/// isolate 在首次使用时自动初始化，可以通过 [shutdown] 关闭。
///
/// ## Example / 示例
///
/// ```dart
/// // Load and resize an image
/// final imageData = await VipsImageAsync.loadFromFile('input.jpg');
/// final resized = await VipsImageAsync.resize(imageData.data, 0.5);
/// print('Resized to ${resized.width}x${resized.height}');
///
/// // Don't forget to shutdown when done
/// VipsImageAsync.shutdown();
/// ```
class VipsImageAsync {
  static SendPort? _isolateSendPort;
  static Isolate? _isolate;
  static bool _initialized = false;

  /// Initializes the isolate worker.
  ///
  /// 初始化 isolate 工作器。
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    _isolateSendPort = await receivePort.first as SendPort;
    _initialized = true;
  }

  /// Shuts down the isolate worker.
  ///
  /// 关闭 isolate 工作器。
  ///
  /// Call this when you're done using the async API to free resources.
  /// 当你完成异步 API 的使用时调用此方法以释放资源。
  static void shutdown() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isolateSendPort = null;
    _initialized = false;
  }

  /// Entry point for the isolate.
  ///
  /// isolate 的入口点。
  static void _isolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    // Initialize vips in the isolate
    initVips();

    receivePort.listen((message) {
      if (message is _IsolateRequest) {
        _handleRequest(message);
      }
    });
  }

  /// Handles a request in the isolate.
  ///
  /// 在 isolate 中处理请求。
  static void _handleRequest(_IsolateRequest request) {
    try {
      final result = _processRequest(request);
      request.responsePort.send(_IsolateResponse.success(result));
    } catch (e) {
      request.responsePort.send(_IsolateResponse.error(e.toString()));
    }
  }

  /// Processes a request and returns the result.
  ///
  /// 处理请求并返回结果。
  static dynamic _processRequest(_IsolateRequest request) {
    final params = request.params;

    switch (request.type) {
      case _IsolateMessageType.loadFromFile:
        final image = VipsImageWrapper.fromFile(params['path'] as String);
        final data = image.writeToBuffer('.png');
        final result = VipsImageData(
          data: data,
          width: image.width,
          height: image.height,
          bands: image.bands,
        );
        image.dispose();
        return result;

      case _IsolateMessageType.loadFromBuffer:
        final image = VipsImageWrapper.fromBuffer(
          params['data'] as Uint8List,
          optionString: params['optionString'] as String? ?? '',
        );
        final data = image.writeToBuffer('.png');
        final result = VipsImageData(
          data: data,
          width: image.width,
          height: image.height,
          bands: image.bands,
        );
        image.dispose();
        return result;

      case _IsolateMessageType.resize:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.resize(params['scale'] as double),
        );

      case _IsolateMessageType.thumbnail:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.thumbnail(params['width'] as int),
        );

      case _IsolateMessageType.thumbnailFromFile:
        final image = VipsImageWrapper.thumbnailFromFile(
          params['path'] as String,
          params['width'] as int,
        );
        final data = image.writeToBuffer('.png');
        final result = VipsImageData(
          data: data,
          width: image.width,
          height: image.height,
          bands: image.bands,
        );
        image.dispose();
        return result;

      case _IsolateMessageType.thumbnailFromBuffer:
        final image = VipsImageWrapper.thumbnailFromBuffer(
          params['data'] as Uint8List,
          params['width'] as int,
        );
        final data = image.writeToBuffer('.png');
        final result = VipsImageData(
          data: data,
          width: image.width,
          height: image.height,
          bands: image.bands,
        );
        image.dispose();
        return result;

      case _IsolateMessageType.rotate:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.rotate(params['angle'] as double),
        );

      case _IsolateMessageType.crop:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.crop(
            params['left'] as int,
            params['top'] as int,
            params['width'] as int,
            params['height'] as int,
          ),
        );

      case _IsolateMessageType.flip:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.flip(VipsDirection.values[params['direction'] as int]),
        );

      case _IsolateMessageType.gaussianBlur:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.gaussianBlur(params['sigma'] as double),
        );

      case _IsolateMessageType.sharpen:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.sharpen(),
        );

      case _IsolateMessageType.invert:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.invert(),
        );

      case _IsolateMessageType.flatten:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.flatten(),
        );

      case _IsolateMessageType.gamma:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.gamma(),
        );

      case _IsolateMessageType.autoRotate:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.autoRotate(),
        );

      case _IsolateMessageType.smartCrop:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.smartCrop(
            params['width'] as int,
            params['height'] as int,
          ),
        );

      case _IsolateMessageType.embed:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.embed(
            params['x'] as int,
            params['y'] as int,
            params['width'] as int,
            params['height'] as int,
          ),
        );

      case _IsolateMessageType.extractArea:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.extractArea(
            params['left'] as int,
            params['top'] as int,
            params['width'] as int,
            params['height'] as int,
          ),
        );

      case _IsolateMessageType.colourspace:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.colourspace(
            VipsInterpretation.values.firstWhere(
              (e) => e.value == params['space'],
            ),
          ),
        );

      case _IsolateMessageType.linear:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.linear(
            params['a'] as double,
            params['b'] as double,
          ),
        );

      case _IsolateMessageType.brightness:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.brightness(params['factor'] as double),
        );

      case _IsolateMessageType.contrast:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.contrast(params['factor'] as double),
        );

      case _IsolateMessageType.copy:
        return _processImageOperation(
          params['imageData'] as Uint8List,
          (image) => image.copy(),
        );

      case _IsolateMessageType.writeToBuffer:
        final image = VipsImageWrapper.fromBuffer(params['imageData'] as Uint8List);
        final data = image.writeToBuffer(params['suffix'] as String);
        image.dispose();
        return data;

      case _IsolateMessageType.writeToFile:
        final image = VipsImageWrapper.fromBuffer(params['imageData'] as Uint8List);
        image.writeToFile(params['path'] as String);
        image.dispose();
        return null;
    }
  }

  /// Helper to process an image operation.
  ///
  /// 处理图像操作的辅助方法。
  static VipsImageData _processImageOperation(
    Uint8List imageData,
    VipsImageWrapper Function(VipsImageWrapper) operation,
  ) {
    final image = VipsImageWrapper.fromBuffer(imageData);
    final result = operation(image);
    final data = result.writeToBuffer('.png');
    final imageResult = VipsImageData(
      data: data,
      width: result.width,
      height: result.height,
      bands: result.bands,
    );
    result.dispose();
    image.dispose();
    return imageResult;
  }

  /// Sends a request to the isolate and waits for response.
  ///
  /// 向 isolate 发送请求并等待响应。
  static Future<T> _sendRequest<T>(_IsolateMessageType type, Map<String, dynamic> params) async {
    await _ensureInitialized();

    final responsePort = ReceivePort();
    _isolateSendPort!.send(_IsolateRequest(
      type: type,
      responsePort: responsePort.sendPort,
      params: params,
    ));

    final response = await responsePort.first as _IsolateResponse;
    responsePort.close();

    if (response.success) {
      return response.result as T;
    } else {
      throw VipsException(response.error ?? 'Unknown error');
    }
  }

  // ============ Public API ============
  // ============ 公共 API ============

  /// Loads an image from a file asynchronously.
  ///
  /// 异步从文件加载图像。
  ///
  /// [path] is the path to the image file.
  /// [path] 是图像文件的路径。
  static Future<VipsImageData> loadFromFile(String path) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.loadFromFile,
      {'path': path},
    );
  }

  /// Loads an image from a buffer asynchronously.
  ///
  /// 异步从缓冲区加载图像。
  ///
  /// [data] is the image data. / [data] 是图像数据。
  /// [optionString] can specify format options. / [optionString] 可以指定格式选项。
  static Future<VipsImageData> loadFromBuffer(Uint8List data, {String optionString = ''}) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.loadFromBuffer,
      {'data': data, 'optionString': optionString},
    );
  }

  /// Resizes an image asynchronously.
  ///
  /// 异步调整图像大小。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [scale] is the resize factor. / [scale] 是调整大小的因子。
  static Future<VipsImageData> resize(Uint8List imageData, double scale) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.resize,
      {'imageData': imageData, 'scale': scale},
    );
  }

  /// Creates a thumbnail asynchronously.
  ///
  /// 异步创建缩略图。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [width] is the target width in pixels. / [width] 是目标宽度（像素）。
  static Future<VipsImageData> thumbnail(Uint8List imageData, int width) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.thumbnail,
      {'imageData': imageData, 'width': width},
    );
  }

  /// Creates a thumbnail from file asynchronously.
  ///
  /// 异步从文件创建缩略图。
  ///
  /// [path] is the path to the image file. / [path] 是图像文件的路径。
  /// [width] is the target width in pixels. / [width] 是目标宽度（像素）。
  static Future<VipsImageData> thumbnailFromFile(String path, int width) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.thumbnailFromFile,
      {'path': path, 'width': width},
    );
  }

  /// Creates a thumbnail from buffer asynchronously.
  ///
  /// 异步从缓冲区创建缩略图。
  ///
  /// [data] is the image data. / [data] 是图像数据。
  /// [width] is the target width in pixels. / [width] 是目标宽度（像素）。
  static Future<VipsImageData> thumbnailFromBuffer(Uint8List data, int width) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.thumbnailFromBuffer,
      {'data': data, 'width': width},
    );
  }

  /// Rotates an image asynchronously.
  ///
  /// 异步旋转图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [angle] is the rotation angle in degrees. / [angle] 是旋转角度（度数）。
  static Future<VipsImageData> rotate(Uint8List imageData, double angle) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.rotate,
      {'imageData': imageData, 'angle': angle},
    );
  }

  /// Crops an image asynchronously.
  ///
  /// 异步裁剪图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [left], [top] specify the top-left corner. / [left]、[top] 指定左上角。
  /// [width], [height] specify the crop size. / [width]、[height] 指定裁剪大小。
  static Future<VipsImageData> crop(
    Uint8List imageData,
    int left,
    int top,
    int width,
    int height,
  ) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.crop,
      {
        'imageData': imageData,
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      },
    );
  }

  /// Flips an image asynchronously.
  ///
  /// 异步翻转图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [direction] is the flip direction. / [direction] 是翻转方向。
  static Future<VipsImageData> flip(Uint8List imageData, VipsDirection direction) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.flip,
      {'imageData': imageData, 'direction': direction.index},
    );
  }

  /// Applies Gaussian blur asynchronously.
  ///
  /// 异步应用高斯模糊。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [sigma] is the blur amount. / [sigma] 是模糊程度。
  static Future<VipsImageData> gaussianBlur(Uint8List imageData, double sigma) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.gaussianBlur,
      {'imageData': imageData, 'sigma': sigma},
    );
  }

  /// Sharpens an image asynchronously.
  ///
  /// 异步锐化图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  static Future<VipsImageData> sharpen(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.sharpen,
      {'imageData': imageData},
    );
  }

  /// Inverts an image asynchronously.
  ///
  /// 异步反转图像颜色。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  static Future<VipsImageData> invert(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.invert,
      {'imageData': imageData},
    );
  }

  /// Flattens an image asynchronously.
  ///
  /// 异步平坦化图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  static Future<VipsImageData> flatten(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.flatten,
      {'imageData': imageData},
    );
  }

  /// Applies gamma correction asynchronously.
  ///
  /// 异步应用伽马校正。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  static Future<VipsImageData> gamma(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.gamma,
      {'imageData': imageData},
    );
  }

  /// Auto-rotates an image asynchronously based on EXIF orientation.
  ///
  /// 根据 EXIF 方向异步自动旋转图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  static Future<VipsImageData> autoRotate(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.autoRotate,
      {'imageData': imageData},
    );
  }

  /// Smart crops an image asynchronously.
  ///
  /// 异步智能裁剪图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [width], [height] specify the target size. / [width]、[height] 指定目标大小。
  static Future<VipsImageData> smartCrop(Uint8List imageData, int width, int height) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.smartCrop,
      {'imageData': imageData, 'width': width, 'height': height},
    );
  }

  /// Embeds an image asynchronously.
  ///
  /// 异步嵌入图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [x], [y] specify the position. / [x]、[y] 指定位置。
  /// [width], [height] specify the canvas size. / [width]、[height] 指定画布大小。
  static Future<VipsImageData> embed(
    Uint8List imageData,
    int x,
    int y,
    int width,
    int height,
  ) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.embed,
      {
        'imageData': imageData,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      },
    );
  }

  /// Extracts an area asynchronously.
  ///
  /// 异步提取区域。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [left], [top] specify the top-left corner. / [left]、[top] 指定左上角。
  /// [width], [height] specify the area size. / [width]、[height] 指定区域大小。
  static Future<VipsImageData> extractArea(
    Uint8List imageData,
    int left,
    int top,
    int width,
    int height,
  ) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.extractArea,
      {
        'imageData': imageData,
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      },
    );
  }

  /// Converts colour space asynchronously.
  ///
  /// 异步转换色彩空间。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [space] is the target colour space. / [space] 是目标色彩空间。
  static Future<VipsImageData> colourspace(Uint8List imageData, VipsInterpretation space) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.colourspace,
      {'imageData': imageData, 'space': space.value},
    );
  }

  /// Applies linear transformation asynchronously.
  ///
  /// 异步应用线性变换。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [a] is the multiplier. / [a] 是乘数。
  /// [b] is the offset. / [b] 是偏移量。
  static Future<VipsImageData> linear(Uint8List imageData, double a, double b) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.linear,
      {'imageData': imageData, 'a': a, 'b': b},
    );
  }

  /// Adjusts brightness asynchronously.
  ///
  /// 异步调整亮度。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [factor] is the brightness factor (1.0 = no change). / [factor] 是亮度因子（1.0 = 无变化）。
  static Future<VipsImageData> brightness(Uint8List imageData, double factor) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.brightness,
      {'imageData': imageData, 'factor': factor},
    );
  }

  /// Adjusts contrast asynchronously.
  ///
  /// 异步调整对比度。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [factor] is the contrast factor (1.0 = no change). / [factor] 是对比度因子（1.0 = 无变化）。
  static Future<VipsImageData> contrast(Uint8List imageData, double factor) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.contrast,
      {'imageData': imageData, 'factor': factor},
    );
  }

  /// Copies an image asynchronously.
  ///
  /// 异步复制图像。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  static Future<VipsImageData> copy(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.copy,
      {'imageData': imageData},
    );
  }

  /// Writes to buffer asynchronously.
  ///
  /// 异步写入缓冲区。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [suffix] determines the format (e.g., '.jpg'). / [suffix] 决定格式（例如 '.jpg'）。
  static Future<Uint8List> writeToBuffer(Uint8List imageData, String suffix) async {
    return _sendRequest<Uint8List>(
      _IsolateMessageType.writeToBuffer,
      {'imageData': imageData, 'suffix': suffix},
    );
  }

  /// Writes to file asynchronously.
  ///
  /// 异步写入文件。
  ///
  /// [imageData] is the image data. / [imageData] 是图像数据。
  /// [path] is the path to write to. / [path] 是要写入的路径。
  static Future<void> writeToFile(Uint8List imageData, String path) async {
    await _sendRequest<void>(
      _IsolateMessageType.writeToFile,
      {'imageData': imageData, 'path': path},
    );
  }
}
