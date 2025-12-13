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
  static void _addDllDirectory(String path) {
    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final addDllDirectory = kernel32.lookupFunction<
          IntPtr Function(Pointer<Utf16>),
          int Function(Pointer<Utf16>)>('AddDllDirectory');
      final setDefaultDllDirectories = kernel32.lookupFunction<
          Int32 Function(Uint32),
          int Function(int)>('SetDefaultDllDirectories');
      
      // LOAD_LIBRARY_SEARCH_DEFAULT_DIRS = 0x00001000
      // LOAD_LIBRARY_SEARCH_USER_DIRS = 0x00000400
      setDefaultDllDirectories(0x00001000 | 0x00000400);
      
      final pathPtr = path.toNativeUtf16();
      addDllDirectory(pathPtr);
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
