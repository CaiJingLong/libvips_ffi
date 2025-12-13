import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// 存储已加载的 DLL，用于多库符号查找
final List<DynamicLibrary> _loadedLibraries = [];

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

  /// 预加载所有依赖 DLL 并存储引用
  /// 这是必需的，因为 FFI 绑定会尝试从 libvips 中查找 GLib 函数（如 g_free）
  static void _preloadDependencies(String dllDir) {
    // 清空之前加载的库
    _loadedLibraries.clear();
    
    // 列出目录中的所有 DLL 文件
    final dir = Directory(dllDir);
    if (!dir.existsSync()) {
      return;
    }
    
    // 按依赖顺序加载关键 DLL 并存储引用
    final priorityDlls = [
      'libglib-2.0-0.dll',
      'libgobject-2.0-0.dll',
      'libgio-2.0-0.dll',
    ];
    
    for (final dll in priorityDlls) {
      final dllPath = '$dllDir/$dll';
      if (File(dllPath).existsSync()) {
        try {
          final lib = DynamicLibrary.open(dllPath);
          _loadedLibraries.add(lib);
        } catch (_) {
          // 忽略加载失败
        }
      }
    }
  }

  /// 从多个库中查找符号
  static Pointer<T> _multiLibraryLookup<T extends NativeType>(String symbolName) {
    // 首先尝试从已加载的库中查找（按逆序，libvips 优先）
    for (final lib in _loadedLibraries.reversed) {
      try {
        return lib.lookup<T>(symbolName);
      } catch (_) {
        // 继续尝试下一个库
      }
    }
    throw ArgumentError('Failed to lookup symbol \'$symbolName\' in any loaded library');
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
/// 使用多库符号查找，支持从 libvips 和 GLib 等依赖库中查找符号
void initVipsWindows([String appName = 'libvips_ffi']) {
  final loader = WindowsVipsLoader();
  final library = loader.load();
  
  // 将 libvips 添加到已加载库列表的末尾（最高优先级）
  _loadedLibraries.add(library);
  
  // 使用多库查找初始化
  initVipsWithLookup(
    WindowsVipsLoader._multiLibraryLookup,
    library,
    appName,
  );
}
