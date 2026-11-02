import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/worship_tracker_provider.dart';

class WorshipHistoryScreen extends StatelessWidget {
  const WorshipHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorshipTrackerProvider>();
    final english = !context.isArabic;
    final week = provider.weeklySummary;
    final month = provider.monthlySummary;
    final history = provider.recentHistory(days: 14);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('wtHistory'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            context.tr('wtHistoryIntro'),
            style: TextStyle(
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            title: context.tr('wtWeekly'),
            summaryText: context
                .tr('wtSummaryLine')
                .replaceAll('{done}', '${week.completedSlots}')
                .replaceAll('{total}', '${week.possibleSlots}'),
            rate: week.rate,
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: context.tr('wtMonthly'),
            summaryText: context
                .tr('wtSummaryLine')
                .replaceAll('{done}', '${month.completedSlots}')
                .replaceAll('{total}', '${month.possibleSlots}'),
            rate: month.rate,
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('wtRecentDays'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...history.map((log) {
            final active = provider.activities.where((a) => a.enabled);
            final done = active.where(log.isComplete).length;
            final total = active.length;
            return Card(
              child: ListTile(
                title: Text(log.dateKey),
                subtitle: Text(
                  context
                      .tr('wtDailyProgress')
                      .replaceAll('{done}', '$done')
                      .replaceAll('{total}', '$total'),
                ),
                trailing: Text(
                  total == 0 ? '—' : '${((done / total) * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                onTap: () {
                  final parts = log.dateKey.split('-');
                  if (parts.length == 3) {
                    provider.selectDate(
                      DateTime(
                        int.parse(parts[0]),
                        int.parse(parts[1]),
                        int.parse(parts[2]),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          Text(
            context.tr('wtByActivity'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...provider.activities.where((a) => a.enabled).map((activity) {
            final count = week.completedByActivity[activity.id] ?? 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(activity.title(english)),
              subtitle: Text(
                activity.isObligation
                    ? context.tr('wtNatureObligation')
                    : context.tr('wtNaturePersonal'),
              ),
              trailing: Text(
                context
                    .tr('wtDaysDone')
                    .replaceAll('{count}', '$count')
                    .replaceAll('{days}', '7'),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String summaryText;
  final double rate;

  const _SummaryCard({
    required this.title,
    required this.summaryText,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.surface,
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(summaryText),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: rate.clamp(0, 1),
              minHeight: 8,
              color: AppTheme.primaryGreen,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
