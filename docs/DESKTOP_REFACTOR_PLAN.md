# libvips_ffi 桌面端重构方案

## 概述

本方案旨在将 libvips_ffi 扩展到桌面平台 (macOS, Windows, Linux)，同时支持纯 Dart 和 Flutter 项目。

## 设计目标

1. **纯 Dart 支持**: 桌面用户可以使用纯 Dart FFI 绑定，无需依赖 Flutter
2. **Flutter 兼容**: Flutter 项目可以无缝使用桌面绑定
3. **包大小控制**: 避免触发 pub.dev 的 100MB (gzip) / 256MB (未压缩) 限制
4. **多版本支持**:
   - 预编译版本: 内置 libvips 动态库
   - 系统依赖版本: 使用系统安装的 libvips
   - 动态下载版本: 运行时下载库文件

## 包架构

### 仓库结构

```
libvips_ffi/                          # 仓库根目录
├── melos.yaml                        # melos 配置
├── pubspec.yaml                      # 根 pubspec (workspace)
├── packages/
│   ├── libvips_ffi_core/             # 纯 Dart FFI 核心
│   ├── libvips_ffi/                  # Flutter 移动端 (Android/iOS)
│   ├── libvips_ffi_loader/           # 动态下载器
│   ├── libvips_ffi_macos/            # macOS 预编译
│   ├── libvips_ffi_windows/          # Windows 预编译
│   ├── libvips_ffi_linux/            # Linux 预编译
│   └── libvips_ffi_desktop/          # 桌面元包
├── examples/
│   ├── flutter_example/              # Flutter 示例
│   └── dart_example/                 # 纯 Dart 示例
├── docs/
└── tools/
```

### 依赖关系图

```
                    ┌─────────────────────┐
                    │  libvips_ffi_core   │  (纯 Dart)
                    └─────────┬───────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌─────────────────┐
│ libvips_ffi   │   │libvips_ffi_loader│   │ Desktop Packages│
│ (Flutter移动) │   │   (动态下载)     │   │ (macos/win/linux)│
└───────────────┘   └─────────────────┘   └────────┬────────┘
                                                   │
                                          ┌────────▼────────┐
                                          │libvips_ffi_desktop│
                                          │    (元包)        │
                                          └─────────────────┘
```

---

## 各包详细设计

### 1. libvips_ffi_core (纯 Dart FFI 核心)

**职责**: 提供纯 Dart 的 FFI 绑定，无 Flutter 依赖

**结构**:
```
libvips_ffi_core/
├── lib/
│   ├── libvips_ffi_core.dart
│   └── src/
│       ├── bindings/
│       │   └── vips_bindings_generated.dart
│       ├── vips_ffi_types.dart
│       ├── vips_variadic_bindings.dart
│       ├── vips_core.dart
│       ├── vips_image.dart
│       ├── vips_enums.dart
│       ├── vips_isolate.dart           # 纯 Dart Isolate API
│       ├── extensions/
│       └── loader/
│           └── library_loader.dart     # 库加载抽象
└── pubspec.yaml
```

**pubspec.yaml**:
```yaml
name: libvips_ffi_core
description: Pure Dart FFI bindings for libvips. No Flutter dependency.
version: 1.0.0

environment:
  sdk: ^3.0.0
  # 无 flutter 约束

dependencies:
  ffi: ^2.1.0
```

**核心 API - 库加载抽象**:

```dart
/// 平台枚举
enum VipsPlatform {
  macos,
  windows,
  linux,
  android,
  ios,
}

/// CPU 架构枚举
enum VipsArch {
  arm64,
  x64,
  arm,  // 32-bit ARM (Android)
}

/// 抽象库加载器接口
abstract class VipsLibraryLoader {
  DynamicLibrary load();
  bool isAvailable();
}

/// 系统库加载器
class SystemVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    if (Platform.isMacOS) {
      // 尝试 homebrew 路径
      final paths = [
        '/opt/homebrew/lib/libvips.dylib',      // Apple Silicon
        '/usr/local/lib/libvips.dylib',         // Intel
        'libvips.dylib',                        // 系统路径
      ];
      for (final path in paths) {
        try {
          return DynamicLibrary.open(path);
        } catch (_) {}
      }
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libvips.so.42');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('libvips-42.dll');
    }
    throw UnsupportedError('Unsupported platform');
  }
  
  @override
  bool isAvailable() {
    try {
      load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// 自定义路径加载器
class PathVipsLoader implements VipsLibraryLoader {
  final String libraryPath;
  PathVipsLoader(this.libraryPath);
  
  @override
  DynamicLibrary load() => DynamicLibrary.open(libraryPath);
  
  @override
  bool isAvailable() => File(libraryPath).existsSync();
}
```

