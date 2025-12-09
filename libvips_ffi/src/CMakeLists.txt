cmake_minimum_required(VERSION 3.22.1)

project("libvips_ffi")

# 设置预编译库路径
set(VIPS_LIB_DIR ${CMAKE_SOURCE_DIR}/../android/src/main/jniLibs/${ANDROID_ABI})

# 导入预编译的 libvips
add_library(vips SHARED IMPORTED)
set_target_properties(vips PROPERTIES IMPORTED_LOCATION ${VIPS_LIB_DIR}/libvips.so)

# 导入 glib 依赖
add_library(glib-2.0 SHARED IMPORTED)
set_target_properties(glib-2.0 PROPERTIES IMPORTED_LOCATION ${VIPS_LIB_DIR}/libglib-2.0.so)

add_library(gobject-2.0 SHARED IMPORTED)
set_target_properties(gobject-2.0 PROPERTIES IMPORTED_LOCATION ${VIPS_LIB_DIR}/libgobject-2.0.so)

add_library(gio-2.0 SHARED IMPORTED)
set_target_properties(gio-2.0 PROPERTIES IMPORTED_LOCATION ${VIPS_LIB_DIR}/libgio-2.0.so)

# 创建一个空的 dummy 库来触发 libc++_shared.so 的链接
# 这个库不包含任何代码，只是用来确保 c++_shared STL 被打包
add_library(${CMAKE_PROJECT_NAME} SHARED
    libvips_ffi_dummy.cpp
)

# 链接库 - 这会触发 NDK 自动包含 libc++_shared.so
target_link_libraries(${CMAKE_PROJECT_NAME}
    log
    vips
    glib-2.0
    gobject-2.0
    gio-2.0
)
