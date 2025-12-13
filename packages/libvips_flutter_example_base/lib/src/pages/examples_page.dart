import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:libvips_ffi/libvips_ffi.dart';

/// Examples page showing code samples for each operation.
///
/// 示例页面，展示每个操作的代码示例。
class ExamplesPage extends StatefulWidget {
  const ExamplesPage({super.key});

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {
  String? _selectedImagePath;
  Uint8List? _processedImageData;
  bool _isProcessing = false;
  int _selectedExampleIndex = 0;

  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Example definitions
  static final List<ExampleItem> _examples = [
    ExampleItem(
      title: 'Resize / 调整大小',
      description: 'Scale image by a factor (0.5 = half size)',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final resized = image.resize(0.5);  // 50% size
resized.writeToFile('output.jpg');
resized.dispose();
image.dispose();''',
      asyncCode: '''
// Using VipsCompute (recommended for Flutter)
final result = await VipsCompute.resizeFile(
  'input.jpg',
  0.5,  // scale factor
);
// result.data contains the processed image bytes''',
      operation: (img) => img.resize(0.5),
    ),
    ExampleItem(
      title: 'Thumbnail / 缩略图',
      description: 'Create thumbnail with target width (maintains aspect ratio)',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final thumb = image.thumbnail(200);  // 200px width
thumb.writeToFile('thumb.jpg');
thumb.dispose();
image.dispose();''',
      asyncCode: '''
// Direct thumbnail from file (most efficient)
final result = await VipsCompute.thumbnailFile(
  'input.jpg',
  200,  // target width
);''',
      operation: (img) => img.thumbnail(200),
    ),
    ExampleItem(
      title: 'Rotate / 旋转',
      description: 'Rotate image by angle in degrees',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final rotated = image.rotate(90);  // 90 degrees
rotated.writeToFile('rotated.jpg');
rotated.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.rotateFile(
  'input.jpg',
  90,  // degrees
);''',
      operation: (img) => img.rotate(90),
    ),
    ExampleItem(
      title: 'Crop / 裁剪',
      description: 'Extract a rectangular region from image',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final cropped = image.crop(
  100,  // left
  100,  // top
  200,  // width
  200,  // height
);
cropped.writeToFile('cropped.jpg');
cropped.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.cropFile(
  'input.jpg',
  100, 100,  // left, top
  200, 200,  // width, height
);''',
      operation: (img) {
        final size = img.width < img.height ? img.width : img.height;
        return img.crop(0, 0, size ~/ 2, size ~/ 2);
      },
    ),
    ExampleItem(
      title: 'Flip / 翻转',
      description: 'Flip image horizontally or vertically',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');

// Horizontal flip (mirror)
final flippedH = image.flip(VipsDirection.horizontal);

// Vertical flip
final flippedV = image.flip(VipsDirection.vertical);

flippedH.dispose();
flippedV.dispose();
image.dispose();''',
      asyncCode: '''
// Horizontal flip
final result = await VipsCompute.flipFile(
  'input.jpg',
  VipsDirection.horizontal,
);''',
      operation: (img) => img.flip(VipsDirection.horizontal),
    ),
    ExampleItem(
      title: 'Blur / 模糊',
      description: 'Apply Gaussian blur with sigma value',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final blurred = image.gaussianBlur(5.0);  // sigma = 5
blurred.writeToFile('blurred.jpg');
blurred.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.blurFile(
  'input.jpg',
  5.0,  // sigma (blur amount)
);''',
      operation: (img) => img.gaussianBlur(5.0),
    ),
    ExampleItem(
      title: 'Sharpen / 锐化',
      description: 'Sharpen image using unsharp masking',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final sharpened = image.sharpen();
sharpened.writeToFile('sharpened.jpg');
sharpened.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.sharpenFile('input.jpg');''',
      operation: (img) => img.sharpen(),
    ),
    ExampleItem(
      title: 'Invert / 反色',
      description: 'Invert image colors (negative effect)',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final inverted = image.invert();
inverted.writeToFile('inverted.jpg');
inverted.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.invertFile('input.jpg');''',
      operation: (img) => img.invert(),
    ),
    ExampleItem(
      title: 'Brightness / 亮度',
      description: 'Adjust image brightness (1.0 = no change)',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final brighter = image.brightness(1.3);  // +30%
final darker = image.brightness(0.7);    // -30%
brighter.dispose();
darker.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.brightnessFile(
  'input.jpg',
  1.3,  // factor (1.3 = 30% brighter)
);''',
      operation: (img) => img.brightness(1.3),
    ),
    ExampleItem(
      title: 'Contrast / 对比度',
      description: 'Adjust image contrast (1.0 = no change)',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final highContrast = image.contrast(1.5);  // +50%
final lowContrast = image.contrast(0.5);   // -50%
highContrast.dispose();
lowContrast.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.contrastFile(
  'input.jpg',
  1.5,  // factor (1.5 = 50% more contrast)
);''',
      operation: (img) => img.contrast(1.5),
    ),
    ExampleItem(
      title: 'Grayscale / 灰度',
      description: 'Convert image to grayscale',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final gray = image.colourspace(VipsInterpretation.bw);
gray.writeToFile('grayscale.jpg');
gray.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.processFile(
  'input.jpg',
  (img) => img.colourspace(VipsInterpretation.bw),
);''',
      operation: (img) => img.colourspace(VipsInterpretation.bw),
    ),
    ExampleItem(
      title: 'Smart Crop / 智能裁剪',
      description: 'Crop to focus on the most interesting part',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final cropped = image.smartCrop(300, 300);  // 300x300
cropped.writeToFile('smart_cropped.jpg');
cropped.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.processFile(
  'input.jpg',
  (img) => img.smartCrop(300, 300),
);''',
      operation: (img) {
        final size = img.width < img.height ? img.width ~/ 2 : img.height ~/ 2;
        return img.smartCrop(size, size);
      },
    ),
    ExampleItem(
      title: 'Auto Rotate / 自动旋转',
      description: 'Rotate based on EXIF orientation tag',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');
final rotated = image.autoRotate();
rotated.writeToFile('auto_rotated.jpg');
rotated.dispose();
image.dispose();''',
      asyncCode: '''
final result = await VipsCompute.autoRotateFile('input.jpg');''',
      operation: (img) => img.autoRotate(),
    ),
    ExampleItem(
      title: 'Chain Operations / 链式操作',
      description: 'Combine multiple operations',
      code: '''
final image = VipsImageWrapper.fromFile('input.jpg');

// Chain operations (remember to dispose intermediates!)
final step1 = image.resize(0.5);
final step2 = step1.gaussianBlur(2.0);
final step3 = step2.sharpen();

step3.writeToFile('output.jpg');

// Dispose in reverse order
step3.dispose();
step2.dispose();
step1.dispose();
image.dispose();''',
      asyncCode: '''
// Using processFile for custom chains
final result = await VipsCompute.processFile(
  'input.jpg',
  (img) {
    final resized = img.resize(0.5);
    final blurred = resized.gaussianBlur(2.0);
    resized.dispose();  // Clean up intermediate
    return blurred;
  },
);''',
      operation: (img) {
        final step1 = img.resize(0.5);
        final step2 = step1.gaussianBlur(2.0);
        step1.dispose();
        return step2;
      },
    ),
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _processedImageData = null;
      });
    }
  }

  Future<void> _runExample() async {
    if (_selectedImagePath == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _processedImageData = null;
    });

    try {
      final example = _examples[_selectedExampleIndex];
      final result = await VipsCompute.processFile(
        _selectedImagePath!,
        example.operation,
      );
      setState(() {
        _processedImageData = result.data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied / 代码已复制')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final example = _examples[_selectedExampleIndex];
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Examples / 示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Use endDrawer (right side) for mobile, sidebar for tablet/desktop
      endDrawer: isWideScreen ? null : _buildExampleDrawer(),
      body: isWideScreen
          ? Row(
              children: [
                // Left sidebar - Example list (tablet/desktop)
                SizedBox(
                  width: 200,
                  child: _buildExampleList(),
                ),
                // Right content area
                Expanded(child: _buildExampleContent(example)),
              ],
            )
          : _buildExampleContent(example),
    );
  }

  Widget _buildExampleDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Example',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildExampleList()),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleList() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView.builder(
        itemCount: _examples.length,
        itemBuilder: (context, index) {
          final item = _examples[index];
          final isSelected = index == _selectedExampleIndex;
          return ListTile(
            dense: true,
            selected: isSelected,
            selectedTileColor: Colors.blue.shade50,
            title: Text(
              item.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedExampleIndex = index;
                _processedImageData = null;
              });
              // Close endDrawer on mobile
              if (MediaQuery.of(context).size.width <= 600) {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildExampleContent(ExampleItem example) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile: Show current example selector
          if (MediaQuery.of(context).size.width <= 600)
            Card(
              child: ListTile(
                leading: const Icon(Icons.list),
                title: Text(example.title),
                subtitle: const Text('Tap to select example / 点击选择示例'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ),
          if (MediaQuery.of(context).size.width <= 600)
            const SizedBox(height: 16),

          // Title and description
          Text(
            example.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            example.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          // Sync code
          _buildCodeSection(
            context,
            'Sync API / 同步 API',
            example.code,
            Colors.blue,
          ),
          const SizedBox(height: 16),

          // Async code
          _buildCodeSection(
            context,
            'Async API / 异步 API (Flutter)',
            example.asyncCode,
            Colors.green,
          ),
          const SizedBox(height: 24),

          // Try it section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try It / 试一试',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick'),
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            _selectedImagePath != null && !_isProcessing
                                ? _runExample
                                : null,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: const Text('Run'),
                      ),
                    ],
                  ),
                  if (_selectedImagePath != null ||
                      _processedImageData != null) ...[
                    const SizedBox(height: 16),
                    // Comparison view - responsive
                    _buildComparisonView(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    final isNarrow = MediaQuery.of(context).size.width <= 400;

    final originalWidget = _selectedImagePath != null
        ? _buildImageCard('Original', Colors.blue, Image.file(
            File(_selectedImagePath!),
            height: isNarrow ? 150 : 200,
            fit: BoxFit.contain,
          ))
        : null;

    final processedWidget = _processedImageData != null
        ? _buildImageCard('Processed', Colors.green, Image.memory(
            _processedImageData!,
            height: isNarrow ? 150 : 200,
            fit: BoxFit.contain,
          ))
        : null;

    // Stack vertically on very narrow screens
    if (isNarrow) {
      return Column(
        children: [
          if (originalWidget != null) originalWidget,
          if (originalWidget != null && processedWidget != null)
            const SizedBox(height: 12),
          if (processedWidget != null) processedWidget,
        ],
      );
    }

    // Side by side on wider screens
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (originalWidget != null) Expanded(child: originalWidget),
          if (originalWidget != null && processedWidget != null)
            const SizedBox(width: 12),
          if (processedWidget != null) Expanded(child: processedWidget),
        ],
      ),
    );
  }

  Widget _buildImageCard(String label, Color color, Widget image) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image,
        ),
      ],
    );
  }

  Widget _buildCodeSection(
    BuildContext context,
    String title,
    String code,
    Color accentColor,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor.shade700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 18, color: accentColor.shade700),
                  onPressed: () => _copyCode(code),
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: SelectableText.rich(
              _buildHighlightedCode(code.trim()),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example item definition
class ExampleItem {
  final String title;
  final String description;
  final String code;
  final String asyncCode;
  final VipsImageWrapper Function(VipsImageWrapper) operation;

  const ExampleItem({
    required this.title,
    required this.description,
    required this.code,
    required this.asyncCode,
    required this.operation,
  });
}

extension on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}

