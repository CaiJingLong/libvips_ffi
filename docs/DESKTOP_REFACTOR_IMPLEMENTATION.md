# libvips_ffi 桌面端重构实施指南

## 前置条件

- Dart SDK >= 3.0.0
- Flutter SDK >= 3.10.0 (仅 Flutter 包需要)
- melos (`dart pub global activate melos`)

---

## Phase 1: 基础架构

### 1.1 初始化 melos 工作区

```bash
# 在仓库根目录创建 melos.yaml
# 创建 packages 目录结构
mkdir -p packages/{libvips_ffi_core,libvips_ffi,libvips_ffi_loader}
mkdir -p packages/{libvips_ffi_macos,libvips_ffi_windows,libvips_ffi_linux}
mkdir -p packages/libvips_ffi_desktop
mkdir -p examples/{flutter_example,dart_example}
```

### 1.2 创建根 pubspec.yaml

```yaml
# /pubspec.yaml
name: libvips_ffi_workspace
publish_to: none

environment:
  sdk: ^3.0.0
```

### 1.3 创建 melos.yaml

```yaml
# /melos.yaml
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

### 1.4 提取 libvips_ffi_core

**需要从现有 `libvips_ffi` 包中提取的文件：**

| 源文件 | 目标位置 | 修改说明 |
|--------|----------|----------|
| `lib/src/bindings/vips_bindings_generated.dart` | `packages/libvips_ffi_core/lib/src/bindings/` | 无需修改 |
| `lib/src/vips_ffi_types.dart` | `packages/libvips_ffi_core/lib/src/` | 无需修改 |
| `lib/src/vips_variadic_bindings.dart` | `packages/libvips_ffi_core/lib/src/` | 修改 import |
| `lib/src/vips_core.dart` | `packages/libvips_ffi_core/lib/src/` | 修改 import，移除全局 vipsBindings |
| `lib/src/vips_image.dart` | `packages/libvips_ffi_core/lib/src/` | 修改 import |
| `lib/src/vips_enums.dart` | `packages/libvips_ffi_core/lib/src/` | 无需修改 |
| `lib/src/vips_pointer_manager.dart` | `packages/libvips_ffi_core/lib/src/` | 无需修改 |
| `lib/src/vips_isolate.dart` | `packages/libvips_ffi_core/lib/src/` | 移除 Flutter 依赖 |
| `lib/src/extensions/*` | `packages/libvips_ffi_core/lib/src/extensions/` | 修改 import |
| `ffigen.yaml` | `packages/libvips_ffi_core/` | 无需修改 |

**需要新建的文件：**

1. `packages/libvips_ffi_core/lib/src/loader/library_loader.dart` - 库加载抽象
2. `packages/libvips_ffi_core/lib/src/platform_types.dart` - 平台/架构枚举
3. `packages/libvips_ffi_core/lib/libvips_ffi_core.dart` - 主入口

### 1.5 libvips_ffi_core 目录结构

```
packages/libvips_ffi_core/
├── lib/
│   ├── libvips_ffi_core.dart
│   └── src/
│       ├── bindings/
│       │   └── vips_bindings_generated.dart
│       ├── extensions/
│       │   ├── vips_color_extension.dart
│       │   ├── vips_filter_extension.dart
│       │   ├── vips_io_extension.dart
│       │   ├── vips_transform_extension.dart
│       │   └── vips_utility_extension.dart
│       ├── loader/
│       │   └── library_loader.dart
│       ├── platform_types.dart
│       ├── vips_core.dart
│       ├── vips_enums.dart
│       ├── vips_ffi_types.dart
│       ├── vips_image.dart
│       ├── vips_isolate.dart
│       ├── vips_pointer_manager.dart
│       └── vips_variadic_bindings.dart
├── pubspec.yaml
└── ffigen.yaml
```

### 1.6 libvips_ffi_core/pubspec.yaml

```yaml
name: libvips_ffi_core
description: Pure Dart FFI bindings for libvips image processing library. No Flutter dependency.
version: 1.0.0
homepage: https://github.com/CaiJingLong/libvips_ffi
repository: https://github.com/CaiJingLong/libvips_ffi
issue_tracker: https://github.com/CaiJingLong/libvips_ffi/issues

topics:
  - image
  - image-processing
  - ffi
  - libvips

environment:
  sdk: ^3.0.0

dependencies:
  ffi: ^2.1.0

dev_dependencies:
  ffigen: ^16.0.0
  lints: ^4.0.0
  test: ^1.24.0
```

### 1.7 关键代码修改

#### platform_types.dart (新建)

```dart
/// 支持的平台
enum VipsPlatform {
  macos('macos', 'dylib'),
  windows('windows', 'dll'),
  linux('linux', 'so'),
  android('android', 'so'),
  ios('ios', '');

  final String name;
  final String libraryExtension;

  const VipsPlatform(this.name, this.libraryExtension);

  /// 获取当前平台
  static VipsPlatform get current {
    if (Platform.isMacOS) return VipsPlatform.macos;
    if (Platform.isWindows) return VipsPlatform.windows;
    if (Platform.isLinux) return VipsPlatform.linux;
    if (Platform.isAndroid) return VipsPlatform.android;
    if (Platform.isIOS) return VipsPlatform.ios;
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  /// 是否为桌面平台
  bool get isDesktop => this == macos || this == windows || this == linux;

  /// 是否为移动平台
  bool get isMobile => this == android || this == ios;
}

/// CPU 架构
enum VipsArch {
  arm64('arm64'),
  x64('x64'),
  arm('arm'),
  x86('x86');

  final String name;

  const VipsArch(this.name);

  /// 获取当前架构
  static VipsArch get current {
    // 注意: Dart 目前没有直接获取 CPU 架构的 API
    // 需要通过 Platform.version 或其他方式推断
    // 这里提供一个简化实现
    final version = Platform.version.toLowerCase();
    if (version.contains('arm64') || version.contains('aarch64')) {
      return VipsArch.arm64;
    }
    if (version.contains('arm')) {
      return VipsArch.arm;
    }
    if (version.contains('x64') || version.contains('x86_64') || version.contains('amd64')) {
      return VipsArch.x64;
    }
    return VipsArch.x64; // 默认假设 x64
  }
}
```

#### library_loader.dart (新建)

```dart
import 'dart:ffi';
import 'dart:io';

import '../platform_types.dart';

/// 抽象库加载器接口
abstract class VipsLibraryLoader {
  /// 加载 libvips 动态库
  DynamicLibrary load();

  /// 检查库是否可用
  bool isAvailable();
}

/// 系统库加载器 - 从系统路径加载 libvips
class SystemVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    final platform = VipsPlatform.current;

    switch (platform) {
      case VipsPlatform.macos:
        return _loadMacOS();
      case VipsPlatform.linux:
        return DynamicLibrary.open('libvips.so.42');
      case VipsPlatform.windows:
        return DynamicLibrary.open('libvips-42.dll');
      default:
        throw UnsupportedError(
          'SystemVipsLoader does not support ${platform.name}. '
          'Use platform-specific loader for mobile.',
        );
    }
  }

  DynamicLibrary _loadMacOS() {
    final paths = [
      '/opt/homebrew/lib/libvips.dylib', // Apple Silicon Homebrew
      '/usr/local/lib/libvips.dylib', // Intel Homebrew
      '/opt/local/lib/libvips.dylib', // MacPorts
      'libvips.dylib', // 系统路径
    ];

    for (final path in paths) {
      try {
        return DynamicLibrary.open(path);
      } catch (_) {
        continue;
      }
    }

    throw StateError(
      'Could not find libvips on macOS. '
      'Install via: brew install vips',
    );
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

/// 直接使用 DynamicLibrary 的加载器
class DirectVipsLoader implements VipsLibraryLoader {
  final DynamicLibrary library;

  DirectVipsLoader(this.library);

  @override
  DynamicLibrary load() => library;

  @override
  bool isAvailable() => true;
}
```

#### vips_core.dart 修改

```dart
// 移除全局 vipsLibrary 依赖
// 改为通过初始化函数设置

import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

import 'bindings/vips_bindings_generated.dart';
import 'loader/library_loader.dart';

/// 全局 libvips 绑定实例 (延迟初始化)
VipsBindings? _vipsBindings;

/// 获取 libvips 绑定实例
/// 必须先调用 initVips* 系列函数
VipsBindings get vipsBindings {
  if (_vipsBindings == null) {
    throw StateError(
      'libvips not initialized. Call initVips(), initVipsWithLoader(), '
      'or initVipsWithLibrary() first.',
    );
  }
  return _vipsBindings!;
}

/// 是否已初始化
bool _initialized = false;

/// 使用系统库初始化 libvips (桌面端)
void initVipsSystem([String appName = 'libvips_ffi']) {
  initVipsWithLoader(SystemVipsLoader(), appName);
}

/// 使用自定义加载器初始化 libvips
void initVipsWithLoader(VipsLibraryLoader loader, [String appName = 'libvips_ffi']) {
  initVipsWithLibrary(loader.load(), appName);
}

/// 使用 DynamicLibrary 直接初始化 libvips
void initVipsWithLibrary(ffi.DynamicLibrary library, [String appName = 'libvips_ffi']) {
  if (_initialized) return;

  _vipsBindings = VipsBindings(library);

  final appNamePtr = appName.toNativeUtf8();
  try {
    final result = _vipsBindings!.vips_init(appNamePtr.cast());
    if (result != 0) {
      throw VipsException('Failed to initialize libvips: ${getVipsError()}');
    }
    _initialized = true;
  } finally {
    calloc.free(appNamePtr);
  }
}

// ... 其余代码保持不变 ...
```

---

## Phase 2: 动态加载器

### 2.1 libvips_ffi_loader 目录结构

```
packages/libvips_ffi_loader/
├── lib/
│   ├── libvips_ffi_loader.dart
│   └── src/
│       ├── loader_types.dart
│       └── vips_loader.dart
└── pubspec.yaml
```

### 2.2 loader_types.dart

```dart
import 'package:libvips_ffi_core/libvips_ffi_core.dart';

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

  VipsLibraryRequest({
    required this.platform,
    required this.arch,
    required this.recommendedVersion,
    required this.suggestedCacheDir,
  });

  /// 获取平台对应的库文件名
  String get libraryFileName {
    switch (platform) {
      case VipsPlatform.macos:
        return 'libvips.dylib';
      case VipsPlatform.windows:
        return 'libvips-42.dll';
      case VipsPlatform.linux:
        return 'libvips.so.42';
      default:
        throw UnsupportedError('Unsupported platform: ${platform.name}');
    }
  }
}

/// 加载状态
enum VipsLoadingState {
  /// 检查本地缓存
  checking,

  /// 下载中 (由开发者触发)
  downloading,

  /// 解压中 (由开发者触发)
  extracting,

  /// 加载库
  loading,

  /// 就绪
  ready,

  /// 错误
  error,
}

/// 库提供者回调
/// 返回库文件的绝对路径
typedef VipsLibraryProvider = Future<String> Function(VipsLibraryRequest request);

/// 加载状态回调
typedef VipsLoadingCallback = void Function(VipsLoadingState state);
```

### 2.3 vips_loader.dart

```dart
import 'dart:ffi';
import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';
import 'package:path/path.dart' as p;

import 'loader_types.dart';

/// 动态加载器
class VipsLoader {
  /// 使用自定义提供者初始化
  static Future<void> init({
    required VipsLibraryProvider provider,
    VipsLoadingCallback? onStateChanged,
    String appName = 'libvips_ffi',
  }) async {
    final request = VipsLibraryRequest(
      platform: VipsPlatform.current,
      arch: VipsArch.current,
      recommendedVersion: '8.16.0',
      suggestedCacheDir: await _getSuggestedCacheDir(),
    );

    onStateChanged?.call(VipsLoadingState.checking);

    final libraryPath = await provider(request);

    if (!File(libraryPath).existsSync()) {
      onStateChanged?.call(VipsLoadingState.error);
      throw StateError('Library file not found: $libraryPath');
    }

    onStateChanged?.call(VipsLoadingState.loading);

    initVipsWithLibrary(DynamicLibrary.open(libraryPath), appName);

    onStateChanged?.call(VipsLoadingState.ready);
  }

  static Future<String> _getSuggestedCacheDir() async {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';

    final cacheDir = p.join(home, '.cache', 'libvips_ffi');

    final dir = Directory(cacheDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    return cacheDir;
  }
}
```

---

## Phase 3: 重构现有 libvips_ffi 包

### 3.1 修改 pubspec.yaml

```yaml
name: libvips_ffi
description: Flutter FFI bindings for libvips - Android & iOS.
version: 1.0.0
homepage: https://github.com/CaiJingLong/libvips_ffi

environment:
  sdk: ^3.0.0
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  libvips_ffi_core: ^1.0.0
  ffi: ^2.1.0

flutter:
  plugin:
    platforms:
      android:
        ffiPlugin: true
      ios:
        ffiPlugin: true
```

### 3.2 修改 lib/libvips_ffi.dart

```dart
/// Flutter FFI bindings for libvips image processing library.
library libvips_ffi;

// Re-export everything from core
export 'package:libvips_ffi_core/libvips_ffi_core.dart';

// Export Flutter-specific APIs
export 'src/vips_compute.dart' show VipsCompute, VipsComputeResult;
export 'src/mobile_loader.dart' show initVips;
```

### 3.3 新建 lib/src/mobile_loader.dart

```dart
import 'dart:ffi';
import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// 移动端库加载器
class MobileVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libvips.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    throw UnsupportedError(
      'MobileVipsLoader only supports Android and iOS. '
      'Use desktop packages for ${Platform.operatingSystem}.',
    );
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

/// 初始化 libvips (移动端便捷方法)
/// 保持与旧 API 兼容
void initVips([String appName = 'libvips_ffi']) {
  initVipsWithLoader(MobileVipsLoader(), appName);
}
```

---

## Phase 4: 桌面预编译包

### 4.1 libvips_ffi_macos 结构

```
packages/libvips_ffi_macos/
├── lib/
│   ├── libvips_ffi_macos.dart
│   └── src/
│       └── macos_loader.dart
├── macos/
│   ├── Classes/
│   │   └── LibvipsFfiMacosPlugin.swift  # 空实现
│   └── libvips_ffi_macos.podspec
└── pubspec.yaml
```

### 4.2 libvips_ffi_macos/pubspec.yaml

```yaml
name: libvips_ffi_macos
description: Pre-compiled libvips for macOS.
version: 1.0.0
homepage: https://github.com/CaiJingLong/libvips_ffi

environment:
  sdk: ^3.0.0
  flutter: '>=3.10.0'

dependencies:
  libvips_ffi_core: ^1.0.0

flutter:
  plugin:
    platforms:
      macos:
        pluginClass: LibvipsFfiMacosPlugin
        ffiPlugin: true
```

### 4.3 Windows 和 Linux 类似结构

参考 macOS 包结构，修改平台特定配置。

---

## Phase 5: 桌面元包

### 5.1 libvips_ffi_desktop/pubspec.yaml

```yaml
name: libvips_ffi_desktop
description: Meta package for libvips_ffi desktop support (macOS, Windows, Linux).
version: 1.0.0
homepage: https://github.com/CaiJingLong/libvips_ffi

environment:
  sdk: ^3.0.0
  flutter: '>=3.10.0'

dependencies:
  libvips_ffi_core: ^1.0.0
  libvips_ffi_macos: ^1.0.0
  libvips_ffi_windows: ^1.0.0
  libvips_ffi_linux: ^1.0.0
```

### 5.2 libvips_ffi_desktop/lib/libvips_ffi_desktop.dart

```dart
/// Desktop support for libvips_ffi.
library libvips_ffi_desktop;

export 'package:libvips_ffi_core/libvips_ffi_core.dart';

// Platform-specific exports will be handled by conditional imports
// when the native libraries are bundled
```

---

## 执行命令

```bash
# 1. 初始化 melos
melos bootstrap

# 2. 分析所有包
melos analyze

# 3. 格式化代码
melos format

# 4. 运行测试
melos test

# 5. 发布前检查
melos publish:dry
```

---

## 检查清单

### Phase 1 完成标准
- [ ] melos 工作区配置完成
- [ ] libvips_ffi_core 包提取完成
- [ ] 所有 import 路径修正
- [ ] `melos bootstrap` 成功
- [ ] `melos analyze` 无错误

### Phase 2 完成标准
- [ ] libvips_ffi_loader 包创建完成
- [ ] 回调接口设计完成
- [ ] 示例代码可运行

### Phase 3 完成标准
- [ ] libvips_ffi 依赖 core 包
- [ ] 移动端功能正常
- [ ] API 向后兼容

### Phase 4 完成标准
- [ ] 桌面平台包结构创建
- [ ] 预编译库集成 (可选)
- [ ] Flutter plugin 配置正确

### Phase 5 完成标准
- [ ] 元包创建完成
- [ ] 文档更新
- [ ] 示例项目可运行
