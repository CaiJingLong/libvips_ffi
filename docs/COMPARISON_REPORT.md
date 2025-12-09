# libvips Include 文件对比报告

## 对比来源

| 平台 | 来源 |
|------|------|
| Android | https://github.com/CaiJingLong/libvips-demo-android/tree/main/app/src/main/include |
| iOS | https://github.com/CaiJingLong/libvips_precompile_mobile/releases/download/ios-2025-11-29-3/libvips-ios-ios-2025-11-29-3.tar.xz |

## 总体对比结果

### 目录结构

| 指标 | Android | iOS |
|------|---------|-----|
| 目录数 | 13 | 13 |
| 文件数 | 382 | 382 |

**结论：目录结构完全一致**

### 文件差异统计

- **相同文件**: 376 个 (98.4%)
- **有差异的文件**: 6 个 (1.6%)
- **仅 Android 有的文件**: 0 个
- **仅 iOS 有的文件**: 0 个

## 核心 libvips 头文件

### vips/ 目录对比

| 指标 | Android | iOS |
|------|---------|-----|
| 文件数 | 48 | 48 |
| 有差异的文件 | 0 | 0 |

**✅ 核心 vips 头文件完全一致！这对 Flutter FFI 跨平台开发非常重要。**

## 有差异的文件详情

### 1. expat_config.h

**差异类型**: 平台特定配置

```diff
- #define HAVE_SYSCALL_GETRANDOM
+ /* #undef HAVE_SYSCALL_GETRANDOM */
```

**影响**: 
- Android 使用 `syscall(SYS_getrandom, ...)` 获取随机数
- iOS 不使用这个系统调用

### 2. ffi.h

**差异类型**: 平台特定的 FFI 配置

```diff
- #if 1
+ #if 0
  #define FFI_TYPE_LONGDOUBLE 4
```

以及 trampoline_table 相关配置的差异

**影响**:
- `long double` 类型在两个平台上的处理方式不同
- iOS 使用 trampoline table 机制，Android 不使用

### 3. glib-2.0/gio/gnetworking.h

**差异类型**: 网络相关头文件包含

```diff
+ #include <arpa/nameser_compat.h>
```

**影响**: iOS 需要额外的 DNS 解析兼容头文件

### 4. glib-2.0/glibconfig.h

**差异类型**: 平台特定的类型定义

```diff
- #undef GLIB_USING_SYSTEM_PRINTF
+ #define GLIB_USING_SYSTEM_PRINTF

- typedef signed long gint64;
- typedef unsigned long guint64;
+ G_GNUC_EXTENSION typedef signed long long gint64;
+ G_GNUC_EXTENSION typedef unsigned long long guint64;

- #define G_GINT64_CONSTANT(val)(val##L)
- #define G_GUINT64_CONSTANT(val)(val##UL)
+ #define G_GINT64_CONSTANT(val)(G_GNUC_EXTENSION (val##LL))
+ #define G_GUINT64_CONSTANT(val)(G_GNUC_EXTENSION (val##ULL))
```

**影响**: 
- 64位整数类型定义不同
- Android (aarch64): `long` = 64位
- iOS (arm64): 使用 `long long` 确保64位

### 5. pcre2.h

**差异类型**: 库版本不同

```diff
- #define PCRE2_MINOR           44
- #define PCRE2_DATE            2024-06-07
+ #define PCRE2_MINOR           42
+ #define PCRE2_DATE            2022-12-11
```

**影响**: 
- Android 使用 PCRE2 10.44 (2024年版)
- iOS 使用 PCRE2 10.42 (2022年版)
- 新版本有额外的宏定义如 `PCRE2_EXTRA_CASELESS_RESTRICT`

### 6. pcre2posix.h

**差异类型**: 库版本不同

- 版权年份和 API 版本差异
- 头文件保护宏差异

## Flutter FFI 跨平台使用分析

### ✅ 好消息

1. **核心 vips API 完全一致**
   - `vips/` 目录下的所有48个头文件在两个平台完全相同
   - 这意味着你可以使用相同的 FFI 绑定代码

2. **目录结构一致**
   - 不需要处理路径差异
   - 可以使用统一的 include 路径

3. **主要依赖库头文件一致**
   - png.h, jpeglib.h, webp/*.h 等完全相同
   - 图像处理相关的 FFI 绑定可以统一

### ⚠️ 需要注意

1. **类型定义差异 (glibconfig.h)**
   - `gint64/guint64` 类型定义不同
   - 在 Dart FFI 中使用 `Int64/Uint64` 即可自动适配
   - 不直接暴露 glib 类型给 Dart

2. **FFI 调用约定 (ffi.h)**
   - trampoline table 机制不同
   - 这是底层实现细节，不影响上层 API

3. **依赖库版本差异 (pcre2)**
   - PCRE2 版本不同可能导致某些功能不可用
   - 建议使用两个版本都支持的功能

### 🔧 建议的 FFI 绑定策略

```dart
// 推荐的跨平台 FFI 绑定方式

// 1. 只绑定 vips 核心 API
import 'dart:ffi';

// 2. 使用平台无关的类型
typedef VipsImage = Pointer<Void>;
typedef VipsOperation = Pointer<Void>;

// 3. 基础类型使用 Dart FFI 标准类型
// Int32, Int64, Uint32, Uint64, Double, Pointer<T>

// 4. 加载动态库时区分平台
DynamicLibrary loadVipsLibrary() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libvips.so');
  } else if (Platform.isIOS) {
    return DynamicLibrary.process(); // 静态链接到主程序
  }
  throw UnsupportedError('Unsupported platform');
}

// 5. 核心 API 示例
typedef VipsInitNative = Int32 Function();
typedef VipsInit = int Function();

typedef VipsImageNewFromFileNative = Pointer<VipsImage> Function(Pointer<Utf8>);
typedef VipsImageNewFromFile = Pointer<VipsImage> Function(Pointer<Utf8>);
```

### 📋 开发清单

- [x] 头文件结构一致 - 可以使用相同的 ffigen 配置
- [x] vips API 一致 - 可以编写统一的绑定代码
- [ ] 需要处理库加载方式的差异 (Android: .so, iOS: 静态链接)
- [ ] 建议统一依赖库版本以获得最佳兼容性
- [ ] 测试两个平台上的实际行为

## 附录：完整差异文件列表

| 文件 | Android 大小 | iOS 大小 | 差异类型 |
|------|-------------|----------|----------|
| expat_config.h | 3331 bytes | 3336 bytes | 平台配置 |
| ffi.h | 14602 bytes | 14602 bytes | 平台 FFI |
| glib-2.0/gio/gnetworking.h | 2092 bytes | 2124 bytes | 头文件包含 |
| glib-2.0/glibconfig.h | 5977 bytes | 6065 bytes | 类型定义 |
| pcre2.h | 48423 bytes | 47257 bytes | 版本差异 |
| pcre2posix.h | 7355 bytes | 7294 bytes | 版本差异 |

---

*报告生成时间: 2025-12-05*
