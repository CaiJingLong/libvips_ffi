import 'dart:ffi';
import 'dart:io';

import 'package:libvips_ffi_core/libvips_ffi_core.dart';
import 'package:path/path.dart' as p;

import 'loader_types.dart';

/// 推荐的 libvips 版本
const String recommendedVipsVersion = '8.16.0';

/// 动态加载器
///
/// 使用回调方式让开发者自行实现库的下载和管理逻辑。
class VipsLoader {
  /// 使用自定义提供者初始化 libvips
  ///
  /// [provider] 回调函数，返回库文件的绝对路径。
  /// 开发者在 provider 中自行实现：
  /// - 检查本地缓存
  /// - 下载库文件 (从自己的 CDN)
  /// - 解压 (如果需要)
  /// - 返回最终的 .dylib/.dll/.so 路径
  ///
  /// [onStateChanged] 可选的状态回调，用于显示加载进度。
  ///
  /// [appName] libvips 初始化时使用的应用名称。
  ///
  /// 示例:
  /// ```dart
  /// await VipsLoader.init(
  ///   provider: (request) async {
  ///     final cacheDir = request.suggestedCacheDir;
  ///     final libPath = '$cacheDir/${request.libraryFileName}';
  ///
  ///     if (await File(libPath).exists()) {
  ///       return libPath;
  ///     }
  ///
  ///     // 从 CDN 下载
  ///     final url = 'https://my-cdn.com/libs/'
  ///         '${request.platformArchIdentifier}/'
  ///         'libvips.zip';
  ///     await downloadAndExtract(url, cacheDir);
  ///
  ///     return libPath;
  ///   },
  ///   onStateChanged: (state) => print('State: $state'),
  /// );
  /// ```
  static Future<void> init({
    required VipsLibraryProvider provider,
    VipsLoadingCallback? onStateChanged,
    String appName = 'libvips_ffi',
  }) async {
    final request = VipsLibraryRequest(
      platform: VipsPlatform.current,
      arch: VipsArch.current,
      recommendedVersion: recommendedVipsVersion,
      suggestedCacheDir: await _getSuggestedCacheDir(),
    );

    onStateChanged?.call(VipsLoadingState.checking);

    // 调用开发者提供的回调获取库路径
    final libraryPath = await provider(request);

    // 验证文件存在
    if (!File(libraryPath).existsSync()) {
      onStateChanged?.call(VipsLoadingState.error);
      throw StateError(
        'Library file not found: $libraryPath\n'
        'The provider callback must return a valid library file path.',
      );
    }

    onStateChanged?.call(VipsLoadingState.loading);

    // 加载库
    try {
      initVipsWithLibrary(DynamicLibrary.open(libraryPath), appName);
      onStateChanged?.call(VipsLoadingState.ready);
    } catch (e) {
      onStateChanged?.call(VipsLoadingState.error);
      rethrow;
    }
  }

  /// 获取建议的缓存目录
  ///
  /// 返回用户主目录下的 `.cache/libvips_ffi` 目录。
  /// 如果目录不存在，会自动创建。
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

  /// 获取当前平台的库请求信息
  ///
  /// 可用于在初始化前获取平台信息，例如用于预下载。
  static Future<VipsLibraryRequest> getLibraryRequest() async {
    return VipsLibraryRequest(
      platform: VipsPlatform.current,
      arch: VipsArch.current,
      recommendedVersion: recommendedVipsVersion,
      suggestedCacheDir: await _getSuggestedCacheDir(),
    );
  }
}
