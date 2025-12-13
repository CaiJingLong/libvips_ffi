import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:libvips_ffi/libvips_ffi.dart';
import 'package:path_provider/path_provider.dart';

/// Test result callback
typedef TestResultCallback = void Function(String result, Uint8List? imageData);

/// Log callback
typedef LogCallback = void Function(String message);

/// Async test operation type (takes image data)
typedef AsyncTestOperation = Future<VipsImageData> Function(Uint8List imageData);

/// Compute test operation type (takes file path, more efficient)
typedef ComputeTestOperation = Future<VipsComputeResult> Function(String filePath);

/// Vips test runner using async API (runs in isolate)
class VipsTestRunner {
  final LogCallback? onLog;

  VipsTestRunner({this.onLog});

  void _log(String message) {
    onLog?.call(message);
  }

  /// Gets the current pointer leak report.
  ///
  /// 获取当前指针泄漏报告。
  String getLeakReport() {
    return VipsPointerManager.instance.getLeakReport();
  }

  /// Gets the number of active (potentially leaked) pointers.
  ///
  /// 获取活跃（可能泄漏）的指针数量。
  int get activePointerCount => VipsPointerManager.instance.activeCount;

  /// Whether there are any potential memory leaks.
  ///
  /// 是否有任何潜在的内存泄漏。
  bool get hasLeaks => VipsPointerManager.instance.hasLeaks;

  /// Enables stack trace tracking for leak debugging.
  ///
  /// 启用堆栈跟踪以进行泄漏调试。
  void enableStackTraceTracking() {
    VipsPointerManager.instance.trackStackTraces = true;
  }

  /// Disables stack trace tracking.
  ///
  /// 禁用堆栈跟踪。
  void disableStackTraceTracking() {
    VipsPointerManager.instance.trackStackTraces = false;
  }

  /// Forces disposal of all active pointers (emergency cleanup).
  ///
  /// 强制释放所有活跃指针（紧急清理）。
  ///
  /// Returns the number of pointers that were disposed.
  /// 返回已释放的指针数量。
  int forceDisposeAll() {
    _log('WARNING: Force disposing all active pointers!');
    final count = VipsPointerManager.instance.forceDisposeAll();
    _log('Disposed $count pointers');
    return count;
  }

  /// Resets the pointer manager state.
  ///
  /// 重置指针管理器状态。
  void resetPointerManager() {
    VipsPointerManager.instance.reset();
  }

  /// Gets pointer usage statistics.
  ///
  /// 获取指针使用统计信息。
  Map<String, dynamic> getPointerStatistics() {
    return VipsPointerManager.instance.getStatistics();
  }

