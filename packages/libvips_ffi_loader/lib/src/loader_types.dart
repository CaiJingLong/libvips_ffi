import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// 库请求信息 - 传递给开发者的回调
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
      case VipsPlatform.android:
        return 'libvips.so';
      case VipsPlatform.ios:
        return ''; // iOS 使用静态链接
    }
  }

  /// 获取平台-架构标识符 (用于构建下载 URL)
  String get platformArchIdentifier => '${platform.name}-${arch.name}';

  @override
  String toString() {
    return 'VipsLibraryRequest('
        'platform: ${platform.name}, '
        'arch: ${arch.name}, '
        'version: $recommendedVersion, '
        'cacheDir: $suggestedCacheDir)';
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
///
/// 开发者实现此回调，返回库文件的绝对路径。
/// 在回调中可以：
/// - 检查本地缓存
/// - 从 CDN 下载库文件
/// - 解压压缩包
/// - 返回最终的库文件路径
typedef VipsLibraryProvider = Future<String> Function(
  VipsLibraryRequest request,
);

/// 加载状态回调
typedef VipsLoadingCallback = void Function(VipsLoadingState state);
