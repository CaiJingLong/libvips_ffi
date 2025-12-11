# libvips_ffi_system

System package manager library loader for libvips_ffi.

## Supported Package Managers

- **macOS**: Homebrew, MacPorts
- **Linux**: apt, dnf, pacman
- **Windows**: vcpkg, Chocolatey

## Usage

```dart
import 'package:libvips_ffi_system/libvips_ffi_system.dart';

void main() async {
  // Check installation status
  final managers = await checkVipsInstallation();
  for (final m in managers) {
    print('${m.name}: installed=${m.isInstalled}');
  }
  
  // Initialize from system package manager
  await initVipsSystemAsync();
  
  // Use libvips...
  final image = VipsImageWrapper.fromFile('input.jpg');
  
  shutdownVips();
}
```

## Related Packages

- [libvips_ffi_core](https://pub.dev/packages/libvips_ffi_core) - Core FFI bindings
- [libvips_ffi_desktop](https://pub.dev/packages/libvips_ffi_desktop) - Desktop meta package
