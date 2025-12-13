#include "include/libvips_ffi_windows/libvips_ffi_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

void LibvipsFfiWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  // This is an FFI-only plugin, no method channel registration needed.
  // DLLs are bundled via CMakeLists.txt install() command.
}
