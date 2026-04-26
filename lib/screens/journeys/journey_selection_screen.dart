import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/journey_content.dart';
import '../../providers/journey_provider.dart';
import '../../core/theme/app_theme.dart';
import './journey_detail_screen.dart';
import './active_journey_dashboard.dart';

/// Journey Selection Screen
/// Shows available recovery journeys or active journey dashboard
class JourneySelectionScreen extends StatelessWidget {
  const JourneySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'رحلات التعافي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<JourneyProvider>(
        builder: (context, journeyProvider, child) {
          // If has active journey, show dashboard
          if (journeyProvider.hasActiveJourney) {
            return const ActiveJourneyDashboard();
          }

          // Otherwise show journey selection
          return _buildJourneySelection(context);
        },
      ),
    );
  }

  Widget _buildJourneySelection(BuildContext context) {
    final journeys = JourneyContent.allJourneys;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'اختر رحلتك',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'كل رحلة تبدأ بخطوة واحدة... ابدأ اليوم',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),

          // Journey Cards
          ...journeys.map((journey) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildJourneyCard(context, journey),
              )),
        ],
      ),
    );
  }

  Widget _buildJourneyCard(BuildContext context, journey) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JourneyDetailScreen(journey: journey),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen.withValues(alpha: 0.2),
                AppTheme.primaryGreen.withValues(alpha: 0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    journey.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      journey.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14FFEC)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${journey.stages.length} مراحل',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF14FFEC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '~${journey.recommendedDays} يوم',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF14FFEC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
