import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journey_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/journey.dart';
import '../emergency/emergency_adhkar_screen.dart';
import '../stats/advanced_stats_screen.dart';
import '../../data/journey_l10n.dart';
import '../../l10n/app_localizations.dart';
import 'journey_detail_screen.dart';

/// Active Journey Dashboard
/// Shows current journey progress and daily commitment logging
class ActiveJourneyDashboard extends StatelessWidget {
  const ActiveJourneyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<JourneyProvider, GamificationProvider, RewardsProvider>(
      builder: (context, journeyProvider, gamProvider, rewardsProvider, child) {
        final sourceJourney = journeyProvider.getCurrentJourney();
        final journey = sourceJourney == null
            ? null
            : JourneyL10n.localize(sourceJourney, !context.isArabic);
        final activeJourney = journeyProvider. activeJourney;

        if (journey == null || activeJourney == null) {
          return const Center(child: Text('لا توجد رحلة نشطة'));
        }

        final stageIndex = journeyProvider.getCurrentStageIndex();
        final currentStage = journey.stages.isEmpty
            ? null
            : journey.stages[stageIndex.clamp(0, journey.stages.length - 1)];
        final progress = journeyProvider.getRecoveryProgress();
        final isTodayLogged = activeJourney.isTodayLogged();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Journey Title
              Row(
                children: [
                  Text(
                    journey.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journey.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'بدأت منذ ${activeJourney.getDaysSinceStart()} يوم',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Streak Card
              _buildStreakCard(activeJourney.currentStreak),

              const SizedBox(height: 16),

              // Progress Card
              _buildProgressCard(
                activeJourney.totalDays,
                journey.recommendedDays,
                progress,
              ),

              const SizedBox(height: 16),

              // Current Stage
              if (currentStage != null)
                _buildCurrentStageCard(currentStage, stageIndex + 1),


              const SizedBox(height: 32),

              // ⚡ EMERGENCY: Feel like falling?
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade900,
                      Colors.orange.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '⚡',
                          style: TextStyle(fontSize: 32),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'تشعر بالرغبة في السقوط؟',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'توقف! خذ 90 ثانية للمقاومة',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _startEmergencySession(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '⏰ ابدأ 90 ثانية إنقاذ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Daily Commitment Buttons
              if (!isTodayLogged) ...[
                const Text(
                  'تسجيل اليوم',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCommitmentButton(
                        context,
                        'التزام اليوم ✅',
                        AppTheme.primaryGreen,
                        () => _logCommitment(context, journeyProvider),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCommitmentButton(
                        context,
                        'تعثر ⚠️',
                        Colors.orange,
                        () => _logRelapse(context, journeyProvider),
                      ),
                    ),
                  ],
                ),
              ] else
                _buildAlreadyLoggedCard(),

              const SizedBox(height: 32),

              // Stats Grid
              _buildStatsGrid(
                activeJourney.totalDays,
                journeyProvider.getSuccessRate(),
                gamProvider.totalXP,
              ),

              const SizedBox(height: 16),

              // Advanced Stats Feature (if unlocked)
              if (rewardsProvider.isFeatureUnlocked('feature_stats'))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdvancedStatsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('📊 عرض الإحصائيات المتقدمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.3),
                      foregroundColor: AppTheme.accentCyan,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Journey Options
              TextButton(
                onPressed: () => _showJourneyOptions(context, journeyProvider),
                child: const Text('خيارات الرحلة'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade800,
            Colors.red.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔥',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(width: 12),
              Text(
                'سلسلة الالتزام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'يوم متواصل',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int totalDays, int recommendedDays, double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'التقدم الكلي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14FFEC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 12,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF14FFEC),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$totalDays من $recommendedDays يوم',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStageCard(JourneyStage stage, int stageNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$stageNumber',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'المرحلة الحالية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stage.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14FFEC),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stage.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAlreadyLoggedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF14FFEC), size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم التسجيل!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'لقد سجلت التزامك اليوم بنجاح 🎉',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int totalDays, double successRate, int xp) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('إجمالي الأيام', '$totalDays', Icons.calendar_today),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'نسبة النجاح',
            '${successRate.toStringAsFixed(0)}%',
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('النقاط', '$xp XP', Icons.stars),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF14FFEC), size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logCommitment(BuildContext context, JourneyProvider provider) async {
    try {
      final result = await provider.logDailyCommitment();

      if (result['alreadyLogged'] == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التسجيل مسبقاً اليوم')),
        );
        return;
      }

      if (context.mounted) {
        final xpEarned = result['xpEarned'] ?? 0;
        final newStreak = result['newStreak'] ?? 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ممتاز! سلسلتك: $newStreak يوم | +$xpEarned XP'),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _logRelapse(BuildContext context, JourneyProvider provider) async {
    final shouldLog = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('التعثر جزء من الرحلة'),
        content: const Text(
          'لم تسقط... أنت تتعلم 💙\n\n'
          'كل شخص يتعثر في طريقه. المهم أن تعود وتبدأ من جديد.\n\n'
          'هل تريد تسجيل التعثر والبدء من جديد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text(
              'نعم، ابدأ من جديد',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldLog == true) {
      await provider.logRelapse();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة التعيين. ابدأ من جديد، أنت قوي! 💪'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showJourneyOptions(BuildContext context, JourneyProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('تفاصيل الرحلة'),
              onTap: () {
                Navigator.pop(ctx);
                final journey = provider.getCurrentJourney();
                if (journey != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JourneyDetailScreen(journey: journey),
                    ),
                  );
                }
              },
            ),
            // Paused removed as requested
            const Divider(),
            ListTile(
              leading: const Icon(Icons.replay),
              title: Text(context.tr('restartJourney')),
              onTap: () {
                Navigator.pop(ctx);
                _confirmRestart(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'إنهاء الرحلة',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmResetJourney(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestart(BuildContext context, JourneyProvider provider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('restartJourney')),
        content: Text(context.tr('restartConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              provider.restartJourney();
              Navigator.pop(ctx);
            },
            child: Text(context.tr('restartJourney')),
          ),
        ],
      ),
    );
  }

  void _confirmResetJourney(BuildContext context, JourneyProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text(
          'هل أنت متأكد من إنهاء هذه الرحلة؟\n\nسيتم حفظ إحصائياتك ولكن ستحتاج إلى بدء رحلة جديدة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetJourney();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنهاء الرحلة')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'نعم، أنهِ الرحلة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _startEmergencySession(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const EmergencyAdhkarScreen(),
        fullscreenDialog: true,
      ),
    );

    // If user completed the 90-second session successfully
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ممتاز! أنت أقوى من رغباتك!'),
          backgroundColor: AppTheme.primaryGreen,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