/// Simple Dart syntax highlighter
TextSpan _buildHighlightedCode(String code) {
  final spans = <TextSpan>[];
  
  // Define colors for different token types
  const keywordColor = Color(0xFF569CD6);      // Blue - keywords
  const stringColor = Color(0xFFCE9178);       // Orange - strings
  const commentColor = Color(0xFF6A9955);      // Green - comments
  const numberColor = Color(0xFFB5CEA8);       // Light green - numbers
  const typeColor = Color(0xFF4EC9B0);         // Cyan - types
  const functionColor = Color(0xFFDCDCAA);     // Yellow - functions
  const defaultColor = Colors.white;
  
  // Keywords
  final keywords = {
    'final', 'var', 'const', 'void', 'async', 'await', 'return', 'try',
    'catch', 'finally', 'if', 'else', 'for', 'while', 'import', 'class',
    'extends', 'with', 'mixin', 'static', 'new', 'this', 'super', 'true',
    'false', 'null', 'Future', 'int', 'double', 'String', 'bool', 'dynamic',
  };
  
  // Types (capitalized words that are likely types)
  final types = {
    'VipsImageWrapper', 'VipsCompute', 'VipsDirection', 'VipsInterpretation',
    'VipsPointerManager', 'Image', 'Uint8List', 'File',
  };
  
  // Simple tokenizer
  final buffer = StringBuffer();
  var i = 0;
  
  void flushBuffer(Color color) {
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(
        text: buffer.toString(),
        style: TextStyle(color: color),
      ));
      buffer.clear();
    }
  }
  
  while (i < code.length) {
    final char = code[i];
    
    // Check for comments
    if (i < code.length - 1 && code[i] == '/' && code[i + 1] == '/') {
      flushBuffer(defaultColor);
      final commentEnd = code.indexOf('\n', i);
      final end = commentEnd == -1 ? code.length : commentEnd;
      spans.add(TextSpan(
        text: code.substring(i, end),
        style: const TextStyle(color: commentColor),
      ));
      i = end;
      continue;
    }
    
    // Check for strings
    if (char == "'" || char == '"') {
      flushBuffer(defaultColor);
      final quote = char;
      final start = i;
      i++;
      while (i < code.length && code[i] != quote) {
        if (code[i] == '\\' && i + 1 < code.length) i++;
        i++;
      }
      if (i < code.length) i++;
      spans.add(TextSpan(
        text: code.substring(start, i),
        style: const TextStyle(color: stringColor),
      ));
      continue;
    }
    
    // Check for numbers
    if (RegExp(r'[0-9]').hasMatch(char)) {
      flushBuffer(defaultColor);
      final start = i;
      while (i < code.length && RegExp(r'[0-9.]').hasMatch(code[i])) {
        i++;
      }
      spans.add(TextSpan(
        text: code.substring(start, i),
        style: const TextStyle(color: numberColor),
      ));
      continue;
    }
    
    // Check for identifiers (words)
    if (RegExp(r'[a-zA-Z_]').hasMatch(char)) {
      flushBuffer(defaultColor);
      final start = i;
      while (i < code.length && RegExp(r'[a-zA-Z0-9_]').hasMatch(code[i])) {
        i++;
      }
      final word = code.substring(start, i);
      
      Color wordColor;
      if (keywords.contains(word)) {
        wordColor = keywordColor;
      } else if (types.contains(word)) {
        wordColor = typeColor;
      } else if (i < code.length && code[i] == '(') {
        wordColor = functionColor;
      } else {
        wordColor = defaultColor;
      }
      
      spans.add(TextSpan(
        text: word,
        style: TextStyle(color: wordColor),
      ));
      continue;
    }
    
    // Default: add to buffer
    buffer.write(char);
    i++;
  }
  
  flushBuffer(defaultColor);
  
  return TextSpan(children: spans);
}
