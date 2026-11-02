import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tasbeeh.dart';
import '../../providers/tasbeeh_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'tasbeeh_selection_screen.dart';
import 'tasbeeh_stats_screen.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  DateTime? _lastTapAt;
  static const _tapGuard = Duration(milliseconds: 90);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.96,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _tapCount(TasbeehProvider provider) async {
    final now = DateTime.now();
    if (_lastTapAt != null && now.difference(_lastTapAt!) < _tapGuard) {
      return;
    }
    _lastTapAt = now;
    await provider.increment();
    if (!mounted) return;
    await _pulse.reverse();
    if (!mounted) return;
    await _pulse.forward();
  }

  Future<void> _confirmReset(TasbeehProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('tasbeehReset')),
        content: Text(context.tr('tasbeehResetConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('tasbeehReset')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.resetCurrent(confirmed: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasbeehProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final dhikr = provider.selected;
    final target = provider.activeTarget;
    final count = provider.currentCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tasbeehTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('tasbeehStats'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasbeehStatsScreen()),
              );
            },
            icon: const Icon(Icons.insights_outlined),
          ),
          IconButton(
            tooltip: context.tr('settings'),
            onPressed: () => _openSettings(),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: scheme.onSurface.withValues(alpha: 0.03),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  _DhikrHeaderCard(
                    dhikr: dhikr,
                    english: english,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TasbeehSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: ScaleTransition(
                        scale: _pulse,
                        child: Semantics(
                          button: true,
                          label: context.tr('tasbeehTapToCount'),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _tapCount(provider),
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0,
                                        end: target == null
                                            ? 0
                                            : provider.progress,
                                      ),
                                      duration:
                                          const Duration(milliseconds: 280),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, _) {
                                        return SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: CircularProgressIndicator(
                                            value: value,
                                            strokeWidth: 11,
                                            backgroundColor: scheme.onSurface
                                                .withValues(alpha: 0.08),
                                            color: AppTheme.primaryGreen,
                                          ),
                                        );
                                      },
                                    ),
                                    Container(
                                      width: 244,
                                      height: 244,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.primaryGreen
                                            .withValues(alpha: 0.12),
                                        border: Border.all(
                                          color: AppTheme.primaryGreen
                                              .withValues(alpha: 0.35),
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 160,
                                            ),
                                            transitionBuilder: (child, anim) {
                                              return FadeTransition(
                                                opacity: anim,
                                                child: ScaleTransition(
                                                  scale: Tween<double>(
                                                    begin: 0.92,
                                                    end: 1,
                                                  ).animate(anim),
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              '$count',
                                              key: ValueKey(count),
                                              style: TextStyle(
                                                fontSize: 64,
                                                fontWeight: FontWeight.w800,
                                                height: 1,
                                                color: scheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            target == null
                                                ? context
                                                    .tr('tasbeehUnlimited')
                                                : '${context.tr('tasbeehTarget')}: $target',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: scheme.onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            context.tr('tasbeehTapToCount'),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.primaryGreen
                                                  .withValues(alpha: 0.9),
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
                        ),
                      ),
                    ),
                  ),
                  if (dhikr.hasTraditionalTarget || dhikr.usesPersonalGoal)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        dhikr.usesPersonalGoal
                            ? context.tr('tasbeehPersonalGoalNote')
                            : (dhikr.traditionalNote(english) ??
                                context.tr('tasbeehTraditionalGoalNote')),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              provider.canUndo ? () => provider.undo() : null,
                          icon: const Icon(Icons.undo_rounded),
                          label: Text(context.tr('tasbeehUndo')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: count == 0
                              ? null
                              : () => _confirmReset(provider),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.tr('tasbeehReset')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Consumer<TasbeehProvider>(
          builder: (context, provider, _) {
            final scheme = Theme.of(context).colorScheme;
            final personal = provider.selected.personalTarget;
            final goalLabel = personal == null
                ? context.tr('tasbeehUnlimited')
                : context
                    .tr('tasbeehGoalCurrent')
                    .replaceAll('{value}', '$personal');

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('tasbeehSettingsTitle'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.selected.displayName(!context.isArabic),
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsToggleRow(
                      icon: Icons.vibration_rounded,
                      title: context.tr('tasbeehHaptic'),
                      subtitle: context.tr('tasbeehHapticHelp'),
                      value: provider.hapticEnabled,
                      onChanged: provider.setHapticEnabled,
                    ),
                    const SizedBox(height: 8),
                    _SettingsToggleRow(
                      icon: Icons.volume_up_outlined,
                      title: context.tr('tasbeehSound'),
                      subtitle: context.tr('tasbeehSoundHelp'),
                      value: provider.soundEnabled,
                      onChanged: provider.setSoundEnabled,
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: scheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await _editGoal(provider, provider.selected);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.flag_outlined,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('tasbeehSetGoal'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      goalLabel,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: scheme.onSurface.withValues(alpha: 0.45),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editGoal(TasbeehProvider provider, TasbeehDhikr dhikr) async {
    final controller = TextEditingController(
      text: dhikr.personalTarget?.toString() ?? '',
    );
    String? error;

    final result = await showDialog<int?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(context.tr('tasbeehSetGoal')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: context.tr('tasbeehGoalHint'),
                      errorText: error,
                    ),
                    onSubmitted: (_) {
                      final parsed = _parseGoal(controller.text);
                      if (parsed.error != null) {
                        setLocal(() => error = context.tr('tasbeehGoalInvalid'));
                        return;
                      }
                      Navigator.pop(context, parsed.value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, -1),
                  child: Text(context.tr('tasbeehClearGoal')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    final parsed = _parseGoal(controller.text);
                    if (parsed.error != null) {
                      setLocal(() => error = context.tr('tasbeehGoalInvalid'));
                      return;
                    }
                    Navigator.pop(context, parsed.value);
                  },
                  child: Text(context.tr('save')),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    if (result == null) return;
    if (result <= 0) {
      await provider.setPersonalTarget(dhikr.id, null);
    } else {
      await provider.setPersonalTarget(dhikr.id, result);
    }
  }

  /// Empty → clear (-1). Invalid → error. Valid → positive int.
  ({int? value, String? error}) _parseGoal(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return (value: -1, error: null);
    final value = int.tryParse(text);
    if (value == null || value < 1 || value > 999999) {
      return (value: null, error: 'invalid');
    }
    return (value: value, error: null);
  }
}

class _DhikrHeaderCard extends StatelessWidget {
  const _DhikrHeaderCard({
    required this.dhikr,
    required this.english,
    required this.onTap,
  });

  final TasbeehDhikr dhikr;
  final bool english;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Text(
                dhikr.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dhikr.displayName(english),
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('tasbeehChangeDhikr'),
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: value
            ? AppTheme.primaryGreen.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? AppTheme.primaryGreen.withValues(alpha: 0.35)
              : scheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: value
                      ? AppTheme.primaryGreen
                      : scheme.onSurface.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IgnorePointer(
                  child: Switch.adaptive(
                    value: value,
                    onChanged: (_) {},
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
