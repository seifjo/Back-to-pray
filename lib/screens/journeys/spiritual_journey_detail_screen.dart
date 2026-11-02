import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/spiritual_journey_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../models/active_journey.dart';
import '../../models/spiritual_journey.dart';
import '../../providers/spiritual_journey_provider.dart';
import 'journey_completion_screen.dart';

class SpiritualJourneyDetailScreen extends StatefulWidget {
  final String journeyId;

  const SpiritualJourneyDetailScreen({super.key, required this.journeyId});

  @override
  State<SpiritualJourneyDetailScreen> createState() =>
      _SpiritualJourneyDetailScreenState();
}

class _SpiritualJourneyDetailScreenState
    extends State<SpiritualJourneyDetailScreen> {
  final Set<int> _checkedTasks = {};

  Future<void> _openCompletion() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            JourneyCompletionScreen(journeyId: widget.journeyId),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journey = SpiritualJourneyCatalog.byId(widget.journeyId);
    if (journey == null) {
      return Scaffold(body: Center(child: Text(context.tr('error'))));
    }

    final english = !context.isArabic;
    final provider = context.watch<SpiritualJourneyProvider>();
    final progress = provider.progressFor(journey.id);
    final now = provider.now;
    final day = progress == null
        ? 0
        : spiritualDayIndex(progress.startDate, now, journey.durationDays);
    final tasks = journey.tasksForDay(day, english);
    final todayDone = provider.isTodayDone(journey.id, now);
    final ratio = provider.ratio(journey.id);
    final missed = progress != null &&
        hasEarlierUnmarkedDay(
          start: progress.startDate,
          now: now,
          durationDays: journey.durationDays,
          completedDays: progress.completedDays,
        );
    final scheme = Theme.of(context).colorScheme;
    final allChecked =
        tasks.isEmpty || _checkedTasks.length >= tasks.length || todayDone;

    return Scaffold(
      appBar: AppBar(title: Text(journey.title(english))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.14),
                  scheme.surface,
                ],
              ),
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(journey.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  journey.title(english),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${journey.durationDays} ${context.tr('durationDays')}',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  journey.description(english),
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('objective'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(journey.objective(english), style: const TextStyle(height: 1.45)),
          const SizedBox(height: 10),
          Text(
            journey.disclaimer(english),
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 20),
            Text(
              context.tr('dashboard'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${context.tr('dayLabel')} ${day + 1} / ${journey.durationDays}',
            ),
            const SizedBox(height: 8),
            Text(
              missed
                  ? context.tr('encouragingFreshStart')
                  : context.tr('encouragingOnTrack'),
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('missedDayNote'),
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('todayTasks'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...List.generate(tasks.length, (index) {
              final checked = todayDone || _checkedTasks.contains(index);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: checked,
                onChanged: progress.status != JourneyStatus.active || todayDone
                    ? null
                    : (value) {
                        setState(() {
                          if (value == true) {
                            _checkedTasks.add(index);
                          } else {
                            _checkedTasks.remove(index);
                          }
                        });
                      },
                title: Text(tasks[index]),
              );
            }),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final milestone in journey.milestones)
                  Chip(
                    label: Text('${context.tr('milestone')} $milestone'),
                    avatar: Icon(
                      progress.completedDays.length >= milestone
                          ? Icons.star
                          : Icons.star_border,
                      color: AppTheme.accentGold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('journeyReminder')),
              subtitle: Text(context.tr('journeyReminderHelp')),
              value: progress.reminderEnabled,
              onChanged: (enabled) {
                provider.setReminder(
                  journeyId: journey.id,
                  enabled: enabled,
                  hour: progress.reminderHour ?? 20,
                  minute: progress.reminderMinute ?? 0,
                );
              },
            ),
            if (progress.reminderEnabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('journeyReminderTime')),
                trailing: Text(
                  TimeOfDay(
                    hour: progress.reminderHour ?? 20,
                    minute: progress.reminderMinute ?? 0,
                  ).format(context),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: progress.reminderHour ?? 20,
                      minute: progress.reminderMinute ?? 0,
                    ),
                  );
                  if (picked == null) return;
                  await provider.setReminder(
                    journeyId: journey.id,
                    enabled: true,
                    hour: picked.hour,
                    minute: picked.minute,
                  );
                },
              ),
          ],
          const SizedBox(height: 20),
          if (progress == null)
            FilledButton(
              onPressed: () => provider.start(journey.id),
              child: Text(context.tr('startJourney')),
            )
          else ...[
            if (progress.status == JourneyStatus.active)
              FilledButton(
                onPressed: !allChecked
                    ? null
                    : () async {
                        final completed =
                            await provider.toggleToday(journey.id, now);
                        if (!mounted) return;
                        if (completed) {
                          await _openCompletion();
                        }
                      },
                child: Text(
                  todayDone
                      ? context.tr('todayDone')
                      : context.tr('markToday'),
                ),
              ),
            const SizedBox(height: 8),
            if (progress.status == JourneyStatus.active)
              OutlinedButton(
                onPressed: () => provider.pause(journey.id),
                child: Text(context.tr('pauseJourney')),
              ),
            if (progress.status == JourneyStatus.paused)
              FilledButton(
                onPressed: () => provider.resume(journey.id),
                child: Text(context.tr('resumeJourney')),
              ),
            if (progress.status == JourneyStatus.completed) ...[
              Text(
                context.tr('statusCompleted'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _openCompletion,
                child: Text(context.tr('journeyViewCompletion')),
              ),
            ],
            if (progress.status != JourneyStatus.completed &&
                progress.status != JourneyStatus.abandoned)
              TextButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(context.tr('abandonJourney')),
                      content: Text(context.tr('abandonJourneyConfirm')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(context.tr('cancel')),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(context.tr('abandonJourney')),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await provider.abandon(journey.id);
                  }
                },
                child: Text(context.tr('abandonJourney')),
              ),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.tr('restartJourney')),
                    content: Text(context.tr('restartConfirm')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.tr('cancel')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(context.tr('restartJourney')),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await provider.restart(journey.id);
                  setState(() => _checkedTasks.clear());
                }
              },
              child: Text(context.tr('restartJourney')),
            ),
          ],
        ],
      ),
    );
  }
}
