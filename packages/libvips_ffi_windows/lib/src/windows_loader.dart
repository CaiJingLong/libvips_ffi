import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// Windows 库加载器
///
/// 加载预编译的 Windows libvips 库。
/// DLL 文件通过 CMakeLists.txt 复制到可执行文件目录。
/// 当预编译库不可用时，会回退到系统库。
class WindowsVipsLoader implements VipsLibraryLoader {
  static const _dllName = 'libvips-42.dll';

  /// 获取可执行文件所在目录
  static String _getExecutableDirectory() {
    final exePath = Platform.resolvedExecutable;
    return File(exePath).parent.path;
  }

  /// 获取预编译库可能的路径列表
  static List<String> _getBundledLibraryPaths() {
    final exeDir = _getExecutableDirectory();
    
    return [
      // 可执行文件同级目录 (CMakeLists.txt install 目标位置)
      '$exeDir/$_dllName',
      // 开发时的包路径
      'packages/libvips_ffi_windows/windows/dll/$_dllName',
    ];
  }

  /// 获取 DLL 目录路径（用于添加到 DLL 搜索路径）
  static String? _findDllDirectory() {
    final exeDir = _getExecutableDirectory();
    
    // 检查可执行文件目录下是否有 DLL
    if (File('$exeDir/$_dllName').existsSync()) {
      return exeDir;
    }
    
    // 检查开发时的包路径
    const devPath = 'packages/libvips_ffi_windows/windows/dll';
    if (Directory(devPath).existsSync()) {
      return Directory(devPath).absolute.path;
    }
    
    return null;
  }

  @override
  DynamicLibrary load() {
    // 首先尝试将 DLL 目录添加到搜索路径
    final dllDir = _findDllDirectory();
    if (dllDir != null) {
      _addDllDirectory(dllDir);
      // 预加载关键依赖 DLL
      _preloadDependencies(dllDir);
    }

    // 尝试加载预编译库
    final paths = _getBundledLibraryPaths();
    for (final path in paths) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          return DynamicLibrary.open(file.absolute.path);
        }
      } catch (_) {
        // 继续尝试下一个路径
      }
    }

    // 回退到系统库
    return SystemVipsLoader().load();
  }

  /// 预加载所有依赖 DLL
  /// 这是必需的，因为 FFI 绑定会尝试从 libvips 中查找 GLib 函数（如 g_free）
  static void _preloadDependencies(String dllDir) {
    // 按依赖顺序加载所有 DLL
    // 注意：顺序很重要，被依赖的库必须先加载
    final dependencies = [
      // 基础库
      'libffi-8.dll',
      'libz1.dll',
      'libintl-8.dll',
      'libiconv-2.dll',
      // GLib 相关
      'libglib-2.0-0.dll',
      'libgmodule-2.0-0.dll',
      'libgobject-2.0-0.dll',
      'libgio-2.0-0.dll',
      // 图像格式库
      'libpng16-16.dll',
      'libjpeg-62.dll',
      'libtiff-6.dll',
      'libwebp-7.dll',
      'libwebpdemux-2.dll',
      'libwebpmux-3.dll',
      'libheif.dll',
      'libspng-0.dll',
      'libcgif-0.dll',
      // 其他依赖
      'libexpat-1.dll',
      'libexif-12.dll',
      'liblcms2-2.dll',
      'libxml2-16.dll',
      'libarchive-13.dll',
      'libimagequant.dll',
      // 字体和渲染
      'libfreetype-6.dll',
      'libfontconfig-1.dll',
      'libharfbuzz-0.dll',
      'libfribidi-0.dll',
      'libpixman-1-0.dll',
      'libcairo-2.dll',
      'libpango-1.0-0.dll',
      'libpangocairo-1.0-0.dll',
      'libpangoft2-1.0-0.dll',
      'librsvg-2-2.dll',
      // 视频编解码
      'libhwy.dll',
      'libsharpyuv-0.dll',
      'libaom.dll',
      // C++ 运行时
      'libc++.dll',
      'libunwind.dll',
    ];

    for (final dll in dependencies) {
      final dllPath = '$dllDir/$dll';
      if (File(dllPath).existsSync()) {
        try {
          DynamicLibrary.open(dllPath);
        } catch (_) {
          // 忽略加载失败，某些 DLL 可能不存在
        }
      }
    }
  }

  @override
  bool isAvailable() {
    if (!Platform.isWindows) return false;
    try {
      load();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 添加 DLL 搜索目录
  /// 使用 SetDllDirectoryW 设置 DLL 搜索路径
  static void _addDllDirectory(String path) {
    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final setDllDirectory = kernel32.lookupFunction<
          Int32 Function(Pointer<Utf16>),
          int Function(Pointer<Utf16>)>('SetDllDirectoryW');
      
      final pathPtr = path.toNativeUtf16();
      setDllDirectory(pathPtr);
      calloc.free(pathPtr);
    } catch (_) {
      // 如果 API 不可用，忽略错误
    }
  }
}

/// 初始化 libvips (Windows)
void initVipsWindows([String appName = 'libvips_ffi']) {
  initVipsWithLoader(WindowsVipsLoader(), appName);
}
