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

## 安装

在你的项目 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  libvips_ffi:
    git:
      url: https://github.com/CaiJingLong/libvips_ffi
      path: libvips_ffi
```

## 使用示例

```dart
import 'package:libvips_ffi/libvips_ffi.dart';

void main() {
  // 初始化 libvips（首次使用时会自动调用）
  initVips();

  // 查看版本
  print('libvips version: $vipsVersionString');

  // 加载图片
  final image = VipsImageWrapper.fromFile('/path/to/image.jpg');

  // 获取图片信息
  print('Size: ${image.width}x${image.height}');
  print('Bands: ${image.bands}');

  // 保存为其他格式
  image.writeToFile('/path/to/output.png');

  // 或导出为字节数据
  final pngBytes = image.writeToBuffer('.png');

  // 使用完记得释放资源
  image.dispose();

  // 全部处理完成后（可选）关闭 libvips
  shutdownVips();
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