  /// Run all tests using async API
  Future<(String, Uint8List?)> runAllTests(String imagePath) async {
    _log('=== Running All Tests (Async) ===');
    _log('Image path: $imagePath');

    final result = StringBuffer();
    final stopwatch = Stopwatch()..start();

    // Load the image
    _log('Loading image...');
    final image = await VipsImageAsync.loadFromFile(imagePath);
    _log('Image loaded: ${image.width}x${image.height}, ${image.bands} bands');
    result.writeln(
        '✓ Image loaded: ${image.width}x${image.height}, ${image.bands} bands');

    // Test resize
    _log('Testing resize...');
    final resized = await VipsImageAsync.resize(image.data, 0.5);
    _log('Resize result: ${resized.width}x${resized.height}');
    result.writeln('✓ Resize (0.5x): ${resized.width}x${resized.height}');

    // Test thumbnail
    _log('Testing thumbnail...');
    final thumb = await VipsImageAsync.thumbnail(image.data, 200);
    _log('Thumbnail result: ${thumb.width}x${thumb.height}');
    result.writeln('✓ Thumbnail (200px): ${thumb.width}x${thumb.height}');

    // Test rotate
    _log('Testing rotate...');
    final rotated = await VipsImageAsync.rotate(image.data, 45);
    _log('Rotate result: ${rotated.width}x${rotated.height}');
    result.writeln('✓ Rotate (45°): ${rotated.width}x${rotated.height}');

    // Test crop (if image is large enough)
    if (image.width >= 100 && image.height >= 100) {
      _log('Testing crop...');
      final cropped = await VipsImageAsync.crop(image.data, 0, 0, 100, 100);
      _log('Crop result: ${cropped.width}x${cropped.height}');
      result.writeln('✓ Crop (100x100): ${cropped.width}x${cropped.height}');
    }

    // Test flip
    _log('Testing flip...');
    final flipped = await VipsImageAsync.flip(image.data, VipsDirection.horizontal);
    _log('Flip result: ${flipped.width}x${flipped.height}');
    result.writeln('✓ Flip horizontal: ${flipped.width}x${flipped.height}');

    // Test blur
    _log('Testing blur...');
    final blurred = await VipsImageAsync.gaussianBlur(thumb.data, 3.0);
    _log('Blur result: ${blurred.width}x${blurred.height}');
    result.writeln('✓ Gaussian blur (σ=3): ${blurred.width}x${blurred.height}');

    // Test sharpen
    _log('Testing sharpen...');
    final sharpened = await VipsImageAsync.sharpen(thumb.data);
    _log('Sharpen result: ${sharpened.width}x${sharpened.height}');
    result.writeln('✓ Sharpen: ${sharpened.width}x${sharpened.height}');

    // Test invert
    _log('Testing invert...');
    final inverted = await VipsImageAsync.invert(thumb.data);
    _log('Invert result: ${inverted.width}x${inverted.height}');
    result.writeln('✓ Invert: ${inverted.width}x${inverted.height}');

    // Test brightness
    _log('Testing brightness...');
    final brighter = await VipsImageAsync.brightness(thumb.data, 1.2);
    _log('Brightness result: ${brighter.width}x${brighter.height}');
    result.writeln('✓ Brightness +20%: ${brighter.width}x${brighter.height}');

    // Test contrast
    _log('Testing contrast...');
    final contrasted = await VipsImageAsync.contrast(thumb.data, 1.3);
    _log('Contrast result: ${contrasted.width}x${contrasted.height}');
    result.writeln('✓ Contrast +30%: ${contrasted.width}x${contrasted.height}');

    // Test auto rotate
    _log('Testing auto rotate...');
    final autoRotated = await VipsImageAsync.autoRotate(image.data);
    _log('Auto rotate result: ${autoRotated.width}x${autoRotated.height}');
    result.writeln('✓ Auto rotate: ${autoRotated.width}x${autoRotated.height}');

    // Test write to buffer (JPEG)
    _log('Testing writeToBuffer (JPEG)...');
    final jpegData = await VipsImageAsync.writeToBuffer(image.data, '.jpg');
    _log('JPEG buffer size: ${jpegData.length} bytes');
    result.writeln(
        '✓ Write to JPEG: ${(jpegData.length / 1024).toStringAsFixed(1)} KB');

    // Test write to file
    _log('Testing writeToFile...');
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/vips_output.jpg';
    _log('Output path: $outputPath');
    await VipsImageAsync.writeToFile(image.data, outputPath);
    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      final size = await outputFile.length();
      _log('File written: $size bytes');
      result.writeln(
          '✓ Write to file: ${(size / 1024).toStringAsFixed(1)} KB');
    }

    stopwatch.stop();
    _log('All tests completed in ${stopwatch.elapsedMilliseconds}ms');
    result.writeln('\n✓ All tests passed in ${stopwatch.elapsedMilliseconds}ms!');

