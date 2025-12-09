import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:libvips_ffi/libvips_ffi.dart';
import 'package:image_picker/image_picker.dart';

import '../vips_tests.dart';

void _log(String message) {
  debugPrint('[FlutterVips] $message');
  developer.log(message, name: 'FlutterVips');
}

class AllTestsPage extends StatefulWidget {
  const AllTestsPage({super.key});

  @override
  State<AllTestsPage> createState() => _AllTestsPageState();
}

class _AllTestsPageState extends State<AllTestsPage> {
  String _vipsVersion = 'Loading...';
  String _status = 'Initializing...';
  String? _testResult;
  bool _isLoading = false;
  String? _selectedImagePath;
  Uint8List? _processedImageData;

  final ImagePicker _picker = ImagePicker();
  final _testRunner = VipsTestRunner(onLog: _log);

  @override
  void initState() {
    super.initState();
    _initVips();
  }

  Future<void> _initVips() async {
    _log('Initializing libvips...');
    _log('Platform: ${Platform.operatingSystem}');
    try {
      _log('Loading vips library...');
      initVips();
      _log('vips_init() called successfully');

      final major = vipsVersion(0);
      final minor = vipsVersion(1);
      final micro = vipsVersion(2);
      final version = '$major.$minor.$micro';
      _log('libvips version: $version');

      setState(() {
        _vipsVersion = version;
        _status = 'libvips initialized successfully ✓';
      });
    } catch (e, stack) {
      _log('Failed to initialize libvips: $e');
      _log('Stack trace: $stack');
      setState(() {
        _vipsVersion = 'Error';
        _status = 'Failed to initialize: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    _log('Opening image picker...');
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _log('Image selected: ${image.path}');
      setState(() {
        _selectedImagePath = image.path;
        _testResult = null;
        _processedImageData = null;
      });
    } else {
      _log('No image selected');
    }
  }

  Future<void> _runAllTests() async {
    if (_selectedImagePath == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _testResult = 'Running tests...';
      _processedImageData = null;
    });

    try {
      final (result, imageData) =
          await _testRunner.runAllTests(_selectedImagePath!);
      setState(() {
        _testResult = result;
        _processedImageData = imageData;
      });
    } catch (e, stack) {
      _log('ERROR: $e');
      _log('Stack trace: $stack');
      setState(() {
        _testResult = '✗ Test failed: $e\n\n$stack';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testResize() async =>
      _runSingleTestAsync('Resize', VipsTestOperationsAsync.resize);

  Future<void> _testThumbnail() async =>
      _runSingleTestAsync('Thumbnail', VipsTestOperationsAsync.thumbnail);

  Future<void> _testRotate() async =>
      _runSingleTestAsync('Rotate', VipsTestOperationsAsync.rotate);

  Future<void> _testCrop() async =>
      _runSingleTestAsync('Crop', VipsTestOperationsAsync.crop);

  Future<void> _testFlipH() async =>
      _runSingleTestAsync('Flip Horizontal', VipsTestOperationsAsync.flipH);

  Future<void> _testFlipV() async =>
      _runSingleTestAsync('Flip Vertical', VipsTestOperationsAsync.flipV);

  Future<void> _testBlur() async =>
      _runSingleTestAsync('Gaussian Blur', VipsTestOperationsAsync.blur);

  Future<void> _testSharpen() async =>
      _runSingleTestAsync('Sharpen', VipsTestOperationsAsync.sharpen);

  Future<void> _testInvert() async =>
      _runSingleTestAsync('Invert', VipsTestOperationsAsync.invert);

  Future<void> _testBrightness() async =>
      _runSingleTestAsync(
          'Brightness +20%', VipsTestOperationsAsync.brightness);

  Future<void> _testContrast() async =>
      _runSingleTestAsync('Contrast +30%', VipsTestOperationsAsync.contrast);

  Future<void> _testAutoRotate() async =>
      _runSingleTestAsync('Auto Rotate', VipsTestOperationsAsync.autoRotate);

  Future<void> _testSmartCrop() async =>
      _runSingleTestAsync('Smart Crop', VipsTestOperationsAsync.smartCrop);

  Future<void> _testGrayscale() async =>
      _runSingleTestAsync('Grayscale', VipsTestOperationsAsync.grayscale);

  Future<void> _runSingleTestAsync(
    String name,
    AsyncTestOperation operation,
  ) async {
    if (_selectedImagePath == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _testResult = 'Running $name...';
    });

    try {
      final (result, imageData) = await _testRunner.runSingleTestAsync(
          _selectedImagePath!, name, operation);
      setState(() {
        _testResult = result;
        _processedImageData = imageData;
      });
    } catch (e, stack) {
      _log('ERROR in $name: $e');
      _log('Stack trace: $stack');
      setState(() {
        _testResult = '✗ $name failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tests'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Version Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.image, size: 40, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'libvips $_vipsVersion',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _status,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Image',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_selectedImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImagePath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('No image selected'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pick Image'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons
            if (_selectedImagePath != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image Operations',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTestButton(
                              'All Tests', Icons.play_arrow, _runAllTests),
                          _buildTestButton('Resize',
                              Icons.photo_size_select_large, _testResize),
                          _buildTestButton('Thumbnail',
                              Icons.photo_size_select_small, _testThumbnail),
                          _buildTestButton(
                              'Rotate', Icons.rotate_right, _testRotate),
                          _buildTestButton('Crop', Icons.crop, _testCrop),
                          _buildTestButton('Flip H', Icons.flip, _testFlipH),
                          _buildTestButton('Flip V',
                              Icons.flip_camera_android, _testFlipV),
                          _buildTestButton('Blur', Icons.blur_on, _testBlur),
                          _buildTestButton(
                              'Sharpen', Icons.deblur, _testSharpen),
                          _buildTestButton(
                              'Invert', Icons.invert_colors, _testInvert),
                          _buildTestButton(
                              'Bright+', Icons.brightness_high, _testBrightness),
                          _buildTestButton(
                              'Contrast+', Icons.contrast, _testContrast),
                          _buildTestButton('Auto Rot', Icons.screen_rotation,
                              _testAutoRotate),
                          _buildTestButton('Smart Crop',
                              Icons.center_focus_strong, _testSmartCrop),
                          _buildTestButton(
                              'Grayscale', Icons.filter_b_and_w, _testGrayscale),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Results
            if (_testResult != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        Text(
                          _testResult!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        if (_processedImageData != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Processed Image:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _processedImageData!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
