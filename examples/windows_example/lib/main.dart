import 'package:flutter/material.dart';
import 'package:libvips_ffi_windows/libvips_ffi_windows.dart';
import 'package:libvips_flutter_example_base/libvips_flutter_example_base.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'libvips Windows Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(
        onInit: () => initVipsWindows(),
      ),
    );
  }
}
