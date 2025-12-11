# libvips_ffi

本文件为 libvips_ffi 包的中文 README。
英文版本请参见：
[README.md](https://github.com/CaiJingLong/libvips_ffi/blob/main/libvips_ffi/README.md)

Flutter FFI 方式集成 [libvips](https://www.libvips.org/) —— 一个高性能的图像处理库。

## 版本说明

版本格式：`<插件版本>+<libvips版本>`

- 插件版本遵循 [语义化版本规范](https://semver.org/lang/zh-CN/)
- 构建元数据（如 `+8.16.0`）表示预编译的 libvips 版本

示例：`0.0.1+8.16.0` 表示插件版本 0.0.1，内置 libvips 8.16.0

## 特性

- **高性能图像处理**：基于 libvips，实现高效的图像处理能力
- **跨平台支持**：
  - Android: arm64-v8a, armeabi-v7a, x86_64（64位库已支持 Android 15+ 的 16KB 对齐）
  - iOS: arm64 真机和模拟器（iOS 12.0+，仅支持 Apple Silicon Mac 模拟器）
- **Dart 友好的 API**：易于在 Flutter 项目中集成和使用
- **自动生成 FFI 绑定**：通过 ffigen 自动生成绑定代码
- **平台特定库加载自动处理**：根据平台自动加载对应原生库
- **异步 API 支持**：通过 Dart Isolates 避免阻塞 UI 线程

## 库大小

| 平台 | 下载大小 |
|------|----------|
| Android (arm64-v8a) | ~3.20 MB |
| iOS (arm64) | ~7.48 MB |

详细的架构分解请参见：
[原生库大小](https://github.com/CaiJingLong/libvips_ffi/blob/main/docs/NATIVE_LIBRARY_SIZES_CN.md)

## 安装

在你的项目 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  libvips_ffi:
    git:
      url: https://github.com/CaiJingLong/libvips_ffi
      path: libvips_ffi
```

## 快速开始

### 基础用法（同步 API）

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

void main() {
  // 初始化 libvips（首次使用时会自动调用）
  initVips();

  // 查看版本
  print('libvips version: $vipsVersionString');

  // 加载图片
  final image = VipsImageWrapper.fromFile('/path/to/image.jpg');
  print('尺寸: ${image.width}x${image.height}');

  // 处理图片
  final resized = image.resize(0.5);  // 缩小到 50%
  final blurred = resized.gaussianBlur(3.0);

  // 保存结果
  blurred.writeToFile('/path/to/output.jpg');

  // 使用完记得释放资源（按逆序释放）
  blurred.dispose();
  resized.dispose();
  image.dispose();

  shutdownVips();
}
```

### Flutter 用法（异步 API - 推荐）

**重要：** 在 Flutter 中请使用异步 API，避免阻塞 UI 线程。

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

// 使用 VipsCompute 进行简单的一次性操作
Future<void> processImage() async {
  // 调整图片大小（在 isolate 中运行，不阻塞 UI）
  final result = await VipsCompute.resizeFile('input.jpg', 0.5);
  
  // result.data 包含处理后的图片字节数据
  // result.width, result.height 包含尺寸信息
  
  // 在 Flutter 中显示
  Image.memory(result.data);
}

// 更多操作示例
Future<void> moreExamples() async {
  // 缩略图（预览图最高效的方式）
  final thumb = await VipsCompute.thumbnailFile('input.jpg', 200);
  
  // 旋转
  final rotated = await VipsCompute.rotateFile('input.jpg', 90);
  
  // 模糊
  final blurred = await VipsCompute.blurFile('input.jpg', 5.0);
  
  // 自定义操作链
  final custom = await VipsCompute.processFile('input.jpg', (img) {
    final step1 = img.resize(0.5);
    final step2 = step1.gaussianBlur(2.0);
    step1.dispose();  // 清理中间结果
    return step2;
  });
}
```

### 常用操作

```dart
// 按比例缩放
final resized = image.resize(0.5);  // 原图的 50%

// 创建缩略图（保持宽高比）
final thumb = image.thumbnail(200);  // 宽度 200px

// 按角度旋转
final rotated = image.rotate(90);  // 90 度

// 裁剪区域
final cropped = image.crop(100, 100, 200, 200);  // left, top, width, height

// 翻转
final flippedH = image.flip(VipsDirection.horizontal);  // 水平翻转
final flippedV = image.flip(VipsDirection.vertical);    // 垂直翻转

// 模糊
final blurred = image.gaussianBlur(5.0);  // sigma 值

// 锐化
final sharpened = image.sharpen();

// 调整亮度（1.0 = 不变，>1 = 更亮）
final brighter = image.brightness(1.3);

// 调整对比度
final highContrast = image.contrast(1.5);

// 转换为灰度
final gray = image.colourspace(VipsInterpretation.bw);

// 智能裁剪（聚焦于有趣的区域）
final smartCropped = image.smartCrop(300, 300);

// 根据 EXIF 自动旋转
final autoRotated = image.autoRotate();
```

### 内存管理

```dart
// 使用完图片后务必释放
final image = VipsImageWrapper.fromFile('input.jpg');
try {
  final result = image.resize(0.5);
  try {
    result.writeToFile('output.jpg');
  } finally {
    result.dispose();
  }
} finally {
  image.dispose();
}

// 检查内存泄漏（仅开发阶段使用）
if (VipsPointerManager.instance.hasLeaks) {
  print(VipsPointerManager.instance.getLeakReport());
}
```

## 高级用法

对于需要直接访问 libvips 原生函数的高级用户，可以直接使用底层绑定：

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

// 访问底层绑定
final bindings = VipsBindings(vipsLibrary);

// 可以直接调用任意 libvips 函数
// bindings.vips_thumbnail(...);
```

## 重新生成 FFI 绑定

如果需要重新生成 FFI 绑定代码：

```bash
dart run ffigen --config ffigen.yaml
```

## 原生库构建 / 预编译位置说明（Android / iOS）

为了便于排查问题和确认来源，本项目中使用的原生库（native libraries）的原始构建/预编译位置如下。
这些预编译二进制由对应的上游仓库通过 GitHub Actions 自动构建并发布（见上文链接）。

上游构建仓库链接：
- Android: [MobiPkg/Compile 构建运行](https://github.com/MobiPkg/Compile/actions/runs/20085520935)
- iOS: [libvips_precompile_mobile 构建运行](https://github.com/CaiJingLong/libvips_precompile_mobile/actions/runs/19779932583)

- **Android**  
  原始的 Android 构建产物及相关构建配置位于：  
  `libvips_ffi/android/`  
  其中包含用于生成 Android 原生库的 Gradle 配置和源码等内容。

- **iOS**  
  预编译好的 iOS Framework 及相关配置位于：  
  `libvips_ffi/ios/Frameworks/`  
  以及 CocoaPods 规范文件：  
  `libvips_ffi/ios/libvips_ffi.podspec`  
  这些文件是 iOS 集成所依赖的预编译二进制和元数据。

## 免责声明

**本项目按"原样"提供，不提供任何形式的保证。** 维护者不保证任何维护周期、Bug 修复或功能更新。使用风险自负。

- 不保证对 Issue 或 Pull Request 的响应时间
- 不保证与未来 Flutter/Dart 版本的兼容性
- 不保证预编译原生库的安全更新

请在生产环境使用前自行评估风险。

## 许可证（License）

本项目的**主体代码**以 **Apache License 2.0** 授权发布。

部分代码来自上游项目，这些代码继续遵循其**原始许可证**，并未因本项目而改变授权条款。请参考对应上游源码文件以及随附的许可证文本，以了解适用于这些组件的具体授权条款。
