import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/islamic_events_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hijri_calendar.dart';
import '../../providers/hijri_calendar_provider.dart';
import '../../widgets/islamic_motif.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HijriCalendarProvider>();
      if (provider.loading) provider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HijriCalendarProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final cells = provider.monthCells;
    final selected = provider.selectedCell;
    final weekdays = english
        ? const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri']
        : const ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: scheme.onSurface.withValues(alpha: 0.03),
              ),
            ),
          ),
          if (provider.loading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null)
            Center(child: Text(context.tr('hijriLoadError')))
          else
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(context.tr('hijriTitle')),
                  actions: [
                    IconButton(
                      tooltip: context.tr('hijriSettings'),
                      onPressed: () => _openSettings(context),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('hijriSubtitle'),
                          style: TextStyle(
                            height: 1.45,
                            color: scheme.onSurface.withValues(alpha: 0.68),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          english
                              ? provider.methodNameEn
                              : provider.methodNameAr,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('hijriMoonSightingNote'),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _MonthHeader(
                      title: provider.monthTitle(english),
                      onPrev: provider.previousMonth,
                      onNext: provider.nextMonth,
                      onToday: provider.goToToday,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        for (final label in weekdays)
                          Expanded(
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Calendar is a fixed ~6-row grid; use a non-sliver ListView
                // child height that scales with width for responsive cells.
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellWidth = (constraints.maxWidth - 24) / 7;
                      final cellHeight = (cellWidth * 1.15).clamp(54.0, 78.0);
                      final rows = (cells.length / 7).ceil();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: SizedBox(
                          height: rows * cellHeight,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisExtent: cellHeight,
                            ),
                            itemCount: cells.length,
                            itemBuilder: (context, index) {
                              final cell = cells[index];
                              final isSelected = selected != null &&
                                  cell.gregorian == selected.gregorian;
                              return _DayCell(
                                cell: cell,
                                selected: isSelected,
                                onTap: () =>
                                    provider.selectDay(cell.gregorian),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _Legend(english: english),
                  ),
                ),
                if (selected != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _SelectedDayCard(
                        cell: selected,
                        english: english,
                        onEventTap: (occurrence) =>
                            _openEventSheet(context, occurrence),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      context.tr('hijriUpcoming'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverList.separated(
                    itemCount: provider.upcomingEvents.take(8).length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final occurrence =
                          provider.upcomingEvents.take(8).toList()[index];
                      return _EventTile(
                        occurrence: occurrence,
                        english: english,
                        onTap: () => _openEventSheet(context, occurrence),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    final provider = context.read<HijriCalendarProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            top: 8,
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('hijriSettings'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(context.tr('hijriAdjustmentHelp')),
                  Slider(
                    value: provider.adjustmentDays.toDouble(),
                    min: -2,
                    max: 2,
                    divisions: 4,
                    label: provider.adjustmentDays.toString(),
                    onChanged: (value) async {
                      await provider.setAdjustment(value.round());
                      setModal(() {});
                    },
                  ),
                  Text(
                    context
                        .tr('hijriAdjustmentValue')
                        .replaceAll('{days}', '${provider.adjustmentDays}'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('hijriMoonSightingNote'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openEventSheet(
    BuildContext context,
    IslamicEventOccurrence occurrence,
  ) async {
    final provider = context.read<HijriCalendarProvider>();
    final english = !context.isArabic;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            top: 8,
          ),
          child: Consumer<HijriCalendarProvider>(
            builder: (context, live, _) {
              final reminder = live.reminderFor(occurrence.definition.id);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    occurrence.definition.name(english),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    occurrence.definition.description(english),
                    style: const TextStyle(height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${context.tr('hijriDate')}: ${occurrence.hijriDate}',
                  ),
                  Text(
                    '${context.tr('gregorianDate')}: ${DateFormat.yMMMEd(english ? 'en' : 'ar').format(occurrence.gregorianDate)}',
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('hijriReminder')),
                    subtitle: Text(context.tr('hijriReminderHelp')),
                    value: reminder.enabled,
                    onChanged: (enabled) async {
                      final ok = await provider.setReminder(
                        eventDefinitionId: occurrence.definition.id,
                        enabled: enabled,
                      );
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('hijriPermissionDenied')),
                          ),
                        );
                      }
                    },
                  ),
                  if (reminder.enabled) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.tr('hijriReminderDaysBefore')),
                      trailing: DropdownButton<int>(
                        value: reminder.daysBefore,
                        items: [
                          for (final d in const [0, 1, 2, 3])
                            DropdownMenuItem(
                              value: d,
                              child: Text('$d'),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          provider.setReminder(
                            eventDefinitionId: occurrence.definition.id,
                            enabled: true,
                            daysBefore: value,
                          );
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.tr('hijriReminderTime')),
                      trailing: Text(
                        TimeOfDay(
                          hour: reminder.hour,
                          minute: reminder.minute,
                        ).format(context),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: reminder.hour,
                            minute: reminder.minute,
                          ),
                        );
                        if (picked == null) return;
                        await provider.setReminder(
                          eventDefinitionId: occurrence.definition.id,
                          enabled: true,
                          hour: picked.hour,
                          minute: picked.minute,
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _MonthHeader({
    required this.title,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: onToday,
                child: Text(context.tr('hijriToday')),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final CalendarDayCell cell;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell({
    required this.cell,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasEvent = cell.events.isNotEmpty;
    final bg = selected
        ? AppTheme.primaryGreen.withValues(alpha: 0.18)
        : cell.isToday
            ? AppTheme.accentGold.withValues(alpha: 0.16)
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppTheme.primaryGreen
                    : cell.isToday
                        ? AppTheme.accentGold
                        : scheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cell.hijri.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: cell.isCurrentMonth
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
                Text(
                  '${cell.gregorian.day}',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withValues(
                      alpha: cell.isCurrentMonth ? 0.55 : 0.3,
                    ),
                  ),
                ),
                if (hasEvent)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Wrap(
                      spacing: 2,
                      children: [
                        for (final event in cell.events.take(3))
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Color(event.definition.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final CalendarDayCell cell;
  final bool english;
  final ValueChanged<IslamicEventOccurrence> onEventTap;

  const _SelectedDayCard({
    required this.cell,
    required this.english,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gLabel =
        DateFormat.yMMMEd(english ? 'en' : 'ar').format(cell.gregorian);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surface,
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('hijriSelectedDay'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${context.tr('hijriDate')}: ${cell.hijri}',
          ),
          Text('${context.tr('gregorianDate')}: $gLabel'),
          const SizedBox(height: 10),
          if (cell.events.isEmpty)
            Text(
              context.tr('hijriNoEvents'),
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else
            ...cell.events.map(
              (event) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 8,
                  backgroundColor: Color(event.definition.colorValue),
                ),
                title: Text(event.definition.name(english)),
                onTap: () => onEventTap(event),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final IslamicEventOccurrence occurrence;
  final bool english;
  final VoidCallback onTap;

  const _EventTile({
    required this.occurrence,
    required this.english,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Color(occurrence.definition.colorValue)
              .withValues(alpha: 0.2),
          child: Icon(
            Icons.event_rounded,
            color: Color(occurrence.definition.colorValue),
          ),
        ),
        title: Text(occurrence.definition.name(english)),
        subtitle: Text(
          DateFormat.yMMMd(english ? 'en' : 'ar')
              .format(occurrence.gregorianDate),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final bool english;

  const _Legend({required this.english});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('hijriLegend'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            for (final def in IslamicEventsCatalog.definitions)
              Chip(
                avatar: CircleAvatar(
                  backgroundColor: Color(def.colorValue),
                  radius: 6,
                ),
                label: Text(
                  def.name(english),
                  style: const TextStyle(fontSize: 12),
                ),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }
}
