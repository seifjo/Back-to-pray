import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Custom Goals Screen
/// Create and track custom goals
class CustomGoalsScreen extends StatefulWidget {
  const CustomGoalsScreen({super.key});

  @override
  State<CustomGoalsScreen> createState() => _CustomGoalsScreenState();
}

class _CustomGoalsScreenState extends State<CustomGoalsScreen> {
  final List<Map<String, dynamic>> _goals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أهدافي الخاصة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _goals.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(_goals[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGoalDialog,
        icon: const Icon(Icons.add),
        label: const Text('هدف جديد'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد أهداف بعد',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أنشئ هدفك الخاص واتبع تقدمك',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCreateGoalDialog,
            icon: const Icon(Icons.add),
            label: const Text('إنشاء هدف'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final progress = goal['progress'] as double;
    final target = goal['target'] as int;
    final percentage = (progress / target * 100).clamp(0, 100);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal['title'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentage.toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / target,
                minHeight: 12,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.accentCyan,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${progress.toInt()} / $target',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هدف جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الهدف',
                hintText: 'مثال: قراءة 10 صفحات يومياً',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(
                labelText: 'الهدف المطلوب',
                hintText: 'مثال: 100',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  targetController.text.isNotEmpty) {
                setState(() {
                  _goals.add({
                    'title': titleController.text,
                    'target': int.tryParse(targetController.text) ?? 0,
                    'progress': 0.0,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}