**初始化 API**:

```dart
// 使用自定义加载器初始化
void initVipsWithLoader(VipsLibraryLoader loader, [String appName = 'libvips_ffi']);

// 使用 DynamicLibrary 直接初始化
void initVipsWithLibrary(DynamicLibrary library, [String appName = 'libvips_ffi']);

// 使用系统库初始化 (便捷方法)
void initVipsSystem([String appName = 'libvips_ffi']) {
  initVipsWithLoader(SystemVipsLoader(), appName);
}
```

---

### 2. libvips_ffi (Flutter 移动端)

**职责**: 为 Flutter 移动端 (Android/iOS) 提供预编译库

**结构**:
```
libvips_ffi/
├── lib/
│   ├── libvips_ffi.dart
│   └── src/
│       ├── mobile_loader.dart          # 移动端库加载
│       └── vips_compute.dart           # Flutter compute API
├── android/
│   └── (预编译 .so 文件)
├── ios/
│   └── (预编译 .xcframework)
└── pubspec.yaml
```

**pubspec.yaml**:
```yaml
name: libvips_ffi
description: Flutter FFI bindings for libvips - Android & iOS.
version: 1.0.0

environment:
  sdk: ^3.0.0
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  libvips_ffi_core: ^1.0.0

flutter:
  plugin:
    platforms:
      android:
        ffiPlugin: true
      ios:
        ffiPlugin: true
```

---

### 3. libvips_ffi_loader (动态下载器)

**职责**: 提供回调接口让开发者自行实现库下载逻辑

**设计理念**: 不控制下载过程，只提供回调接口

**结构**:
```
libvips_ffi_loader/
├── lib/
│   ├── libvips_ffi_loader.dart
│   └── src/
│       ├── loader_types.dart
│       └── vips_loader.dart
└── pubspec.yaml
```

**核心 API**:

```dart
/// 库请求信息
class VipsLibraryRequest {
  /// 当前平台
  final VipsPlatform platform;
  
  /// CPU 架构
  final VipsArch arch;
  
  /// 推荐的 libvips 版本
  final String recommendedVersion;
  
  /// 建议的缓存目录
  final String suggestedCacheDir;
  
  /// 获取平台对应的库文件扩展名
  String get libraryExtension {
    switch (platform) {
      case VipsPlatform.macos:
        return 'dylib';
      case VipsPlatform.windows:
        return 'dll';
      case VipsPlatform.linux:
        return 'so';
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}

/// 库提供者回调 - 由开发者实现
/// 返回库文件的绝对路径
typedef VipsLibraryProvider = Future<String> Function(
  VipsLibraryRequest request,
);

/// 加载状态
enum VipsLoadingState {
  checking,
  downloading,
  extracting,
  loading,
  ready,
  error,
}

/// 加载状态回调
typedef VipsLoadingCallback = void Function(VipsLoadingState state);

/// 加载器
class VipsLoader {
  /// 使用自定义提供者初始化
  static Future<void> init({
    required VipsLibraryProvider provider,
    VipsLoadingCallback? onStateChanged,
    String appName = 'libvips_ffi',
  }) async {
    final request = VipsLibraryRequest(
      platform: _getCurrentPlatform(),
      arch: _getCurrentArch(),
      recommendedVersion: '8.16.0',
      suggestedCacheDir: await _getSuggestedCacheDir(),
    );
    
    onStateChanged?.call(VipsLoadingState.checking);
    
    final libraryPath = await provider(request);
    
    onStateChanged?.call(VipsLoadingState.loading);
    
    initVipsWithLibrary(DynamicLibrary.open(libraryPath));
    
    onStateChanged?.call(VipsLoadingState.ready);
  }
}
```

**使用示例**:

```dart
// 开发者自行实现下载逻辑
Future<String> myLibraryProvider(VipsLibraryRequest request) async {
  final cacheDir = request.suggestedCacheDir;
  final libPath = '$cacheDir/libvips.${request.libraryExtension}';
  
  // 检查缓存
  if (await File(libPath).exists()) {
    return libPath;
  }
  
  // 从自己的 CDN 下载
  final url = 'https://my-cdn.com/libs/'
      '${request.platform.name}-${request.arch.name}/'
      'libvips.zip';
  await _downloadAndExtract(url, cacheDir);
  
  return libPath;
}

// 使用
await VipsLoader.init(
  provider: myLibraryProvider,
  onStateChanged: (state) => print('State: $state'),
);
```

