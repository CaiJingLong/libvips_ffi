import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_vips/flutter_vips.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _vipsVersion = 'Loading...';
  String _status = 'Initializing...';
  String? _testResult;
  bool _isLoading = false;
  String? _selectedImagePath;
  Uint8List? _processedImageData;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initVips();
  }

  Future<void> _initVips() async {
    try {
      initVips();
      setState(() {
        _vipsVersion = vipsVersionString;
        _status = 'libvips initialized successfully ✓';
      });
    } catch (e) {
      setState(() {
        _vipsVersion = 'Error';
        _status = 'Failed to initialize: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _testResult = null;
        _processedImageData = null;
      });
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
      final result = StringBuffer();
      final stopwatch = Stopwatch()..start();

      // Load the image
      final image = VipsImageWrapper.fromFile(_selectedImagePath!);
      result.writeln('✓ Image loaded: ${image.width}x${image.height}, ${image.bands} bands');

      // Test resize
      final resized = image.resize(0.5);
      result.writeln('✓ Resize (0.5x): ${resized.width}x${resized.height}');
      resized.dispose();

      // Test thumbnail
      final thumb = image.thumbnail(200);
      result.writeln('✓ Thumbnail (200px): ${thumb.width}x${thumb.height}');

      // Test rotate
      final rotated = image.rotate(45);
      result.writeln('✓ Rotate (45°): ${rotated.width}x${rotated.height}');
      rotated.dispose();

      // Test crop (if image is large enough)
      if (image.width >= 100 && image.height >= 100) {
        final cropped = image.crop(0, 0, 100, 100);
        result.writeln('✓ Crop (100x100): ${cropped.width}x${cropped.height}');
        cropped.dispose();
      }

      // Test write to buffer (JPEG)
      final jpegData = image.writeToBuffer('.jpg');
      result.writeln('✓ Write to JPEG: ${(jpegData.length / 1024).toStringAsFixed(1)} KB');

      // Test write to buffer (PNG)
      final pngData = thumb.writeToBuffer('.png');
      result.writeln('✓ Write to PNG: ${(pngData.length / 1024).toStringAsFixed(1)} KB');

      // Test write to file
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/vips_output.jpg';
      image.writeToFile(outputPath);
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        final size = await outputFile.length();
        result.writeln('✓ Write to file: ${(size / 1024).toStringAsFixed(1)} KB');
      }

      stopwatch.stop();
      result.writeln('\n✓ All tests passed in ${stopwatch.elapsedMilliseconds}ms!');

      // Keep thumbnail data for display
      setState(() {
        _processedImageData = pngData;
      });

      thumb.dispose();
      image.dispose();

      setState(() {
        _testResult = result.toString();
      });
    } catch (e, stack) {
      setState(() {
        _testResult = '✗ Test failed: $e\n\n$stack';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testResize() async {
    await _runSingleTest('Resize', (image) => image.resize(0.5));
  }

  Future<void> _testThumbnail() async {
    await _runSingleTest('Thumbnail', (image) => image.thumbnail(200));
  }

  Future<void> _testRotate() async {
    await _runSingleTest('Rotate', (image) => image.rotate(90));
  }

  Future<void> _testCrop() async {
    await _runSingleTest('Crop', (image) {
      final size = image.width < image.height ? image.width : image.height;
      return image.crop(0, 0, size ~/ 2, size ~/ 2);
    });
  }

  Future<void> _runSingleTest(
    String name,
    VipsImageWrapper Function(VipsImageWrapper) operation,
  ) async {
    if (_selectedImagePath == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _testResult = 'Running $name...';
    });

    try {
      final stopwatch = Stopwatch()..start();

      final image = VipsImageWrapper.fromFile(_selectedImagePath!);
      final result = operation(image);
      final pngData = result.writeToBuffer('.png');

      stopwatch.stop();

      setState(() {
        _testResult = '✓ $name completed in ${stopwatch.elapsedMilliseconds}ms\n'
            '  Input: ${image.width}x${image.height}\n'
            '  Output: ${result.width}x${result.height}\n'
            '  Size: ${(pngData.length / 1024).toStringAsFixed(1)} KB';
        _processedImageData = pngData;
      });

      result.dispose();
      image.dispose();
    } catch (e) {
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
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Vips Example'),
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
                            _buildTestButton('All Tests', Icons.play_arrow, _runAllTests),
                            _buildTestButton('Resize', Icons.photo_size_select_large, _testResize),
                            _buildTestButton('Thumbnail', Icons.photo_size_select_small, _testThumbnail),
                            _buildTestButton('Rotate', Icons.rotate_right, _testRotate),
                            _buildTestButton('Crop', Icons.crop, _testCrop),
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

  @override
  void dispose() {
    shutdownVips();
    super.dispose();
  }
}
