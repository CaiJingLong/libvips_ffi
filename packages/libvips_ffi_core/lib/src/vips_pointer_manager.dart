import 'dart:ffi' as ffi;

import 'bindings/vips_bindings_generated.dart';
import 'vips_core.dart';

/// Global pointer manager for tracking VipsImage pointers.
///
/// 全局指针管理器，用于跟踪 VipsImage 指针。
///
/// This singleton class helps detect memory leaks and provides
/// emergency cleanup capabilities.
/// 此单例类帮助检测内存泄漏并提供紧急清理功能。
///
/// ## Usage / 使用方式
///
/// ```dart
/// // Check for leaks at app exit
/// if (VipsPointerManager.instance.hasLeaks) {
///   print(VipsPointerManager.instance.getLeakReport());
/// }
///
/// // Emergency cleanup (use with caution)
/// VipsPointerManager.instance.forceDisposeAll();
/// ```
class VipsPointerManager {
  static final VipsPointerManager _instance = VipsPointerManager._();

  /// Gets the singleton instance.
  ///
  /// 获取单例实例。
  static VipsPointerManager get instance => _instance;

  VipsPointerManager._();

  /// Set of active pointer addresses.
  ///
  /// 活跃指针地址集合。
  final Set<int> _activePointers = {};

  /// Map of pointer addresses to allocation stack traces (for debugging).
  ///
  /// 指针地址到分配堆栈跟踪的映射（用于调试）。
  final Map<int, StackTrace> _allocationTraces = {};

  /// Map of pointer addresses to allocation timestamps.
  ///
  /// 指针地址到分配时间戳的映射。
  final Map<int, DateTime> _allocationTimes = {};

  /// Map of pointer addresses to optional labels.
  ///
  /// 指针地址到可选标签的映射。
  final Map<int, String?> _labels = {};

  /// Whether to track stack traces (disabled by default for performance).
  ///
  /// 是否跟踪堆栈（默认禁用以提高性能）。
  bool trackStackTraces = false;

  /// Registers a new pointer.
  ///
  /// 注册新指针。
  ///
  /// [ptr] is the pointer to register.
  /// [ptr] 是要注册的指针。
  ///
  /// [label] is an optional label for debugging (e.g., "fromFile: image.jpg").
  /// [label] 是用于调试的可选标签（例如 "fromFile: image.jpg"）。
  void register(ffi.Pointer<VipsImage> ptr, [String? label]) {
    if (ptr == ffi.nullptr) return;

    final address = ptr.address;
    _activePointers.add(address);
    _allocationTimes[address] = DateTime.now();
    if (label != null) {
      _labels[address] = label;
    }
    if (trackStackTraces) {
      _allocationTraces[address] = StackTrace.current;
    }
  }

  /// Unregisters a pointer.
  ///
  /// 注销指针。
  ///
  /// [ptr] is the pointer to unregister.
  /// [ptr] 是要注销的指针。
  void unregister(ffi.Pointer<VipsImage> ptr) {
    if (ptr == ffi.nullptr) return;

    final address = ptr.address;
    _activePointers.remove(address);
    _allocationTraces.remove(address);
    _allocationTimes.remove(address);
    _labels.remove(address);
  }

  /// Gets the number of active (not disposed) pointers.
  ///
  /// 获取活跃（未释放）的指针数量。
  int get activeCount => _activePointers.length;

  /// Whether there are any active pointers (potential leaks).
  ///
  /// 是否有任何活跃指针（潜在泄漏）。
  bool get hasLeaks => _activePointers.isNotEmpty;

  /// Gets all active pointer addresses.
  ///
  /// 获取所有活跃指针地址。
  Set<int> get activeAddresses => Set.unmodifiable(_activePointers);

  /// Gets a detailed leak report.
  ///
  /// 获取详细的泄漏报告。
  ///
  /// Returns a formatted string with information about all active pointers.
  /// 返回包含所有活跃指针信息的格式化字符串。
  String getLeakReport() {
    if (_activePointers.isEmpty) {
      return 'VipsPointerManager: No leaks detected. / 未检测到泄漏。';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== VipsPointerManager Leak Report ===');
    buffer.writeln('=== VipsPointerManager 泄漏报告 ===');
    buffer.writeln('Active pointers / 活跃指针: ${_activePointers.length}');
    buffer.writeln('');

    var index = 0;
    for (final address in _activePointers) {
      index++;
      buffer.writeln('[$index] Pointer address / 指针地址: 0x${address.toRadixString(16)}');

      final allocTime = _allocationTimes[address];
      if (allocTime != null) {
        final age = DateTime.now().difference(allocTime);
        buffer.writeln('    Allocated / 分配时间: $allocTime (${_formatDuration(age)} ago)');
      }

      final label = _labels[address];
      if (label != null) {
        buffer.writeln('    Label / 标签: $label');
      }

      final trace = _allocationTraces[address];
      if (trace != null) {
        buffer.writeln('    Stack trace / 堆栈跟踪:');
        final lines = trace.toString().split('\n').take(10);
        for (final line in lines) {
          buffer.writeln('      $line');
        }
        if (trace.toString().split('\n').length > 10) {
          buffer.writeln('      ... (truncated)');
        }
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Formats a duration for display.
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Forces disposal of all active pointers.
  ///
  /// 强制释放所有活跃指针。
  ///
  /// **WARNING**: Use this only as an emergency measure!
  /// This will attempt to free all tracked pointers, which may cause
  /// issues if any are still in use.
  /// **警告**：仅在紧急情况下使用！
  /// 这将尝试释放所有跟踪的指针，如果有任何指针仍在使用中，可能会导致问题。
  ///
  /// Returns the number of pointers that were disposed.
  /// 返回已释放的指针数量。
  int forceDisposeAll() {
    final count = _activePointers.length;
    final addressesToDispose = List<int>.from(_activePointers);

    for (final address in addressesToDispose) {
      try {
        final ptr = ffi.Pointer<VipsImage>.fromAddress(address);
        vipsBindings.g_object_unref(ptr.cast());
      } catch (e) {
        // Ignore errors during force dispose
      }
    }

    // Clear all tracking data
    _activePointers.clear();
    _allocationTraces.clear();
    _allocationTimes.clear();
    _labels.clear();

    return count;
  }

  /// Resets the manager state (for testing).
  ///
  /// 重置管理器状态（用于测试）。
  void reset() {
    _activePointers.clear();
    _allocationTraces.clear();
    _allocationTimes.clear();
    _labels.clear();
    trackStackTraces = false;
  }

  /// Gets statistics about pointer usage.
  ///
  /// 获取指针使用统计信息。
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    Duration? oldestAge;
    Duration? newestAge;

    for (final time in _allocationTimes.values) {
      final age = now.difference(time);
      if (oldestAge == null || age > oldestAge) {
        oldestAge = age;
      }
      if (newestAge == null || age < newestAge) {
        newestAge = age;
      }
    }

    return {
      'activeCount': activeCount,
      'hasLeaks': hasLeaks,
      'trackStackTraces': trackStackTraces,
      'oldestPointerAge': oldestAge?.toString(),
      'newestPointerAge': newestAge?.toString(),
    };
  }
}
