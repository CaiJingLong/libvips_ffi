# Flutter FFI libvips 库创建教程与兼容性报告

本文档提供了创建 Flutter FFI 库（以 libvips 为例）的完整教程，并包含详细的 Flutter/Dart 版本兼容性分析。

## 目录

1. [Flutter FFI 兼容性报告](#flutter-ffi-兼容性报告)
2. [创建 Flutter FFI 库教程](#创建-flutter-ffi-库教程)
3. [libvips 特定集成指南](#libvips-特定集成指南)
4. [跨平台最佳实践](#跨平台最佳实践)

---

## Flutter FFI 兼容性报告

### 概述

`dart:ffi` 是 Dart 的外部函数接口库，允许 Dart 代码调用原生 C 库。本节详细分析了不同 Flutter 版本的 FFI 支持情况。

### Dart FFI 版本演进时间线

| Dart 版本 | Flutter 版本 | 发布日期 | FFI 关键特性 |
|-----------|-------------|----------|-------------|
| Dart 2.6 | Flutter 1.12 | 2019-12 | `dart:ffi` 预览版首次引入 |
| Dart 2.12 | Flutter 2.0 | 2021-03 | `dart:ffi` 正式稳定版、空安全支持 |
| Dart 2.13 | Flutter 2.2 | 2021-05 | `Array` 类型支持、改进的 ABI 支持 |
| Dart 2.14 | Flutter 2.5 | 2021-09 | `@Native` 注解预览 |
| Dart 2.17 | Flutter 3.0 | 2022-05 | 增强的 FFI 性能优化 |
| Dart 2.18 | Flutter 3.3 | 2022-08 | Objective-C/Swift 互操作改进 |
| Dart 3.0 | Flutter 3.10 | 2023-05 | `NativeCallable` 支持、新的内存管理 API |
| Dart 3.1 | Flutter 3.13 | 2023-08 | FFI Native 资产支持（实验性） |
| Dart 3.2 | Flutter 3.16 | 2023-11 | 构建钩子 (Build Hooks) 预览 |
| Dart 3.4 | Flutter 3.22 | 2024-05 | Native Assets 正式支持 |

### 最低推荐版本

**为了获得最佳的 FFI 开发体验，建议使用以下最低版本：**

| 需求级别 | Flutter 版本 | Dart 版本 | 理由 |
|----------|-------------|-----------|------|
| **最低可用** | Flutter 2.0+ | Dart 2.12+ | `dart:ffi` 稳定版、空安全 |
| **推荐** | Flutter 3.0+ | Dart 2.17+ | 性能优化、完整的 ABI 类型支持 |
| **最佳体验** | Flutter 3.22+ | Dart 3.4+ | Native Assets、自动构建集成 |

### FFI API 可用性矩阵

| API 特性 | 最低 Dart 版本 | 最低 Flutter 版本 | 备注 |
|----------|---------------|------------------|------|
| `DynamicLibrary.open()` | 2.12 | 2.0 | 加载动态库 |
| `DynamicLibrary.process()` | 2.12 | 2.0 | iOS 静态链接库 |
| `DynamicLibrary.executable()` | 2.12 | 2.0 | 可执行文件中查找符号 |
| `Pointer<T>` | 2.12 | 2.0 | 原生指针类型 |
| `Struct` | 2.12 | 2.0 | 定义 C 结构体 |
| `Union` | 2.13 | 2.2 | 定义 C 联合体 |
| `Array<T>` | 2.13 | 2.2 | 固定大小数组 |
| `@Packed()` | 2.13 | 2.2 | 结构体对齐控制 |
| `AbiSpecificInteger` | 2.13 | 2.2 | 平台特定整数类型 |
| `NativeCallable` | 3.0 | 3.10 | 创建可从 C 调用的 Dart 函数 |
| `@Native<T>()` | 3.2 | 3.16 | 声明式外部函数绑定 |
| Native Assets | 3.4 | 3.22 | 自动化原生代码构建 |

### Flutter 平台 FFI 支持情况

| 平台 | 支持状态 | 库加载方式 | 最低 Flutter 版本 |
|------|---------|-----------|------------------|
| Android | ✅ 完全支持 | `DynamicLibrary.open()` | 2.0 |
| iOS | ✅ 完全支持 | `DynamicLibrary.process()` (静态链接) 或 Framework | 2.0 |
| macOS | ✅ 完全支持 | `DynamicLibrary.open()` / `.process()` | 2.0 |
| Linux | ✅ 完全支持 | `DynamicLibrary.open()` | 2.0 |
| Windows | ✅ 完全支持 | `DynamicLibrary.open()` | 2.0 |
| Web | ❌ 不支持 | N/A | N/A |

### 重要版本变更说明

#### Flutter 2.0 / Dart 2.12 (2021-03)
- `dart:ffi` 从预览版升级为稳定版
- 引入空安全支持，所有 FFI 类型需要空安全兼容
- `Pointer` 类型语义变更

#### Flutter 2.2 / Dart 2.13 (2021-05)
- 新增 `Array<T>` 类型，支持固定大小数组
- 新增 `Union` 类型支持
- 引入 `AbiSpecificInteger` 系列类型 (`Int`, `Long`, `Size` 等)

#### Flutter 3.0 / Dart 2.17 (2022-05)
- FFI 性能显著提升
- 改进的内存管理
- 更好的平台兼容性

#### Flutter 3.10 / Dart 3.0 (2023-05)
- 引入 `NativeCallable` 用于创建 C 可调用的 Dart 函数
- 新增 `NativeCallable.listener` 用于异步回调
- 改进的 finalizer 支持

#### Flutter 3.16 / Dart 3.2 (2023-11)
- `@Native<T>()` 注解正式引入
- 构建钩子 (Build Hooks) 预览
- 简化的外部函数声明语法

#### Flutter 3.22 / Dart 3.4 (2024-05)
- Native Assets 正式支持
- 自动化原生代码编译和打包
- `@DefaultAsset()` 注解支持

---

## 创建 Flutter FFI 库教程

### 步骤 1: 创建 Flutter Plugin 项目

```bash
flutter create --template=plugin --platforms=android,ios flutter_vips
cd flutter_vips
```

### 步骤 2: 项目结构配置

推荐的项目结构：

```
flutter_vips/
├── lib/
│   ├── flutter_vips.dart          # 公共 API
│   └── src/
│       ├── bindings/
│       │   └── vips_bindings.dart  # FFI 绑定 (可由 ffigen 生成)
│       ├── vips_library.dart       # 库加载逻辑
│       └── vips_image.dart         # 高级封装
├── src/                            # 原生代码 (可选)
├── android/
├── ios/
└── pubspec.yaml
```

### 步骤 3: 配置 pubspec.yaml

```yaml
name: flutter_vips
description: Flutter FFI bindings for libvips image processing library.
version: 0.0.1

environment:
  sdk: '>=3.0.0 <4.0.0'        # 推荐 Dart 3.0+ 以获取 NativeCallable 支持
  flutter: '>=3.10.0'          # 推荐 Flutter 3.10+

dependencies:
  flutter:
    sdk: flutter
  ffi: ^2.1.0
  path: ^1.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  ffigen: ^11.0.0              # 自动生成 FFI 绑定

# ffigen 配置
ffigen:
  name: VipsBindings
  description: FFI bindings for libvips
  output: 'lib/src/bindings/vips_bindings.dart'
  headers:
    entry-points:
      - 'src/vips/vips.h'
    include-directives:
      - 'src/vips/**'
  preamble: |
    // 自动生成的 FFI 绑定
    // 不要手动编辑此文件
  comments:
    style: any
    length: full
```

### 步骤 4: 实现平台库加载

创建 `lib/src/vips_library.dart`：

```dart
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// 加载 libvips 动态库
DynamicLibrary loadVipsLibrary() {
  if (Platform.isAndroid) {
    // Android: 从 APK 的 lib 目录加载 .so 文件
    return DynamicLibrary.open('libvips.so');
  } else if (Platform.isIOS) {
    // iOS: 静态链接到主程序，使用 process()
    return DynamicLibrary.process();
  } else if (Platform.isMacOS) {
    // macOS: 从 Framework 或指定路径加载
    return DynamicLibrary.open('libvips.dylib');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('libvips.so.42');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('libvips-42.dll');
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

/// 延迟初始化的库实例
late final DynamicLibrary _vipsLib = loadVipsLibrary();

/// 获取 libvips 库实例
DynamicLibrary get vipsLibrary => _vipsLib;
```

### 步骤 5: 定义 FFI 类型和函数绑定

创建 `lib/src/bindings/vips_bindings.dart`（手动编写或使用 ffigen 生成）：

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// VipsImage 不透明类型
final class VipsImage extends Opaque {}

/// VipsOperation 不透明类型
final class VipsOperation extends Opaque {}

// 原生函数类型定义
typedef VipsInitNative = Int32 Function(Pointer<Utf8> argv0);
typedef VipsInit = int Function(Pointer<Utf8> argv0);

typedef VipsShutdownNative = Void Function();
typedef VipsShutdown = void Function();

typedef VipsImageNewFromFileNative = Pointer<VipsImage> Function(
  Pointer<Utf8> filename,
  Pointer<Void> options,
);
typedef VipsImageNewFromFile = Pointer<VipsImage> Function(
  Pointer<Utf8> filename,
  Pointer<Void> options,
);

typedef VipsImageWriteToFileNative = Int32 Function(
  Pointer<VipsImage> image,
  Pointer<Utf8> filename,
  Pointer<Void> options,
);
typedef VipsImageWriteToFile = int Function(
  Pointer<VipsImage> image,
  Pointer<Utf8> filename,
  Pointer<Void> options,
);

typedef GObjectUnrefNative = Void Function(Pointer<Void> object);
typedef GObjectUnref = void Function(Pointer<Void> object);

typedef VipsImageGetWidthNative = Int32 Function(Pointer<VipsImage> image);
typedef VipsImageGetWidth = int Function(Pointer<VipsImage> image);

typedef VipsImageGetHeightNative = Int32 Function(Pointer<VipsImage> image);
typedef VipsImageGetHeight = int Function(Pointer<VipsImage> image);

/// libvips 绑定类
class VipsBindings {
  final DynamicLibrary _lib;

  VipsBindings(this._lib);

  /// 初始化 libvips
  late final vipsInit = _lib
      .lookup<NativeFunction<VipsInitNative>>('vips_init')
      .asFunction<VipsInit>();

  /// 关闭 libvips
  late final vipsShutdown = _lib
      .lookup<NativeFunction<VipsShutdownNative>>('vips_shutdown')
      .asFunction<VipsShutdown>();

  /// 从文件加载图像
  late final imageNewFromFile = _lib
      .lookup<NativeFunction<VipsImageNewFromFileNative>>('vips_image_new_from_file')
      .asFunction<VipsImageNewFromFile>();

  /// 将图像写入文件
  late final imageWriteToFile = _lib
      .lookup<NativeFunction<VipsImageWriteToFileNative>>('vips_image_write_to_file')
      .asFunction<VipsImageWriteToFile>();

  /// 释放 GObject
  late final gObjectUnref = _lib
      .lookup<NativeFunction<GObjectUnrefNative>>('g_object_unref')
      .asFunction<GObjectUnref>();

  /// 获取图像宽度
  late final imageGetWidth = _lib
      .lookup<NativeFunction<VipsImageGetWidthNative>>('vips_image_get_width')
      .asFunction<VipsImageGetWidth>();

  /// 获取图像高度
  late final imageGetHeight = _lib
      .lookup<NativeFunction<VipsImageGetHeightNative>>('vips_image_get_height')
      .asFunction<VipsImageGetHeight>();
}
```

### 步骤 6: 创建高级封装 API

创建 `lib/src/vips_image.dart`：

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'vips_library.dart';
import 'bindings/vips_bindings.dart';

/// 全局 libvips 绑定实例
final VipsBindings _bindings = VipsBindings(vipsLibrary);

/// 初始化状态
bool _initialized = false;

/// 初始化 libvips
void initVips() {
  if (_initialized) return;

  final appName = 'flutter_vips'.toNativeUtf8();
  try {
    final result = _bindings.vipsInit(appName.cast());
    if (result != 0) {
      throw Exception('Failed to initialize libvips');
    }
    _initialized = true;
  } finally {
    calloc.free(appName);
  }
}

/// 关闭 libvips
void shutdownVips() {
  if (!_initialized) return;
  _bindings.vipsShutdown();
  _initialized = false;
}

/// VipsImage 高级封装
class VipsImageWrapper {
  final Pointer<VipsImage> _pointer;
  bool _disposed = false;

  VipsImageWrapper._(this._pointer);

  /// 检查指针是否为空
  bool get isNull => _pointer == nullptr;

  /// 从文件加载图像
  factory VipsImageWrapper.fromFile(String filename) {
    initVips();

    final filenamePtr = filename.toNativeUtf8();
    try {
      final imagePtr = _bindings.imageNewFromFile(
        filenamePtr,
        nullptr,
      );

      if (imagePtr == nullptr) {
        throw Exception('Failed to load image: $filename');
      }

      return VipsImageWrapper._(imagePtr);
    } finally {
      calloc.free(filenamePtr);
    }
  }

  /// 获取图像宽度
  int get width {
    _checkDisposed();
    return _bindings.imageGetWidth(_pointer);
  }

  /// 获取图像高度
  int get height {
    _checkDisposed();
    return _bindings.imageGetHeight(_pointer);
  }

  /// 将图像保存到文件
  void writeToFile(String filename) {
    _checkDisposed();

    final filenamePtr = filename.toNativeUtf8();
    try {
      final result = _bindings.imageWriteToFile(
        _pointer,
        filenamePtr,
        nullptr,
      );

      if (result != 0) {
        throw Exception('Failed to write image: $filename');
      }
    } finally {
      calloc.free(filenamePtr);
    }
  }

  /// 释放资源
  void dispose() {
    if (_disposed) return;
    _bindings.gObjectUnref(_pointer.cast());
    _disposed = true;
  }

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('VipsImage has been disposed');
    }
  }
}
```

### 步骤 7: 创建公共 API

创建 `lib/flutter_vips.dart`：

```dart
library flutter_vips;

export 'src/vips_image.dart' show VipsImageWrapper, initVips, shutdownVips;
```

---

## libvips 特定集成指南

### Android 集成

#### 1. 放置预编译库

将预编译的 libvips.so 文件放入相应目录：

```
android/
└── src/
    └── main/
        └── jniLibs/
            ├── arm64-v8a/
            │   └── libvips.so
            ├── armeabi-v7a/
            │   └── libvips.so
            └── x86_64/
                └── libvips.so
```

#### 2. 配置 build.gradle

在 `android/build.gradle` 中添加：

```groovy
android {
    defaultConfig {
        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a', 'x86_64'
        }
    }

    sourceSets {
        main {
            jniLibs.srcDirs = ['src/main/jniLibs']
        }
    }
}
```

### iOS 集成

#### 1. 创建 XCFramework

使用预编译的 libvips 创建 XCFramework：

```bash
xcodebuild -create-xcframework \
    -library libvips-ios-arm64.a -headers include/ \
    -library libvips-simulator-arm64.a -headers include/ \
    -output libvips.xcframework
```

#### 2. 配置 Podspec

在 `ios/flutter_vips.podspec` 中添加：

```ruby
Pod::Spec.new do |s|
  s.name             = 'flutter_vips'
  s.version          = '0.0.1'
  s.summary          = 'Flutter FFI bindings for libvips'
  s.homepage         = 'https://example.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'

  # 静态库配置
  s.vendored_libraries = 'Libraries/libvips.a'
  s.libraries = 'vips'

  # 或使用 XCFramework
  # s.vendored_frameworks = 'Frameworks/libvips.xcframework'

  # 依赖系统库
  s.frameworks = 'CoreFoundation', 'CoreGraphics', 'ImageIO'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/Libraries/include"'
  }

  s.swift_version = '5.0'
end
```

### 使用 ffigen 自动生成绑定

#### 1. 安装 ffigen

```bash
dart pub add --dev ffigen
```

#### 2. 创建 ffigen 配置文件

创建 `ffigen.yaml`：

```yaml
name: VipsBindings
description: Auto-generated FFI bindings for libvips
output: 'lib/src/bindings/vips_bindings_generated.dart'

headers:
  entry-points:
    - 'src/vips/vips.h'
  include-directives:
    - 'src/vips/**/*.h'

compiler-opts:
  - '-I/path/to/vips/include'
  - '-I/path/to/glib/include'

functions:
  include:
    - 'vips_.*'
    - 'g_object_unref'
  exclude:
    - '.*_get_type'

structs:
  include:
    - 'VipsImage'
    - 'VipsOperation'
    - 'VipsObject'

enums:
  include:
    - 'Vips.*'

typedefs:
  include:
    - 'VipsImage'
    - 'VipsOperation'

preamble: |
  // Auto-generated FFI bindings for libvips
  // DO NOT EDIT MANUALLY

comments:
  style: any
  length: full

sort: true

use-supported-typedefs: true
```

#### 3. 生成绑定

```bash
dart run ffigen
```

---

## 跨平台最佳实践

### 1. 平台检测和条件加载

```dart
import 'dart:ffi';
import 'dart:io';

DynamicLibrary? _cachedLibrary;

DynamicLibrary loadNativeLibrary() {
  if (_cachedLibrary != null) return _cachedLibrary!;

  _cachedLibrary = switch (Platform.operatingSystem) {
    'android' => DynamicLibrary.open('libvips.so'),
    'ios' => DynamicLibrary.process(),
    'macos' => DynamicLibrary.open('libvips.42.dylib'),
    'linux' => DynamicLibrary.open('libvips.so.42'),
    'windows' => DynamicLibrary.open('libvips-42.dll'),
    _ => throw UnsupportedError('Unsupported platform'),
  };

  return _cachedLibrary!;
}
```

### 2. 内存管理最佳实践

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// 使用 Finalizer 自动释放资源 (Dart 3.0+)
final _imageFinalizer = NativeFinalizer(
  _bindings.addresses.g_object_unref.cast(),
);

class SafeVipsImage implements Finalizable {
  final Pointer<VipsImage> _pointer;

  SafeVipsImage._(this._pointer) {
    // 注册 Finalizer，GC 时自动释放
    _imageFinalizer.attach(this, _pointer.cast(), detach: this);
  }

  void dispose() {
    // 手动释放时取消 Finalizer
    _imageFinalizer.detach(this);
    _bindings.gObjectUnref(_pointer.cast());
  }
}
```

### 3. 异步操作处理

```dart
import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

/// 使用 Isolate 进行耗时的图像处理
Future<Uint8List> processImageAsync(String inputPath, String operation) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(
    _processImageIsolate,
    _ProcessRequest(inputPath, operation, receivePort.sendPort),
  );

  final result = await receivePort.first as Uint8List;
  return result;
}

class _ProcessRequest {
  final String inputPath;
  final String operation;
  final SendPort sendPort;

  _ProcessRequest(this.inputPath, this.operation, this.sendPort);
}

void _processImageIsolate(_ProcessRequest request) {
  // 在 Isolate 中重新初始化 libvips
  initVips();

  try {
    final image = VipsImageWrapper.fromFile(request.inputPath);
    // 执行图像处理操作...
    // ...
    image.dispose();
  } finally {
    shutdownVips();
  }
}
```

### 4. 错误处理

```dart
/// 获取 libvips 错误信息
String? getVipsError() {
  final errorPtr = _bindings.vipsErrorBuffer();
  if (errorPtr == nullptr) return null;
  return errorPtr.cast<Utf8>().toDartString();
}

/// 清除错误缓冲区
void clearVipsError() {
  _bindings.vipsErrorClear();
}

/// 带错误处理的图像操作
VipsImageWrapper loadImageWithErrorHandling(String path) {
  clearVipsError();

  final image = VipsImageWrapper.fromFile(path);
  if (image.isNull) {
    final error = getVipsError();
    throw VipsException('Failed to load image: ${error ?? "Unknown error"}');
  }

  return image;
}

class VipsException implements Exception {
  final String message;
  VipsException(this.message);

  @override
  String toString() => 'VipsException: $message';
}
```

---

## 版本兼容性最佳实践

### 向后兼容的 pubspec.yaml 配置

```yaml
environment:
  # 支持尽可能早的 Flutter 版本
  sdk: '>=2.17.0 <4.0.0'
  flutter: '>=3.0.0'

# 针对不同功能提供可选依赖
dependencies:
  flutter:
    sdk: flutter
  ffi: ^2.0.0

# 条件导入示例见下文
```

### 使用条件导入支持新旧 API

```dart
// lib/src/native_callable_stub.dart (旧版本回退)
class NativeCallableStub<T extends Function> {
  NativeCallableStub.listener(T callback) {
    throw UnsupportedError('NativeCallable requires Dart 3.0+');
  }

  Pointer get nativeFunction => throw UnsupportedError('NativeCallable requires Dart 3.0+');

  void close() {}
}

// lib/src/native_callable_impl.dart (Dart 3.0+)
export 'dart:ffi' show NativeCallable;

// lib/src/native_callable.dart (条件导入)
export 'native_callable_stub.dart'
    if (dart.library.ffi) 'native_callable_impl.dart';
```

---

## 附录

### A. 完整的 Flutter 版本与 Dart SDK 版本对照表

| Flutter 版本 | Dart SDK 版本 | 发布日期 | FFI 支持等级 |
|-------------|--------------|---------|-------------|
| 1.12.x | 2.6.x | 2019-12 | 预览版 |
| 1.17.x | 2.8.x | 2020-05 | 预览版 |
| 1.20.x | 2.9.x | 2020-08 | 预览版 |
| 1.22.x | 2.10.x | 2020-10 | 预览版 |
| 2.0.x | 2.12.x | 2021-03 | ✅ 稳定版 |
| 2.2.x | 2.13.x | 2021-05 | ✅ Array/Union |
| 2.5.x | 2.14.x | 2021-09 | ✅ 改进 |
| 2.10.x | 2.16.x | 2022-02 | ✅ 改进 |
| 3.0.x | 2.17.x | 2022-05 | ✅ 性能优化 |
| 3.3.x | 2.18.x | 2022-08 | ✅ ObjC 互操作 |
| 3.7.x | 2.19.x | 2023-01 | ✅ 改进 |
| 3.10.x | 3.0.x | 2023-05 | ✅ NativeCallable |
| 3.13.x | 3.1.x | 2023-08 | ✅ 实验性 Native Assets |
| 3.16.x | 3.2.x | 2023-11 | ✅ Build Hooks 预览 |
| 3.19.x | 3.3.x | 2024-02 | ✅ 改进 |
| 3.22.x | 3.4.x | 2024-05 | ✅ Native Assets GA |
| 3.24.x | 3.5.x | 2024-08 | ✅ 最新 |

### B. 参考资源

- [Dart FFI 官方文档](https://dart.dev/guides/libraries/c-interop)
- [Flutter 平台集成 - C 互操作](https://docs.flutter.dev/platform-integration/android/c-interop)
- [ffigen 包](https://pub.dev/packages/ffigen)
- [ffi 包](https://pub.dev/packages/ffi)
- [libvips 官方文档](https://www.libvips.org/API/current/)

---

*文档生成时间: 2025-12-06*
