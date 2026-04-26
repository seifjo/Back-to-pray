import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rewards_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../models/reward.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gamification/reward_card.dart';
import '../settings/settings_screen.dart';
import '../stats/advanced_stats_screen.dart';
import '../goals/custom_goals_screen.dart';

class RewardsShopScreen extends StatefulWidget {
  const RewardsShopScreen({super.key});

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text(
          'متجر المكافآت',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'ثيمات'),
            Tab(text: 'شارات'),
            Tab(text: 'ميزات'),
          ],
        ),
      ),
      body: Consumer2<RewardsProvider, GamificationProvider>(
        builder: (context, rewardsProvider, gamProvider, _) {
          final userPoints = gamProvider.recoveryPoints;

          return Column(
            children: [
              // Points Balance
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentCyan.withValues(alpha: 0.3),
                      AppTheme.accentCyan.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.diamond, color: AppTheme.accentCyan, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const Text(
                          'رصيدك',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '$userPoints نقطة',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rewards Grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRewardsGrid(rewardsProvider.rewards, userPoints),
                    _buildRewardsGrid(
                      rewardsProvider.getByType(RewardType.theme),
                      userPoints,
                    ),
                    _buildRewardsGrid(
                      rewardsProvider.getByType(RewardType.badge),
                      userPoints,
                    ),
                    _buildRewardsGrid(
                      rewardsProvider.getByType(RewardType.feature),
                      userPoints,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRewardsGrid(List<Reward> rewards, int userPoints) {
    if (rewards.isEmpty) {
      return const Center(
        child: Text('لا توجد مكافآت في هذه الفئة'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        
        // Custom interaction based on state
        return RewardCard(
          reward: reward,
          userPoints: userPoints,
          onPurchase: () {
            if (reward.isUnlocked) {
               // Show Manage/Info Dialog
               _showSuccessDialog(reward, isNewPurchase: false);
            } else {
              // Purchase
              _purchaseReward(reward.id);
            }
          },
        );
      },
    );
  }

  Future<void> _purchaseReward(String rewardId) async {
    final provider = context.read<RewardsProvider>();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الشراء'),
        content: const Text('هل تريد شراء هذه المكافأة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('شراء'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await provider.purchaseReward(rewardId);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessDialog(result['reward'] as Reward, isNewPurchase: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'] == 'Not enough points'
                ? 'نقاطك غير كافية! تحتاج ${result['needed']} نقطة إضافية'
                : result['error'] ?? 'حدث خطأ',
          ),
        ),
      );
    }
  }

  void _showSuccessDialog(Reward reward, {bool isNewPurchase = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isNewPurchase ? '🎉 تم الشراء!' : '✨ لديك هذه المكافأة',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reward.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              reward.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              textAlign: TextAlign.center,
            ),
            if (reward.type == RewardType.theme) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final provider = context.read<RewardsProvider>();
                    provider.setActiveTheme(reward.themeId ?? 'ocean');
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تطبيق ثيم ${reward.title}'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.palette),
                  label: const Text('تطبيق الثيم الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ] else if (reward.type == RewardType.feature) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.accentCyan),
                        SizedBox(width: 8),
                        Text(
                          'كيفية الاستخدام:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getFeatureInstructions(reward.id),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToFeature(context, reward.id);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(_getFeatureButtonLabel(reward.id)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _getFeatureInstructions(String featureId) {
    switch (featureId) {
      case 'feature_stats':
        return '• اذهب إلى لوحة الرحلة\n'
            '• اضغط على زر "إحصائيات متقدمة"\n'
            '• شاهد رسوم بيانية تفصيلية لتقدمك';
      case 'feature_goals':
        return '• اذهب إلى تبويب الإنجازات\n'
            '• افتح قسم "أهدافي الخاصة"\n'
            '• أنشئ أهدافك وتابع تقدمك';
      case 'feature_export':
        return '• اذهب إلى الإعدادات\n'
            '• اضغط على "تصدير بياناتي"\n'
            '• احفظ ملف JSON بكل بياناتك';
      default:
        return 'هذه الميزة مفعلة الآن في حسابك!';
    }
  }

  String _getFeatureButtonLabel(String featureId) {
    switch (featureId) {
      case 'feature_stats':
        return 'عرض الإحصائيات';
      case 'feature_goals':
        return 'إنشاء هدف';
      case 'feature_export':
        return 'فتح الإعدادات';
      default:
        return 'استخدام الآن';
    }
  }

  void _navigateToFeature(BuildContext context, String featureId) {
    switch (featureId) {
      case 'feature_stats':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdvancedStatsScreen(),
          ),
        );
        break;
      case 'feature_goals':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomGoalsScreen(),
          ),
        );
        break;
      case 'feature_export':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
    }
  }
}
