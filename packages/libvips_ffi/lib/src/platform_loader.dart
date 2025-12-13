import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:libvips_ffi_core/libvips_ffi_core.dart';

/// 平台库加载器（移动端）
/// 
/// 用于 Android 和 iOS 平台。
/// Windows 平台使用内置的多库查找逻辑。
class PlatformVipsLoader implements VipsLibraryLoader {
  @override
  DynamicLibrary load() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libvips.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    throw UnsupportedError(
      'PlatformVipsLoader only supports Android and iOS. '
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

/// 存储已加载的 DLL（Windows 多库查找用）
final List<DynamicLibrary> _loadedLibraries = [];

/// 初始化 libvips
///
/// [loader] - 可选的自定义加载器。如果不提供：
///   - 移动端（Android/iOS）使用 MobileVipsLoader
///   - 桌面端使用 SystemVipsLoader
///
/// 如需使用预编译库，请传入平台特定的加载器（如 WindowsVipsLoader）。
void initVips({
  VipsLibraryLoader? loader,
  String appName = 'libvips_ffi',
}) {
  if (Platform.isWindows) {
    // Windows 需要多库查找支持
    _initVipsWindows(appName);
  } else {
    final effectiveLoader = loader ?? _getDefaultLoader();
    initVipsWithLoader(effectiveLoader, appName);
  }
}

VipsLibraryLoader _getDefaultLoader() {
  if (Platform.isAndroid || Platform.isIOS) {
    return PlatformVipsLoader();
  } else {
    return SystemVipsLoader();
  }
}

/// Windows 专用初始化（支持多库符号查找）
void _initVipsWindows(String appName) {
  // 获取可执行文件目录
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  
  // 设置 DLL 搜索路径
  _setDllDirectory(exeDir);
  
  // 预加载 GLib 等依赖 DLL
  _loadedLibraries.clear();
  final priorityDlls = [
    'libglib-2.0-0.dll',
    'libgobject-2.0-0.dll',
    'libgio-2.0-0.dll',
  ];
  
  for (final dll in priorityDlls) {
    final dllPath = '$exeDir/$dll';
    if (File(dllPath).existsSync()) {
      try {
        final lib = DynamicLibrary.open(dllPath);
        _loadedLibraries.add(lib);
      } catch (_) {
        // 忽略加载失败
      }
    }
  }
  
  // 加载 libvips
  final vipsPath = '$exeDir/libvips-42.dll';
  DynamicLibrary vipsLib;
  if (File(vipsPath).existsSync()) {
    vipsLib = DynamicLibrary.open(vipsPath);
  } else {
    // 回退到系统库
    vipsLib = DynamicLibrary.open('libvips-42.dll');
  }
  _loadedLibraries.add(vipsLib);
  
  // 使用多库查找初始化
  initVipsWithLookup(_multiLibraryLookup, vipsLib, appName);
}

/// 从多个库中查找符号
Pointer<T> _multiLibraryLookup<T extends NativeType>(String symbolName) {
  for (final lib in _loadedLibraries.reversed) {
    try {
      return lib.lookup<T>(symbolName);
    } catch (_) {
      // 继续尝试下一个库
    }
  }
  throw ArgumentError('Failed to lookup symbol \'$symbolName\' in any loaded library');
}

/// 设置 DLL 搜索目录
void _setDllDirectory(String path) {
  try {
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    final setDllDirectory = kernel32.lookupFunction<
        Int32 Function(Pointer<Utf16>),
        int Function(Pointer<Utf16>)>('SetDllDirectoryW');
    
    final pathPtr = path.toNativeUtf16();
    setDllDirectory(pathPtr);
    calloc.free(pathPtr);
  } catch (_) {
    // 忽略错误
  }
}
