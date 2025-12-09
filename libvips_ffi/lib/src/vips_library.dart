import 'dart:ffi';
import 'dart:io';

/// Load the libvips dynamic library based on the current platform.
///
/// - Android: loads `libvips.so` from jniLibs
/// - iOS: uses `DynamicLibrary.process()` for statically linked library
DynamicLibrary loadVipsLibrary() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libvips.so');
  } else if (Platform.isIOS) {
    // iOS uses static linking, symbols are in the main process
    return DynamicLibrary.process();
  }
  throw UnsupportedError(
    'Unsupported platform: ${Platform.operatingSystem}. '
    'Only Android and iOS are supported.',
  );
}

/// Cached library instance for lazy initialization.
DynamicLibrary? _cachedLibrary;

/// Get the libvips library instance (lazy loaded and cached).
DynamicLibrary get vipsLibrary {
  return _cachedLibrary ??= loadVipsLibrary();
}
