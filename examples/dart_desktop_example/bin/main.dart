import 'dart:io';

import 'package:libvips_ffi_system/libvips_ffi_system.dart';

Future<void> main(List<String> args) async {
  print('=== libvips_ffi Desktop Example ===\n');

  // 1. 检查系统安装情况
  print('Checking system package managers...');
  final managers = await checkVipsInstallation();

  if (managers.isEmpty) {
    print('No package managers detected.');
  } else {
    for (final m in managers) {
      print('  ${m.name}: installed=${m.isInstalled}'
          '${m.vipsVersion != null ? ", version=${m.vipsVersion}" : ""}');
      if (m.isInstalled) {
        print('    Library paths: ${m.libraryPaths.join(", ")}');
      }
    }
  }

  // 2. 检查是否有已安装的 libvips
  final hasVips = managers.any((m) => m.isInstalled);
  if (!hasVips) {
    print('\nlibvips is not installed!');
    print('Installation suggestion:');
    print(await getVipsInstallSuggestion());
    exit(1);
  }

  // 3. 初始化 libvips
  print('\nInitializing libvips...');
  try {
    await initVipsSystemAsync();
    print('libvips initialized successfully!');
  } catch (e) {
    print('Failed to initialize libvips: $e');
    exit(1);
  }

  // 4. 获取版本信息
  final major = vipsVersion(0);
  final minor = vipsVersion(1);
  final micro = vipsVersion(2);
  print('libvips version: $major.$minor.$micro');

  // 5. 解析命令
  if (args.isEmpty) {
    _printUsage();
    shutdownVips();
    return;
  }

  final command = args[0];
  final commandArgs = args.skip(1).toList();

  try {
    switch (command) {
      case 'resize':
        await _runResize(commandArgs);
        break;
      case 'crop':
        await _runCrop(commandArgs);
        break;
      case 'rotate':
        await _runRotate(commandArgs);
        break;
      case 'flip':
        await _runFlip(commandArgs);
        break;
      case 'blur':
        await _runBlur(commandArgs);
        break;
      case 'sharpen':
        await _runSharpen(commandArgs);
        break;
      case 'invert':
        await _runInvert(commandArgs);
        break;
      case 'grayscale':
        await _runGrayscale(commandArgs);
        break;
      case 'thumbnail':
        await _runThumbnail(commandArgs);
        break;
      case 'info':
        await _runInfo(commandArgs);
        break;
      default:
        print('Unknown command: $command');
        _printUsage();
    }
  } catch (e) {
    print('Error: $e');
  }

  // 6. 关闭 libvips
  shutdownVips();
  print('\nlibvips shutdown.');
}

void _printUsage() {
  print('''
Usage: dart run bin/main.dart <command> [options]

Commands:
  info <input>                      Show image information
  resize <input> <output> <scale>   Resize image (scale: 0.5 = 50%)
  crop <input> <output> <x> <y> <w> <h>  Crop image
  rotate <input> <output> <angle>   Rotate image (angle in degrees)
  flip <input> <output> <h|v>       Flip image (h=horizontal, v=vertical)
  blur <input> <output> [sigma]     Apply Gaussian blur (default sigma=3)
  sharpen <input> <output>          Sharpen image
  invert <input> <output>           Invert colors
  grayscale <input> <output>        Convert to grayscale
  thumbnail <input> <output> <width> Create thumbnail

Examples:
  dart run bin/main.dart info photo.jpg
  dart run bin/main.dart resize photo.jpg small.jpg 0.5
  dart run bin/main.dart crop photo.jpg cropped.jpg 100 100 200 200
  dart run bin/main.dart rotate photo.jpg rotated.jpg 90
  dart run bin/main.dart blur photo.jpg blurred.jpg 5
''');
}

Future<void> _runInfo(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: info <input>');
    return;
  }
  final input = args[0];
  final image = VipsImageWrapper.fromFile(input);
  print('\nImage Info: $input');
  print('  Size: ${image.width}x${image.height}');
  print('  Bands: ${image.bands}');
  image.dispose();
}

Future<void> _runResize(List<String> args) async {
  if (args.length < 3) {
    print('Usage: resize <input> <output> <scale>');
    return;
  }
  final input = args[0];
  final output = args[1];
  final scale = double.parse(args[2]);

  print('\nResizing $input -> $output (scale: $scale)');
  final image = VipsImageWrapper.fromFile(input);
  print('  Original: ${image.width}x${image.height}');

  final resized = image.resize(scale);
  print('  Resized: ${resized.width}x${resized.height}');

  resized.writeToFile(output);
  print('  Saved to: $output');

  resized.dispose();
  image.dispose();
}

