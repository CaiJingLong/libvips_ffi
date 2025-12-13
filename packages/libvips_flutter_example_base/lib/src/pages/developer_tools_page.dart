import 'package:flutter/material.dart';

import 'all_tests_page.dart';
import 'benchmark_page.dart';
import 'memory_diagnostics_page.dart';

/// Developer tools page with testing and diagnostics.
///
/// 开发者工具页面，包含测试和诊断功能。
class DeveloperToolsPage extends StatelessWidget {
  const DeveloperToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Tools / 开发者工具'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Description
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.developer_mode, size: 40, color: Colors.orange.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer Tools',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.orange.shade700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Testing, benchmarking, and diagnostics for libvips_ffi',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tools list
          _buildToolCard(
            context,
            title: 'All Tests / 全部测试',
            subtitle: 'Test all image operations with visual comparison',
            icon: Icons.science,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllTestsPage()),
            ),
          ),
          const SizedBox(height: 12),

          _buildToolCard(
            context,
            title: 'Benchmark / 性能测试',
            subtitle: 'Compare sync vs async performance',
            icon: Icons.speed,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BenchmarkPage()),
            ),
          ),
          const SizedBox(height: 12),

          _buildToolCard(
            context,
            title: 'Memory Diagnostics / 内存诊断',
            subtitle: 'Monitor pointer usage and detect leaks',
            icon: Icons.memory,
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MemoryDiagnosticsPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
