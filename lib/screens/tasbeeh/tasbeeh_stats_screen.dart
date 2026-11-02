import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/tasbeeh_provider.dart';

class TasbeehStatsScreen extends StatelessWidget {
  const TasbeehStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasbeehProvider>();
    final english = !context.isArabic;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final monthStart = DateTime(now.year, now.month, 1);
    final today = provider.todayTotal(now);
    final week = provider.rangeTotal(weekStart, now);
    final month = provider.rangeTotal(monthStart, now);
    final days = provider.lastDays(7);
    final maxDay = days.fold<int>(1, (m, d) => d.total > m ? d.total : m);
    final breakdown = provider.breakdownForRange(
      now.subtract(const Duration(days: 30)),
      now,
    );
    final breakdownEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final goals =
        provider.allDhikr.where((item) => item.activeTarget != null).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('tasbeehStats'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: context.tr('tasbeehToday'), value: '$today'),
              _StatChip(label: context.tr('tasbeehWeek'), value: '$week'),
              _StatChip(label: context.tr('tasbeehMonth'), value: '$month'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('tasbeehDailyHistory'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in days)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${day.total}', style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 6),
                          Flexible(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor:
                                    (day.total / maxDay).clamp(0.04, 1.0),
                                widthFactor: 1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen
                                        .withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day.day.substring(5),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('tasbeehBreakdown'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (breakdownEntries.isEmpty)
            Text(context.tr('tasbeehNoStats'))
          else
            ...breakdownEntries.map(
              (entry) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(provider.labelFor(entry.key, english)),
                  trailing: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            context.tr('tasbeehGoals'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (goals.isEmpty)
            Text(context.tr('tasbeehNoGoals'))
          else
            ...goals.map((item) {
              final current = provider.sessionCountFor(item.id);
              final target = item.activeTarget!;
              final ratio = (current / target).clamp(0.0, 1.0);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.displayName(english)),
                      const SizedBox(height: 4),
                      Text(
                        item.usesPersonalGoal
                            ? context.tr('tasbeehPersonalGoal')
                            : context.tr('tasbeehTraditionalGoal'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(height: 6),
                      Text('$current / $target'),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
