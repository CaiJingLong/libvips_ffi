/// System package manager library loader for libvips_ffi.
///
/// libvips_ffi 的系统包管理器库加载器。
///
/// This package provides automatic detection and loading of libvips
/// installed via system package managers.
/// 此包提供自动检测和加载通过系统包管理器安装的 libvips。
///
/// ## Supported Package Managers / 支持的包管理器
///
/// - **macOS**: Homebrew, MacPorts
/// - **Linux**: apt (Debian/Ubuntu), dnf (Fedora/RHEL), pacman (Arch)
/// - **Windows**: vcpkg, Chocolatey
///
/// ## Usage / 使用方法
///
/// ```dart
/// import 'package:libvips_ffi_system/libvips_ffi_system.dart';
///
/// Future<void> main() async {
///   // Check if libvips is installed
///   final managers = await checkVipsInstallation();
///   for (final m in managers) {
///     print('${m.name}: installed=${m.isInstalled}');
///   }
///
///   // Initialize using system library
///   await initVipsSystemAsync();
///
///   // Use libvips...
///   final image = VipsImageWrapper.fromFile('input.jpg');
///   // ...
///
///   shutdownVips();
/// }
/// ```
///
/// ## Installation Check / 安装检查
///
/// ```dart
/// final suggestion = await getVipsInstallSuggestion();
/// print(suggestion);
/// // macOS: Install via Homebrew: brew install vips
/// // Linux: Install via apt: sudo apt install libvips-dev
/// ```
library libvips_ffi_system;

// Re-export core package
export 'package:libvips_ffi_core/libvips_ffi_core.dart';

// Export system library finder
export 'src/system_library_finder.dart'
    show PackageManagerInfo, SystemLibraryFinder;

// Export system loader
export 'src/system_vips_loader.dart'
    show
        SystemPackageVipsLoader,
        initVipsSystemAsync,
        checkVipsInstallation,
        getVipsInstallSuggestion;
