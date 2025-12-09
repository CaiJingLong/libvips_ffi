import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'vips_image.dart';

/// Message types for isolate communication
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

/// Request message for isolate
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

/// Response message from isolate
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

/// Image data that can be passed between isolates
class VipsImageData {
  final Uint8List data;
  final int width;
  final int height;
  final int bands;

  VipsImageData({
    required this.data,
    required this.width,
    required this.height,
    required this.bands,
  });
}

/// Async wrapper for VipsImageWrapper that runs operations in an isolate
class VipsImageAsync {
  static SendPort? _isolateSendPort;
  static Isolate? _isolate;
  static bool _initialized = false;

  /// Initialize the isolate worker
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    _isolateSendPort = await receivePort.first as SendPort;
    _initialized = true;
  }

  /// Shutdown the isolate worker
  static void shutdown() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isolateSendPort = null;
    _initialized = false;
  }

  /// Entry point for the isolate
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

  /// Handle a request in the isolate
  static void _handleRequest(_IsolateRequest request) {
    try {
      final result = _processRequest(request);
      request.responsePort.send(_IsolateResponse.success(result));
    } catch (e) {
      request.responsePort.send(_IsolateResponse.error(e.toString()));
    }
  }

  /// Process a request and return the result
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

  /// Helper to process an image operation
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

  /// Send a request to the isolate and wait for response
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

  /// Load an image from a file asynchronously
  static Future<VipsImageData> loadFromFile(String path) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.loadFromFile,
      {'path': path},
    );
  }

  /// Load an image from a buffer asynchronously
  static Future<VipsImageData> loadFromBuffer(Uint8List data, {String optionString = ''}) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.loadFromBuffer,
      {'data': data, 'optionString': optionString},
    );
  }

  /// Resize an image asynchronously
  static Future<VipsImageData> resize(Uint8List imageData, double scale) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.resize,
      {'imageData': imageData, 'scale': scale},
    );
  }

  /// Create a thumbnail asynchronously
  static Future<VipsImageData> thumbnail(Uint8List imageData, int width) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.thumbnail,
      {'imageData': imageData, 'width': width},
    );
  }

  /// Create a thumbnail from file asynchronously
  static Future<VipsImageData> thumbnailFromFile(String path, int width) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.thumbnailFromFile,
      {'path': path, 'width': width},
    );
  }

  /// Create a thumbnail from buffer asynchronously
  static Future<VipsImageData> thumbnailFromBuffer(Uint8List data, int width) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.thumbnailFromBuffer,
      {'data': data, 'width': width},
    );
  }

  /// Rotate an image asynchronously
  static Future<VipsImageData> rotate(Uint8List imageData, double angle) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.rotate,
      {'imageData': imageData, 'angle': angle},
    );
  }

  /// Crop an image asynchronously
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

  /// Flip an image asynchronously
  static Future<VipsImageData> flip(Uint8List imageData, VipsDirection direction) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.flip,
      {'imageData': imageData, 'direction': direction.index},
    );
  }

  /// Apply Gaussian blur asynchronously
  static Future<VipsImageData> gaussianBlur(Uint8List imageData, double sigma) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.gaussianBlur,
      {'imageData': imageData, 'sigma': sigma},
    );
  }

  /// Sharpen an image asynchronously
  static Future<VipsImageData> sharpen(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.sharpen,
      {'imageData': imageData},
    );
  }

  /// Invert an image asynchronously
  static Future<VipsImageData> invert(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.invert,
      {'imageData': imageData},
    );
  }

  /// Flatten an image asynchronously
  static Future<VipsImageData> flatten(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.flatten,
      {'imageData': imageData},
    );
  }

  /// Apply gamma correction asynchronously
  static Future<VipsImageData> gamma(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.gamma,
      {'imageData': imageData},
    );
  }

  /// Auto-rotate an image asynchronously
  static Future<VipsImageData> autoRotate(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.autoRotate,
      {'imageData': imageData},
    );
  }

  /// Smart crop an image asynchronously
  static Future<VipsImageData> smartCrop(Uint8List imageData, int width, int height) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.smartCrop,
      {'imageData': imageData, 'width': width, 'height': height},
    );
  }

  /// Embed an image asynchronously
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

  /// Extract an area asynchronously
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

  /// Convert colour space asynchronously
  static Future<VipsImageData> colourspace(Uint8List imageData, VipsInterpretation space) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.colourspace,
      {'imageData': imageData, 'space': space.value},
    );
  }

  /// Apply linear transformation asynchronously
  static Future<VipsImageData> linear(Uint8List imageData, double a, double b) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.linear,
      {'imageData': imageData, 'a': a, 'b': b},
    );
  }

  /// Adjust brightness asynchronously
  static Future<VipsImageData> brightness(Uint8List imageData, double factor) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.brightness,
      {'imageData': imageData, 'factor': factor},
    );
  }

  /// Adjust contrast asynchronously
  static Future<VipsImageData> contrast(Uint8List imageData, double factor) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.contrast,
      {'imageData': imageData, 'factor': factor},
    );
  }

  /// Copy an image asynchronously
  static Future<VipsImageData> copy(Uint8List imageData) async {
    return _sendRequest<VipsImageData>(
      _IsolateMessageType.copy,
      {'imageData': imageData},
    );
  }

  /// Write to buffer asynchronously
  static Future<Uint8List> writeToBuffer(Uint8List imageData, String suffix) async {
    return _sendRequest<Uint8List>(
      _IsolateMessageType.writeToBuffer,
      {'imageData': imageData, 'suffix': suffix},
    );
  }

  /// Write to file asynchronously
  static Future<void> writeToFile(Uint8List imageData, String path) async {
    await _sendRequest<void>(
      _IsolateMessageType.writeToFile,
      {'imageData': imageData, 'path': path},
    );
  }
}
