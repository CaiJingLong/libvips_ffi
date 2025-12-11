import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libvips_ffi/libvips_ffi.dart';

/// Memory diagnostics page for monitoring VipsImage pointer usage.
///
/// 内存诊断页面，用于监控 VipsImage 指针使用情况。
class MemoryDiagnosticsPage extends StatefulWidget {
  const MemoryDiagnosticsPage({super.key});

  @override
  State<MemoryDiagnosticsPage> createState() => _MemoryDiagnosticsPageState();
}

class _MemoryDiagnosticsPageState extends State<MemoryDiagnosticsPage> {
  late Map<String, dynamic> _statistics;
  String _leakReport = '';
  bool _trackStackTraces = false;

  @override
  void initState() {
    super.initState();
    _refreshStatistics();
  }

  void _refreshStatistics() {
    setState(() {
      _statistics = VipsPointerManager.instance.getStatistics();
      _leakReport = VipsPointerManager.instance.getLeakReport();
      _trackStackTraces = VipsPointerManager.instance.trackStackTraces;
    });
  }

  void _toggleStackTraceTracking() {
    setState(() {
      _trackStackTraces = !_trackStackTraces;
      VipsPointerManager.instance.trackStackTraces = _trackStackTraces;
    });
  }

  void _forceDisposeAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning / 警告'),
        content: const Text(
          'This will force dispose all active pointers. '
          'This may cause issues if any images are still in use.\n\n'
          '这将强制释放所有活跃指针。如果有任何图像仍在使用中，可能会导致问题。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / 取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final count = VipsPointerManager.instance.forceDisposeAll();
              _refreshStatistics();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Disposed $count pointers / 已释放 $count 个指针'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Force Dispose / 强制释放'),
          ),
        ],
      ),
    );
  }

  void _copyReport() {
    Clipboard.setData(ClipboardData(text: _leakReport));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report copied to clipboard / 报告已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLeaks = _statistics['hasLeaks'] as bool? ?? false;
    final activeCount = _statistics['activeCount'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Diagnostics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStatistics,
            tooltip: 'Refresh / 刷新',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            color: hasLeaks ? Colors.red.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    hasLeaks ? Icons.warning : Icons.check_circle,
                    size: 48,
                    color: hasLeaks ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasLeaks
                              ? 'Potential Leaks Detected'
                              : 'No Leaks Detected',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: hasLeaks ? Colors.red : Colors.green,
                              ),
                        ),
                        Text(
                          hasLeaks ? '检测到潜在泄漏' : '未检测到泄漏',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics / 统计信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Active Pointers / 活跃指针', '$activeCount'),
                  _buildStatRow(
                    'Stack Trace Tracking / 堆栈跟踪',
                    _trackStackTraces ? 'Enabled / 已启用' : 'Disabled / 已禁用',
                  ),
                  if (_statistics['oldestPointerAge'] != null)
                    _buildStatRow(
                      'Oldest Pointer Age / 最老指针年龄',
                      _statistics['oldestPointerAge'].toString(),
                    ),
                  if (_statistics['newestPointerAge'] != null)
                    _buildStatRow(
                      'Newest Pointer Age / 最新指针年龄',
                      _statistics['newestPointerAge'].toString(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Actions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions / 操作',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Stack Trace Tracking'),
                    subtitle: const Text('堆栈跟踪（影响性能）'),
                    value: _trackStackTraces,
                    onChanged: (_) => _toggleStackTraceTracking(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Copy Report'),
                    subtitle: const Text('复制报告到剪贴板'),
                    onTap: _copyReport,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text(
                      'Force Dispose All',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('强制释放所有指针（危险）'),
                    onTap: _forceDisposeAll,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Leak Report Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Leak Report / 泄漏报告',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: _copyReport,
                        tooltip: 'Copy / 复制',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _leakReport,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
