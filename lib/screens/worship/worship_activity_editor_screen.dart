import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/worship_tracker.dart';
import '../../providers/worship_tracker_provider.dart';

class WorshipActivityEditorScreen extends StatefulWidget {
  final String? activityId;

  const WorshipActivityEditorScreen({super.key, this.activityId});

  @override
  State<WorshipActivityEditorScreen> createState() =>
      _WorshipActivityEditorScreenState();
}

class _WorshipActivityEditorScreenState
    extends State<WorshipActivityEditorScreen> {
  late final TextEditingController _titleEn;
  late final TextEditingController _titleAr;
  late final TextEditingController _noteEn;
  late final TextEditingController _noteAr;
  WorshipActivityKind _kind = WorshipActivityKind.custom;
  WorshipGoalNature _nature = WorshipGoalNature.personal;
  bool _paused = false;
  bool _enabled = true;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  String? _shortcut;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _titleEn = TextEditingController();
    _titleAr = TextEditingController();
    _noteEn = TextEditingController();
    _noteAr = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _hydrate() {
    final provider = context.read<WorshipTrackerProvider>();
    final existing =
        widget.activityId == null ? null : provider.byId(widget.activityId!);
    if (existing != null) {
      _titleEn.text = existing.titleEn;
      _titleAr.text = existing.titleAr;
      _noteEn.text = existing.noteEn ?? '';
      _noteAr.text = existing.noteAr ?? '';
      _kind = existing.kind;
      _nature = existing.nature;
      _paused = existing.paused;
      _enabled = existing.enabled;
      _reminderEnabled = existing.reminderEnabled;
      _shortcut = existing.shortcut;
      if (existing.reminderHour != null && existing.reminderMinute != null) {
        _reminderTime = TimeOfDay(
          hour: existing.reminderHour!,
          minute: existing.reminderMinute!,
        );
      }
    }
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _noteEn.dispose();
    _noteAr.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final titleEn = _titleEn.text.trim();
    final titleAr = _titleAr.text.trim();
    if (titleEn.isEmpty && titleAr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('wtTitleRequired'))),
      );
      return;
    }
    final provider = context.read<WorshipTrackerProvider>();
    final existing =
        widget.activityId == null ? null : provider.byId(widget.activityId!);
    final resolvedEn = titleEn.isEmpty ? titleAr : titleEn;
    final resolvedAr = titleAr.isEmpty ? titleEn : titleAr;

    if (existing == null) {
      await provider.upsertActivity(
        WorshipActivity(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          kind: _kind,
          titleEn: resolvedEn,
          titleAr: resolvedAr,
          noteEn: _noteEn.text.trim().isEmpty ? null : _noteEn.text.trim(),
          noteAr: _noteAr.text.trim().isEmpty ? null : _noteAr.text.trim(),
          nature: _nature,
          paused: _paused,
          enabled: _enabled,
          reminderEnabled: _reminderEnabled,
          reminderHour: _reminderTime.hour,
          reminderMinute: _reminderTime.minute,
          shortcut: _shortcut,
          sortOrder: provider.activities.length,
        ),
      );
    } else {
      await provider.upsertActivity(
        existing.copyWith(
          kind: _kind,
          titleEn: resolvedEn,
          titleAr: resolvedAr,
          noteEn: _noteEn.text.trim(),
          noteAr: _noteAr.text.trim(),
          nature: _nature,
          paused: _paused,
          enabled: _enabled,
          reminderEnabled: _reminderEnabled,
          reminderHour: _reminderTime.hour,
          reminderMinute: _reminderTime.minute,
          shortcut: _shortcut,
          clearShortcut: _shortcut == null,
        ),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final id = widget.activityId;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('wtRemove')),
        content: Text(context.tr('wtRemoveConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('wtRemove')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<WorshipTrackerProvider>().removeActivity(id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activityId == null
              ? context.tr('wtAddActivity')
              : context.tr('wtEdit'),
        ),
        actions: [
          if (widget.activityId != null)
            IconButton(
              tooltip: context.tr('wtRemove'),
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _titleEn,
            decoration: InputDecoration(
              labelText: context.tr('wtTitleEn'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleAr,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: context.tr('wtTitleAr'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteEn,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: context.tr('wtNoteEn'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteAr,
            maxLines: 2,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: context.tr('wtNoteAr'),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr('wtKind')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WorshipActivityKind.values.map((kind) {
              return ChoiceChip(
                label: Text(_kindLabel(context, kind)),
                selected: _kind == kind,
                onSelected: (_) => setState(() => _kind = kind),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(context.tr('wtNature')),
          const SizedBox(height: 8),
          SegmentedButton<WorshipGoalNature>(
            segments: [
              ButtonSegment(
                value: WorshipGoalNature.personal,
                label: Text(context.tr('wtNaturePersonal')),
              ),
              ButtonSegment(
                value: WorshipGoalNature.obligation,
                label: Text(context.tr('wtNatureObligation')),
              ),
            ],
            selected: {_nature},
            onSelectionChanged: (value) {
              setState(() => _nature = value.first);
            },
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('wtNatureHelp'),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr('wtShortcut')),
          DropdownButtonFormField<String?>(
            initialValue: _shortcut,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(context.tr('wtShortcutNone')),
              ),
              DropdownMenuItem(
                value: 'quran',
                child: Text(context.tr('wtShortcutQuran')),
              ),
              DropdownMenuItem(
                value: 'adhkar',
                child: Text(context.tr('wtShortcutAdhkar')),
              ),
              DropdownMenuItem(
                value: 'tasbeeh',
                child: Text(context.tr('wtShortcutTasbeeh')),
              ),
            ],
            onChanged: (value) => setState(() => _shortcut = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('wtEnabled')),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('wtPause')),
            subtitle: Text(context.tr('wtPauseHelp')),
            value: _paused,
            onChanged: (value) => setState(() => _paused = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('wtReminder')),
            subtitle: Text(context.tr('wtReminderHelp')),
            value: _reminderEnabled,
            onChanged: (value) => setState(() => _reminderEnabled = value),
          ),
          if (_reminderEnabled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('wtReminderTime')),
              trailing: Text(_reminderTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (picked != null) {
                  setState(() => _reminderTime = picked);
                }
              },
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  String _kindLabel(BuildContext context, WorshipActivityKind kind) {
    return switch (kind) {
      WorshipActivityKind.prayer => context.tr('wtKindPrayer'),
      WorshipActivityKind.quran => context.tr('wtKindQuran'),
      WorshipActivityKind.adhkar => context.tr('wtKindAdhkar'),
      WorshipActivityKind.tasbeeh => context.tr('wtKindTasbeeh'),
      WorshipActivityKind.learning => context.tr('wtKindLearning'),
      WorshipActivityKind.custom => context.tr('wtKindCustom'),
    };
  }
}