Future<void> _runCrop(List<String> args) async {
  if (args.length < 6) {
    print('Usage: crop <input> <output> <x> <y> <width> <height>');
    return;
  }
  final input = args[0];
  final output = args[1];
  final x = int.parse(args[2]);
  final y = int.parse(args[3]);
  final w = int.parse(args[4]);
  final h = int.parse(args[5]);

  print('\nCropping $input -> $output (x:$x, y:$y, w:$w, h:$h)');
  final image = VipsImageWrapper.fromFile(input);
  print('  Original: ${image.width}x${image.height}');

  final cropped = image.crop(x, y, w, h);
  print('  Cropped: ${cropped.width}x${cropped.height}');

  cropped.writeToFile(output);
  print('  Saved to: $output');

  cropped.dispose();
  image.dispose();
}

Future<void> _runRotate(List<String> args) async {
  if (args.length < 3) {
    print('Usage: rotate <input> <output> <angle>');
    return;
  }
  final input = args[0];
  final output = args[1];
  final angle = double.parse(args[2]);

  print('\nRotating $input -> $output (angle: $angle°)');
  final image = VipsImageWrapper.fromFile(input);
  print('  Original: ${image.width}x${image.height}');

  final rotated = image.rotate(angle);
  print('  Rotated: ${rotated.width}x${rotated.height}');

  rotated.writeToFile(output);
  print('  Saved to: $output');

  rotated.dispose();
  image.dispose();
}

Future<void> _runFlip(List<String> args) async {
  if (args.length < 3) {
    print('Usage: flip <input> <output> <h|v>');
    return;
  }
  final input = args[0];
  final output = args[1];
  final direction = args[2].toLowerCase() == 'h'
      ? VipsDirection.horizontal
      : VipsDirection.vertical;

  print('\nFlipping $input -> $output (${args[2]})');
  final image = VipsImageWrapper.fromFile(input);

  final flipped = image.flip(direction);

  flipped.writeToFile(output);
  print('  Saved to: $output');

  flipped.dispose();
  image.dispose();
}

Future<void> _runBlur(List<String> args) async {
  if (args.length < 2) {
    print('Usage: blur <input> <output> [sigma]');
    return;
  }
  final input = args[0];
  final output = args[1];
  final sigma = args.length > 2 ? double.parse(args[2]) : 3.0;

  print('\nBlurring $input -> $output (sigma: $sigma)');
  final image = VipsImageWrapper.fromFile(input);

  final blurred = image.gaussianBlur(sigma);

  blurred.writeToFile(output);
  print('  Saved to: $output');

  blurred.dispose();
  image.dispose();
}

Future<void> _runSharpen(List<String> args) async {
  if (args.length < 2) {
    print('Usage: sharpen <input> <output>');
    return;
  }
  final input = args[0];
  final output = args[1];

  print('\nSharpening $input -> $output');
  final image = VipsImageWrapper.fromFile(input);

  final sharpened = image.sharpen();

  sharpened.writeToFile(output);
  print('  Saved to: $output');

  sharpened.dispose();
  image.dispose();
}

Future<void> _runInvert(List<String> args) async {
  if (args.length < 2) {
    print('Usage: invert <input> <output>');
    return;
  }
  final input = args[0];
  final output = args[1];

  print('\nInverting $input -> $output');
  final image = VipsImageWrapper.fromFile(input);

  final inverted = image.invert();

  inverted.writeToFile(output);
  print('  Saved to: $output');

  inverted.dispose();
  image.dispose();
}

Future<void> _runGrayscale(List<String> args) async {
  if (args.length < 2) {
    print('Usage: grayscale <input> <output>');
    return;
  }
  final input = args[0];
  final output = args[1];

  print('\nConverting to grayscale $input -> $output');
  final image = VipsImageWrapper.fromFile(input);

  final gray = image.colourspace(VipsInterpretation.bw);

  gray.writeToFile(output);
  print('  Saved to: $output');

  gray.dispose();
  image.dispose();
}

Future<void> _runThumbnail(List<String> args) async {
  if (args.length < 3) {
    print('Usage: thumbnail <input> <output> <width>');
    return;
  }
  final input = args[0];
  final output = args[1];
  final width = int.parse(args[2]);

  print('\nCreating thumbnail $input -> $output (width: $width)');
  final image = VipsImageWrapper.fromFile(input);
  print('  Original: ${image.width}x${image.height}');

  final thumb = image.thumbnail(width);
  print('  Thumbnail: ${thumb.width}x${thumb.height}');

  thumb.writeToFile(output);
  print('  Saved to: $output');

  thumb.dispose();
  image.dispose();
}