    return (result.toString(), thumb.data);
  }

  /// Run a single test using async API
  Future<(String, Uint8List?)> runSingleTestAsync(
    String imagePath,
    String name,
    AsyncTestOperation operation,
  ) async {
    _log('=== Running $name Test (Async) ===');
    _log('Image path: $imagePath');

    final stopwatch = Stopwatch()..start();

    _log('Loading image...');
    _log('Checking if file exists...');
    final file = File(imagePath);
    final exists = await file.exists();
    _log('File exists: $exists');
    if (exists) {
      final fileSize = await file.length();
      _log('File size: $fileSize bytes');
    }
    
    final image = await VipsImageAsync.loadFromFile(imagePath);
    _log('Image loaded: ${image.width}x${image.height}');

    _log('Executing $name operation...');
    final result = await operation(image.data);
    _log('Operation result: ${result.width}x${result.height}');

    stopwatch.stop();
    _log('$name completed in ${stopwatch.elapsedMilliseconds}ms');

    final resultText = '✓ $name completed in ${stopwatch.elapsedMilliseconds}ms\n'
        '  Input: ${image.width}x${image.height}\n'
        '  Output: ${result.width}x${result.height}\n'
        '  Size: ${(result.data.length / 1024).toStringAsFixed(1)} KB';

    return (resultText, result.data);
  }

  /// Run a single test using VipsCompute (more efficient, loads from file directly)
  Future<(String, Uint8List?)> runSingleTestCompute(
    String imagePath,
    String name,
    ComputeTestOperation operation,
  ) async {
    _log('=== Running $name Test (Compute) ===');
    _log('Image path: $imagePath');

    final stopwatch = Stopwatch()..start();

    _log('Checking if file exists...');
    final file = File(imagePath);
    final exists = await file.exists();
    _log('File exists: $exists');
    if (exists) {
      final fileSize = await file.length();
      _log('File size: $fileSize bytes');
    }

    _log('Executing $name operation...');
    final result = await operation(imagePath);
    _log('Operation result: ${result.width}x${result.height}');

    stopwatch.stop();
    _log('$name completed in ${stopwatch.elapsedMilliseconds}ms');

    final resultText = '✓ $name completed in ${stopwatch.elapsedMilliseconds}ms\n'
        '  Output: ${result.width}x${result.height}\n'
        '  Size: ${(result.data.length / 1024).toStringAsFixed(1)} KB';

    return (resultText, result.data);
  }

  /// Run a single test (sync version for backward compatibility)
  Future<(String, Uint8List?)> runSingleTest(
    String imagePath,
    String name,
    VipsImageWrapper Function(VipsImageWrapper) operation,
  ) async {
    _log('=== Running $name Test ===');
    _log('Image path: $imagePath');

    final stopwatch = Stopwatch()..start();

    _log('Loading image...');
    _log('Checking if file exists...');
    final file = File(imagePath);
    final exists = await file.exists();
    _log('File exists: $exists');
    if (exists) {
      final fileSize = await file.length();
      _log('File size: $fileSize bytes');
    }
    final image = VipsImageWrapper.fromFile(imagePath);
    _log('Image loaded: ${image.width}x${image.height}');

    _log('Executing $name operation...');
    final result = operation(image);
    _log('Operation result: ${result.width}x${result.height}');

    _log('Writing to PNG buffer...');
    final pngData = result.writeToBuffer('.png');
    _log('PNG buffer size: ${pngData.length} bytes');

    stopwatch.stop();
    _log('$name completed in ${stopwatch.elapsedMilliseconds}ms');

    final resultText = '✓ $name completed in ${stopwatch.elapsedMilliseconds}ms\n'
        '  Input: ${image.width}x${image.height}\n'
        '  Output: ${result.width}x${result.height}\n'
        '  Size: ${(pngData.length / 1024).toStringAsFixed(1)} KB';

    result.dispose();
    image.dispose();
    _log('Resources disposed');

    return (resultText, pngData);
  }
}

/// Predefined test operations (sync version)
class VipsTestOperations {
  static VipsImageWrapper resize(VipsImageWrapper image) => image.resize(0.5);
  static VipsImageWrapper thumbnail(VipsImageWrapper image) =>
      image.thumbnail(200);
  static VipsImageWrapper rotate(VipsImageWrapper image) => image.rotate(90);
  static VipsImageWrapper crop(VipsImageWrapper image) {
    final size = image.width < image.height ? image.width : image.height;
    return image.crop(0, 0, size ~/ 2, size ~/ 2);
  }

  static VipsImageWrapper flipH(VipsImageWrapper image) =>
      image.flip(VipsDirection.horizontal);
  static VipsImageWrapper flipV(VipsImageWrapper image) =>
      image.flip(VipsDirection.vertical);
  static VipsImageWrapper blur(VipsImageWrapper image) =>
      image.gaussianBlur(5.0);
  static VipsImageWrapper sharpen(VipsImageWrapper image) => image.sharpen();
  static VipsImageWrapper invert(VipsImageWrapper image) => image.invert();
  static VipsImageWrapper brightness(VipsImageWrapper image) =>
      image.brightness(1.2);
  static VipsImageWrapper contrast(VipsImageWrapper image) =>
      image.contrast(1.3);
  static VipsImageWrapper autoRotate(VipsImageWrapper image) =>
      image.autoRotate();
  static VipsImageWrapper smartCrop(VipsImageWrapper image) {
    final size =
        image.width < image.height ? image.width ~/ 2 : image.height ~/ 2;
    return image.smartCrop(size, size);
  }

