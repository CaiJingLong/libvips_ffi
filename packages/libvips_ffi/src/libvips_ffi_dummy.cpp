// This is a dummy C++ file to ensure libc++_shared.so is linked.
// The actual FFI bindings are handled by Dart FFI, not through JNI.
// This file exists only to trigger the NDK to include the C++ standard library.

extern "C" {
    // Empty - no actual JNI functions needed
    // libvips is loaded directly via Dart FFI
}
