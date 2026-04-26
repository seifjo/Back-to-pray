import 'package:flutter/material.dart';
import '../../data/adhkar_data.dart';
import '../../models/adhkar.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_achievements_provider.dart';

/// Adhkar Screen
/// Displays morning and evening adhkar with progress tracking
class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _completedCounts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'أذكار الصباح'),
            Tab(text: 'أذكار المساء'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdhkarList(AdhkarData.morningAdhkar),
          _buildAdhkarList(AdhkarData.eveningAdhkar),
        ],
      ),
    );
  }

  Widget _buildAdhkarList(AdhkarCategory category) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryGreen.withValues(alpha:0.1),
          child: Column(
            children: [
              Text(
                category.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                category.recommendedTime,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: category.items.length,
            itemBuilder: (context, index) {
              final item = category.items[index];
              final key = '${category.name}_$index';
              final completedCount = _completedCounts[key] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Arabic Text
                      Text(
                        item.arabicText,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 16),
                      
                      // Translation
                      Text(
                        item.translation,
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      
                      // Reference
                      Text(
                        item.reference,
                        style: TextStyle(fontSize: 12, color: AppTheme.accentGold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      
                      // Counter and Repeat Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'العدد: ${item.repetitions}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '$completedCount / ${item.repetitions}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: completedCount >= item.repetitions
                                      ? Colors.green
                                      : AppTheme.primaryGreen,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: completedCount >= item.repetitions
                                    ? null
                                    : () {
                                        setState(() {
                                          _completedCounts[key] = completedCount + 1;
                                        });

                                        // Check if category is complete
                                        _checkAdhkarCompletion(category);
                                      },
                                child: const Icon(Icons.add),
                              ),
                              if (completedCount > 0) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _completedCounts[key] = 0;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh, color: Colors.white70),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  void _checkAdhkarCompletion(AdhkarCategory category) async {
    // Check if all items in this category are completed
    bool isAllComplete = true;
    for (int i = 0; i < category.items.length; i++) {
      final key = '${category.name}_$i';
      final count = _completedCounts[key] ?? 0;
      if (count < category.items[i].repetitions) {
        isAllComplete = false;
        break;
      }
    }

    if (isAllComplete) {
      final achievementId = category.name.contains('الصباح') 
          ? 'adhkar_morning' 
          : 'adhkar_evening';

      // Use try-catch block to handle provider access safely
      try {
        if (!mounted) return;
        final dailyProvider = Provider.of<DailyAchievementsProvider>(context, listen: false);
        final result = await dailyProvider.completeAchievement(achievementId);

        if (result['success'] == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text('🎉 إنجاز رائع: أتممت ${category.name}!'),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error marking adhkar achievement: $e');
      }
    }
  }
}