  static VipsImageWrapper grayscale(VipsImageWrapper image) =>
      image.colourspace(VipsInterpretation.bw);
}

/// Predefined async test operations (runs in isolate)
class VipsTestOperationsAsync {
  static Future<VipsImageData> resize(Uint8List data) =>
      VipsImageAsync.resize(data, 0.5);
  static Future<VipsImageData> thumbnail(Uint8List data) =>
      VipsImageAsync.thumbnail(data, 200);
  static Future<VipsImageData> rotate(Uint8List data) =>
      VipsImageAsync.rotate(data, 90);
  static Future<VipsImageData> crop(Uint8List data) async {
    // Load to get dimensions first
    final image = await VipsImageAsync.loadFromBuffer(data);
    final size = image.width < image.height ? image.width : image.height;
    return VipsImageAsync.crop(data, 0, 0, size ~/ 2, size ~/ 2);
  }

  static Future<VipsImageData> flipH(Uint8List data) =>
      VipsImageAsync.flip(data, VipsDirection.horizontal);
  static Future<VipsImageData> flipV(Uint8List data) =>
      VipsImageAsync.flip(data, VipsDirection.vertical);
  static Future<VipsImageData> blur(Uint8List data) =>
      VipsImageAsync.gaussianBlur(data, 5.0);
  static Future<VipsImageData> sharpen(Uint8List data) =>
      VipsImageAsync.sharpen(data);
  static Future<VipsImageData> invert(Uint8List data) =>
      VipsImageAsync.invert(data);
  static Future<VipsImageData> brightness(Uint8List data) =>
      VipsImageAsync.brightness(data, 1.2);
  static Future<VipsImageData> contrast(Uint8List data) =>
      VipsImageAsync.contrast(data, 1.3);
  static Future<VipsImageData> autoRotate(Uint8List data) =>
      VipsImageAsync.autoRotate(data);
  static Future<VipsImageData> smartCrop(Uint8List data) async {
    final image = await VipsImageAsync.loadFromBuffer(data);
    final size =
        image.width < image.height ? image.width ~/ 2 : image.height ~/ 2;
    return VipsImageAsync.smartCrop(data, size, size);
  }

  static Future<VipsImageData> grayscale(Uint8List data) =>
      VipsImageAsync.colourspace(data, VipsInterpretation.bw);
}

/// Predefined compute test operations (more efficient, loads from file directly)
class VipsTestOperationsCompute {
  static Future<VipsComputeResult> resize(String path) =>
      VipsCompute.resizeFile(path, 0.5);
  static Future<VipsComputeResult> thumbnail(String path) =>
      VipsCompute.thumbnailFile(path, 200);
  static Future<VipsComputeResult> rotate(String path) =>
      VipsCompute.rotateFile(path, 90);
  static Future<VipsComputeResult> flipH(String path) =>
      VipsCompute.flipFile(path, VipsDirection.horizontal);
  static Future<VipsComputeResult> flipV(String path) =>
      VipsCompute.flipFile(path, VipsDirection.vertical);
  static Future<VipsComputeResult> blur(String path) =>
      VipsCompute.blurFile(path, 5.0);
  static Future<VipsComputeResult> sharpen(String path) =>
      VipsCompute.sharpenFile(path);
  static Future<VipsComputeResult> invert(String path) =>
      VipsCompute.invertFile(path);
  static Future<VipsComputeResult> brightness(String path) =>
      VipsCompute.brightnessFile(path, 1.2);
  static Future<VipsComputeResult> contrast(String path) =>
      VipsCompute.contrastFile(path, 1.3);
  static Future<VipsComputeResult> autoRotate(String path) =>
      VipsCompute.autoRotateFile(path);
  // Note: crop, smartCrop, grayscale need additional methods in VipsCompute
  // or can use processFile with custom operation
  static Future<VipsComputeResult> crop(String path) =>
      VipsCompute.processFile(path, (img) {
        final size = img.width < img.height ? img.width : img.height;
        return img.crop(0, 0, size ~/ 2, size ~/ 2);
      });
  static Future<VipsComputeResult> smartCrop(String path) =>
      VipsCompute.processFile(path, (img) {
        final size = img.width < img.height ? img.width ~/ 2 : img.height ~/ 2;
        return img.smartCrop(size, size);
      });
  static Future<VipsComputeResult> grayscale(String path) =>
      VipsCompute.processFile(path, (img) => img.colourspace(VipsInterpretation.bw));
}
