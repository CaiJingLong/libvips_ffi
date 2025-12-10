import 'dart:ffi' as ffi;

import '../bindings/vips_bindings_generated.dart';
import '../vips_core.dart';
import '../vips_variadic_bindings.dart';

// Forward declaration - will be imported by concrete class
typedef VipsImageFactory = dynamic Function(
  ffi.Pointer<VipsImage> pointer, [
  ffi.Pointer<ffi.Uint8>? bufferPtr,
]);

/// Base interface for VipsImageWrapper that mixins can access.
///
/// VipsImageWrapper 的基础接口，供 mixin 访问。
///
/// This abstract class defines the core properties and methods that
/// all image operation mixins need to access.
/// 此抽象类定义了所有图像操作 mixin 需要访问的核心属性和方法。
abstract class VipsImageBase {
  /// Gets the underlying pointer.
  ///
  /// 获取底层指针。
  ffi.Pointer<VipsImage> get pointer;

  /// Checks if the image has been disposed.
  ///
  /// 检查图像是否已被释放。
  void checkDisposed();

  /// Creates a new instance from a pointer.
  ///
  /// 从指针创建新实例。
  ///
  /// Returns dynamic to allow concrete implementations to return their own type.
  /// 返回 dynamic 以允许具体实现返回其自己的类型。
  dynamic createFromPointer(
    ffi.Pointer<VipsImage> pointer, [
    ffi.Pointer<ffi.Uint8>? bufferPtr,
  ]);
}

/// Provides access to shared bindings for mixins.
///
/// 为 mixin 提供对共享绑定的访问。
mixin VipsBindingsAccess {
  /// Gets the variadic bindings instance.
  ///
  /// 获取可变参数绑定实例。
  VipsVariadicBindings get bindings => variadicBindings;

  /// Gets the standard vips bindings instance.
  ///
  /// 获取标准 vips 绑定实例。
  VipsBindings get stdBindings => vipsBindings;
}
