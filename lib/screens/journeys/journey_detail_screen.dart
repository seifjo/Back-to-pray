import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/journey.dart';
import '../../providers/journey_provider.dart';
import '../../core/theme/app_theme.dart';

/// Journey Detail Screen
/// Shows journey information before starting
class JourneyDetailScreen extends StatelessWidget {
  final Journey journey;

  const JourneyDetailScreen({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(journey.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                journey.icon,
                style: const TextStyle(fontSize: 80),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                journey.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            // Effects Section
            _buildSection(
              '⚠️ تأثيرات الإدمان',
              [
                _buildEffectCard(
                  'تأثيرات الدماغ',
                  journey.effects.brainEffects,
                  Icons.psychology,
                ),
                _buildEffectCard(
                  'تأثيرات الجسم',
                  journey.effects.bodyEffects,
                  Icons.favorite,
                ),
                _buildEffectCard(
                  'تأثيرات نفسية',
                  journey.effects.psychologyEffects,
                  Icons.sentiment_very_dissatisfied,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Benefits Section
            _buildSection(
              '✨ فوائد التعافي',
              journey.benefits.map((benefit) => _buildListItem(benefit, '✓')).toList(),
            ),

            const SizedBox(height: 32),

            // Stages Section
            _buildSection(
              '📊 مراحل الرحلة',
              journey.stages.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final stage = entry.value;
                return _buildStageCard(index, stage);
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Duration
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFF14FFEC), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مدة التعافي المتوقعة',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '~${journey.recommendedDays} يوم',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14FFEC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tips Section
            _buildSection(
              '💡 نصائح وإرشادات',
              journey.tips.map((tip) => _buildListItem(tip, '•')).toList(),
            ),

            const SizedBox(height: 40),

            // Start Journey Button
            // Active Journey Status or Start Button
            Consumer<JourneyProvider>(
              builder: (context, provider, child) {
                final isActive = provider.activeJourneyId == journey.id;
                
                if (isActive) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.check_circle, color: AppTheme.accentGold, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'أنت في هذه الرحلة حالياً',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'يتم تسجيل تقدمك يومياً',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }

                // If another journey is active, maybe show warning or allow switch?
                // For now, let's just let them start, which will confirm switch in the dialog logic
                
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startJourney(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🚀 ابدأ الرحلة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildEffectCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content.trim(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(int index, JourneyStage stage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stage.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stage.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, String bullet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bullet,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF14FFEC),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startJourney(BuildContext context) async {
    final journeyProvider = context.read<JourneyProvider>();

    // Show confirmation dialog
    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هل أنت مستعد؟'),
        content: Text(
          'أنت على وشك البدء في "${journey.title}"\n\n'
          'هذه رحلة تحتاج إلى التزام وعزيمة. ستحتاج إلى تسجيل التزامك اليومي.\n\n'
          'هل أنت جاهز للبدء؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لا، ليس الآن'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text(
              'نعم، ابدأ الآن',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldStart == true && context.mounted) {
      await journeyProvider.startJourney(journey.id);

      if (context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 بدأت رحلتك! بالتوفيق'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );

        // Navigate back to journey selection (which will show dashboard now)
        Navigator.of(context).pop();
      }
    }
  }
}
