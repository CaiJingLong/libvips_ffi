import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'bindings/vips_bindings_generated.dart';
import 'vips_library.dart';

/// Global libvips bindings instance.
///
/// 全局 libvips 绑定实例。
final VipsBindings vipsBindings = VipsBindings(vipsLibrary);

/// Whether libvips has been initialized.
///
/// libvips 是否已初始化。
bool _initialized = false;

/// Initializes libvips.
///
/// 初始化 libvips。
///
/// This must be called before using any other libvips functions.
/// It's safe to call multiple times - subsequent calls are no-ops.
/// 在使用任何其他 libvips 函数之前必须调用此函数。
/// 多次调用是安全的 - 后续调用不执行任何操作。
///
/// [appName] is the application name for libvips logging.
/// [appName] 是用于 libvips 日志记录的应用程序名称。
///
/// Throws [VipsException] if initialization fails.
/// 如果初始化失败，则抛出 [VipsException]。
void initVips([String appName = 'libvips_ffi']) {
  if (_initialized) return;

  final appNamePtr = appName.toNativeUtf8();
  try {
    final result = vipsBindings.vips_init(appNamePtr.cast());
    if (result != 0) {
      throw VipsException('Failed to initialize libvips: ${getVipsError()}');
    }
    _initialized = true;
  } finally {
    calloc.free(appNamePtr);
  }
}

/// Shuts down libvips and frees resources.
///
/// 关闭 libvips 并释放资源。
///
/// Call this when you're done using libvips.
/// 当你完成 libvips 的使用时调用此函数。
///
/// It's safe to call multiple times - subsequent calls are no-ops.
/// 多次调用是安全的 - 后续调用不执行任何操作。
void shutdownVips() {
  if (!_initialized) return;
  vipsBindings.vips_shutdown();
  _initialized = false;
}

/// Gets the current libvips error message.
///
/// 获取当前的 libvips 错误消息。
///
/// Returns the error message string, or `null` if no error.
/// 返回错误消息字符串，如果没有错误则返回 `null`。
///
/// The error buffer may contain non-UTF-8 characters, which are handled gracefully.
/// 错误缓冲区可能包含非 UTF-8 字符，这些字符会被优雅地处理。
String? getVipsError() {
  final errorPtr = vipsBindings.vips_error_buffer();
  if (errorPtr == ffi.nullptr) return null;

  try {
    // Try to decode as UTF-8, but handle potential encoding issues
    return errorPtr.cast<Utf8>().toDartString();
  } catch (e) {
    // If UTF-8 decoding fails, try to read as raw bytes and convert
    // This can happen if the error message contains non-UTF-8 characters
    try {
      // Read bytes until null terminator
      final bytes = <int>[];
      var i = 0;
      while (true) {
        final byte = errorPtr.cast<ffi.Uint8>()[i];
        if (byte == 0) break;
        bytes.add(byte);
        i++;
        if (i > 4096) break; // Safety limit
      }
      // Replace invalid UTF-8 sequences
      return String.fromCharCodes(bytes.where((b) => b < 128));
    } catch (_) {
      return 'Error reading vips error buffer';
    }
  }
}

/// Clears the libvips error buffer.
///
/// 清除 libvips 错误缓冲区。
///
/// Call this before operations to ensure you get fresh error messages.
/// 在操作前调用此函数以确保获取最新的错误消息。
void clearVipsError() {
  vipsBindings.vips_error_clear();
}

/// Gets libvips version information.
///
/// 获取 libvips 版本信息。
///
/// [flag] determines what version info to return:
/// [flag] 决定返回什么版本信息：
///
/// - 0: major version / 主版本号
/// - 1: minor version / 次版本号
/// - 2: micro version / 微版本号
/// - 3: library current / 库当前版本
/// - 4: library revision / 库修订版本
/// - 5: library age / 库年龄
///
/// Returns the requested version number.
/// 返回请求的版本号。
int vipsVersion(int flag) {
  return vipsBindings.vips_version(flag);
}

/// Gets libvips version as a string (e.g., "8.15.0").
///
/// 以字符串形式获取 libvips 版本（例如 "8.15.0"）。
///
/// Returns a formatted version string in "major.minor.micro" format.
/// 返回格式化的版本字符串，格式为 "主版本.次版本.微版本"。
String get vipsVersionString {
  return '${vipsVersion(0)}.${vipsVersion(1)}.${vipsVersion(2)}';
}

/// Exception thrown by libvips operations.
///
/// libvips 操作抛出的异常。
///
/// This exception is thrown when a libvips operation fails.
/// 当 libvips 操作失败时抛出此异常。
class VipsException implements Exception {
  /// The error message describing what went wrong.
  ///
  /// 描述错误原因的错误消息。
  final String message;

  /// Creates a new [VipsException] with the given [message].
  ///
  /// 使用给定的 [message] 创建新的 [VipsException]。
  VipsException(this.message);

  @override
  String toString() => 'VipsException: $message';
}