**pubspec.yaml**:
```yaml
name: libvips_ffi_loader
description: Dynamic library loader for libvips_ffi with callback-based download.
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  libvips_ffi_core: ^1.0.0
  path: ^1.8.0
```

---

### 4. 桌面预编译包 (libvips_ffi_macos/windows/linux)

**职责**: 为各桌面平台提供预编译的 libvips 库

**结构 (以 macOS 为例)**:
```
libvips_ffi_macos/
├── lib/
│   ├── libvips_ffi_macos.dart
│   └── src/
│       └── macos_loader.dart
├── macos/
│   └── libvips_ffi_macos.podspec
└── native/
    ├── arm64/
    │   └── libvips.dylib
    └── x64/
        └── libvips.dylib
```

**pubspec.yaml**:
```yaml
name: libvips_ffi_macos
description: Pre-compiled libvips for macOS.
version: 1.0.0

environment:
  sdk: ^3.0.0
  flutter: '>=3.10.0'

dependencies:
  libvips_ffi_core: ^1.0.0

flutter:
  plugin:
    platforms:
      macos:
        ffiPlugin: true
```

---

### 5. libvips_ffi_desktop (桌面元包)

**职责**: 便捷包，自动引入所有桌面平台支持

**pubspec.yaml**:
```yaml
name: libvips_ffi_desktop
description: Meta package for libvips_ffi desktop support.
version: 1.0.0

environment:
  sdk: ^3.0.0
  flutter: '>=3.10.0'

dependencies:
  libvips_ffi_core: ^1.0.0
  libvips_ffi_macos: ^1.0.0
  libvips_ffi_windows: ^1.0.0
  libvips_ffi_linux: ^1.0.0
```

---

## Melos 配置

```yaml
name: libvips_ffi
repository: https://github.com/CaiJingLong/libvips_ffi

packages:
  - packages/**
  - examples/**

command:
  version:
    linkToCommits: true
    workspaceChangelog: true

  bootstrap:
    usePubspecOverrides: true

scripts:
  analyze:
    run: melos exec -- dart analyze .
    description: Analyze all packages

  format:
    run: melos exec -- dart format .
    description: Format all packages

  test:
    run: melos exec -- dart test
    description: Run tests in all packages
    packageFilters:
      dirExists: test

  publish:dry:
    run: melos exec -- dart pub publish --dry-run
    description: Dry run publish for all packages

  ffigen:
    run: melos exec -- dart run ffigen
    description: Generate FFI bindings
    packageFilters:
      fileExists: ffigen.yaml
```

---

## 使用场景

### 场景 1: Flutter 移动端 (现有用户)

```yaml
dependencies:
  libvips_ffi: ^1.0.0
```

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

void main() {
  initVips();
  // 使用 libvips
}
```

### 场景 2: Flutter 全平台

```yaml
dependencies:
  libvips_ffi: ^1.0.0           # 移动端
  libvips_ffi_desktop: ^1.0.0   # 桌面端
```

### 场景 3: 纯 Dart 桌面应用 (系统依赖)

```yaml
dependencies:
  libvips_ffi_core: ^1.0.0
```

```dart
import 'package:libvips_ffi_core/libvips_ffi_core.dart';

void main() {
  // 使用系统安装的 libvips
  initVipsSystem();
  // 或指定路径
  initVipsWithLoader(PathVipsLoader('/path/to/libvips.dylib'));
}
```

### 场景 4: 动态下载

```yaml
dependencies:
  libvips_ffi_loader: ^1.0.0
```

```dart
import 'package:libvips_ffi_loader/libvips_ffi_loader.dart';

Future<void> main() async {
  await VipsLoader.init(
    provider: (request) async {
      // 自定义下载逻辑
      return '/path/to/downloaded/libvips.dylib';
    },
  );
}
```

---

## 迁移计划

### Phase 1: 基础架构
1. 创建 melos 工作区
2. 提取 `libvips_ffi_core` 包
3. 重构现有 `libvips_ffi` 依赖 core 包

### Phase 2: 动态加载
4. 实现 `libvips_ffi_loader` 包
5. 添加系统库加载支持

### Phase 3: 桌面预编译
6. 创建桌面平台包结构
7. 配置 CI 编译 libvips
8. 发布桌面预编译包

### Phase 4: 文档和示例
9. 更新文档
10. 添加各场景示例

---

## 待定事项

- [ ] 桌面端预编译库的来源 (自行编译 vs 官方预编译)
- [ ] CI/CD 配置
- [ ] 版本号策略 (是否所有包同步版本)
