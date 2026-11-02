import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/services/device_feedback.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/adhkar.dart';
import '../../providers/adhkar_progress_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/daily_achievements_provider.dart';

/// Comfortable Arabic reading style that does not depend on network fonts.
TextStyle adhkarArabicStyle({
  required double fontSize,
  required Color color,
  double height = 1.95,
}) {
  return TextStyle(
    fontSize: fontSize,
    height: height,
    color: color,
    fontFamilyFallback: const [
      'Noto Naskh Arabic',
      'Noto Sans Arabic',
      'Amiri',
      'serif',
    ],
  );
}

TextStyle adhkarTranslationStyle({
  required double fontSize,
  required Color color,
}) {
  return TextStyle(
    fontSize: fontSize,
    height: 1.55,
    color: color,
    fontWeight: FontWeight.w400,
  );
}

class AdhkarReaderScreen extends StatefulWidget {
  final AdhkarCategory category;
  final int initialIndex;

  const AdhkarReaderScreen({
    super.key,
    required this.category,
    this.initialIndex = 0,
  });

  @override
  State<AdhkarReaderScreen> createState() => _AdhkarReaderScreenState();
}

class _AdhkarReaderScreenState extends State<AdhkarReaderScreen> {
  late int _index;
  late final PageController _pages;
  bool _showCompletion = false;
  bool _busy = false;

  AdhkarCategory get _category => widget.category;

  int get _total => _category.items.length;

  AdhkarItem get _item => _category.items[_index];

  String _itemId(AdhkarItem item) =>
      item.id.isEmpty ? item.arabicText : item.id;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, (_total - 1).clamp(0, 9999));
    _pages = PageController(initialPage: _index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final progress = context.read<AdhkarProgressProvider>();
      progress.ensureToday();
      progress.recordView(_category.stableId, _itemId(_item));
      if (progress.isCategoryComplete(_category)) {
        setState(() => _showCompletion = true);
      }
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index, {bool animate = true}) async {
    if (index < 0 || index >= _total) return;
    if (animate && _pages.hasClients) {
      await _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else if (_pages.hasClients) {
      _pages.jumpToPage(index);
    } else {
      setState(() => _index = index);
    }
  }

  Future<void> _onPageChanged(int index) async {
    setState(() {
      _index = index;
      _showCompletion = false;
    });
    final viewed = _category.items[index];
    await context.read<AdhkarProgressProvider>().recordView(
          _category.stableId,
          _itemId(viewed),
        );
  }

  Future<void> _count() async {
    if (_busy) return;
    final settings = context.read<AppSettingsProvider>();
    final progress = context.read<AdhkarProgressProvider>();
    final item = _item;
    final id = _itemId(item);
    final before = progress.countFor(_category.stableId, id);
    if (before >= item.repetitions) {
      _snack(context.tr('adhkarAlreadyComplete'));
      return;
    }

    setState(() => _busy = true);
    if (settings.hapticEnabled) {
      // ignore: unawaited_futures
      DeviceFeedback.vibrate();
    }
    await progress.increment(_category.stableId, id, item.repetitions);
    if (!mounted) return;

    final after = progress.countFor(_category.stableId, id);
    final justFinished = after >= item.repetitions;
    if (justFinished) {
      HapticFeedback.mediumImpact();
      await _afterItemFinished(progress, autoAdvance: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _markComplete() async {
    if (_busy) return;
    final progress = context.read<AdhkarProgressProvider>();
    final item = _item;
    final id = _itemId(item);
    if (progress.countFor(_category.stableId, id) >= item.repetitions) {
      await _goTo((_index + 1).clamp(0, _total - 1));
      return;
    }

    setState(() => _busy = true);
    await progress.markComplete(_category.stableId, item);
    if (!mounted) return;
    HapticFeedback.selectionClick();
    await _afterItemFinished(progress, autoAdvance: true);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _afterItemFinished(
    AdhkarProgressProvider progress, {
    required bool autoAdvance,
  }) async {
    if (progress.isCategoryComplete(_category)) {
      await _awardCategory(_category);
      if (!mounted) return;
      setState(() => _showCompletion = true);
      return;
    }
    if (autoAdvance && _index < _total - 1) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (mounted) await _goTo(_index + 1);
    }
  }

  Future<void> _toggleFavorite() async {
    final progress = context.read<AdhkarProgressProvider>();
    final id = _itemId(_item);
    final wasFavorite = progress.isFavorite(_category.stableId, id);
    await progress.toggleFavorite(_category.stableId, id);
    if (!mounted) return;
    _snack(
      wasFavorite
          ? context.tr('adhkarBookmarkRemoved')
          : context.tr('adhkarBookmarkAdded'),
    );
  }

  Future<void> _reset() async {
    final progress = context.read<AdhkarProgressProvider>();
    final id = _itemId(_item);
    final count = progress.countFor(_category.stableId, id);
    if (count <= 0) {
      _snack(context.tr('adhkarAlreadyReset'));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('resetCounter')),
        content: Text(context.tr('adhkarResetConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr('resetCounter')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await progress.reset(_category.stableId, id);
    if (!mounted) return;
    setState(() => _showCompletion = false);
    _snack(context.tr('adhkarResetDone'));
  }

  Future<void> _restartCategory() async {
    final progress = context.read<AdhkarProgressProvider>();
    for (final item in _category.items) {
      await progress.reset(_category.stableId, _itemId(item));
    }
    if (!mounted) return;
    setState(() => _showCompletion = false);
    await _goTo(0, animate: false);
  }

  void _cycleFontSize(AppSettingsProvider settings) {
    const steps = [
      AppSettingsProvider.fontSmall,
      AppSettingsProvider.fontMedium,
      AppSettingsProvider.fontLarge,
      AppSettingsProvider.fontExtraLarge,
    ];
    final current = settings.adhkarFontSize;
    final nextIndex = (steps.indexWhere((s) => (s - current).abs() < 0.5) + 1) %
        steps.length;
    settings.setAdhkarFontSize(steps[nextIndex < 0 ? 1 : nextIndex]);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  Future<void> _awardCategory(AdhkarCategory category) async {
    const ids = {
      'morning': 'adhkar_morning',
      'evening': 'adhkar_evening',
      'before_sleep': 'adhkar_sleep',
    };
    final achievementId = ids[category.stableId];
    if (achievementId == null || !mounted) return;
    try {
      await context
          .read<DailyAchievementsProvider>()
          .completeAchievement(achievementId);
    } catch (e) {
      debugPrint('Error marking adhkar achievement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final progress = context.watch<AdhkarProgressProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final item = _item;
    final itemId = _itemId(item);
    final count = progress.countFor(_category.stableId, itemId);
    final remaining = (item.repetitions - count).clamp(0, item.repetitions);
    final done = count >= item.repetitions;
    final favorite = progress.isFavorite(_category.stableId, itemId);
    final categoryRatio = progress.progressFor(_category);
    final categoryDone = progress.isCategoryComplete(_category);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _category.displayName(english),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: context.tr('arabicTextSize'),
            onPressed: () => _cycleFontSize(settings),
            icon: const Icon(Icons.text_fields_rounded),
          ),
          IconButton(
            tooltip: context.tr('showTranslation'),
            onPressed: () =>
                settings.setShowTranslation(!settings.showTranslation),
            icon: Icon(
              settings.showTranslation
                  ? Icons.translate
                  : Icons.translate_outlined,
            ),
          ),
          IconButton(
            tooltip: context.tr('favorites'),
            onPressed: _toggleFavorite,
            icon: Icon(
              favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: favorite ? AppTheme.accentGold : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _ReaderHeader(
                  index: _index,
                  total: _total,
                  categoryRatio: categoryRatio,
                  categoryDone: categoryDone,
                  swipeHint: context.tr('turnPage'),
                  scheme: scheme,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: _total,
                    // Locale Directionality drives natural RTL/LTR paging.
                    // Logical indices stay 0..n-1; prev/next use those indices.
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      return SizedBox.expand(
                        child: _DhikrPageCard(
                          item: _category.items[index],
                          settings: settings,
                          scheme: scheme,
                        ),
                      );
                    },
                  ),
                ),
                _CounterStrip(
                  count: count,
                  total: item.repetitions,
                  remaining: remaining,
                  done: done,
                  scheme: scheme,
                ),
                _ControlBar(
                  canPrevious: _index > 0,
                  canNext: _index < _total - 1,
                  done: done,
                  favorite: favorite,
                  busy: _busy,
                  onPrevious: () => _goTo(_index - 1),
                  onNext: () => _goTo(_index + 1),
                  onReset: _reset,
                  onFavorite: _toggleFavorite,
                  onCount: _count,
                  onComplete: _markComplete,
                ),
              ],
            ),
            if (_showCompletion && categoryDone)
              _CompletionOverlay(
                categoryName: _category.displayName(english),
                onRestart: _restartCategory,
                onBack: () => Navigator.of(context).maybePop(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReaderHeader extends StatelessWidget {
  const _ReaderHeader({
    required this.index,
    required this.total,
    required this.categoryRatio,
    required this.categoryDone,
    required this.swipeHint,
    required this.scheme,
  });

  final int index;
  final int total;
  final double categoryRatio;
  final bool categoryDone;
  final String swipeHint;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${index + 1} / $total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              if (categoryDone)
                Text(
                  context.tr('categoryComplete'),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                )
              else
                Text(
                  '${(categoryRatio * 100).round()}%',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: categoryRatio.clamp(0.0, 1.0),
              minHeight: 6,
              color: categoryDone ? Colors.green : AppTheme.accentGold,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.swipe_rounded,
                  size: 18,
                  color: scheme.primary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    swipeHint,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrPageCard extends StatelessWidget {
  const _DhikrPageCard({
    required this.item,
    required this.settings,
    required this.scheme,
  });

  final AdhkarItem item;
  final AppSettingsProvider settings;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final showMeaning = settings.showTranslation;
    // User-selected preset; Text applies MediaQuery text scaling on top.
    final arabicSize = settings.adhkarFontSize;
    // Keep translation proportional — never hard-cap at 24 when Arabic is XL.
    final translationSize = (arabicSize * 0.62).clamp(14.0, arabicSize);

    // Architecture:
    // PageView slot (SizedBox.expand)
    //   -> padded card chrome (no fixed height)
    //   -> SingleChildScrollView (owns vertical overflow)
    //   -> Column(mainAxisSize: min) with soft-wrapping Text (no maxLines)
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.arabicText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                softWrap: true,
                style: adhkarArabicStyle(
                  fontSize: arabicSize,
                  color: scheme.onSurface,
                ),
              ),
              if (showMeaning) ...[
                const SizedBox(height: 22),
                Text(
                  context.tr('meaning'),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.4,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.translation,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  softWrap: true,
                  style: adhkarTranslationStyle(
                    fontSize: translationSize,
                    color: scheme.onSurface.withValues(alpha: 0.82),
                  ),
                ),
                if (item.explanation != null &&
                    item.explanation!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    item.explanation!,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.62),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 18),
              Text(
                item.attributionLine,
                textAlign: TextAlign.center,
                softWrap: true,
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              if (item.narrator != null &&
                  item.narrator!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '${context.tr('adhkarNarrator')}: ${item.narrator}',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                  ),
                ),
              ],
              if (item.authenticity != null &&
                  item.authenticity!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${context.tr('adhkarAuthenticity')}: ${item.authenticity}',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterStrip extends StatelessWidget {
  const _CounterStrip({
    required this.count,
    required this.total,
    required this.remaining,
    required this.done,
    required this.scheme,
  });

  final int count;
  final int total;
  final int remaining;
  final bool done;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Column(
        children: [
          Text(
            '$count / $total',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: done ? Colors.green : scheme.primary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            done
                ? context.tr('adhkarItemDone')
                : context
                    .tr('adhkarRemaining')
                    .replaceAll('{count}', '$remaining'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.canPrevious,
    required this.canNext,
    required this.done,
    required this.favorite,
    required this.busy,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
    required this.onFavorite,
    required this.onCount,
    required this.onComplete,
  });

  final bool canPrevious;
  final bool canNext;
  final bool done;
  final bool favorite;
  final bool busy;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final VoidCallback onFavorite;
  final VoidCallback onCount;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Keep physical left=previous / right=next so RTL layout does not swap
    // the meaning of the navigation buttons.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Column(
          children: [
            Row(
              children: [
                _RoundAction(
                  tooltip: context.tr('previous'),
                  onPressed: canPrevious && !busy ? onPrevious : null,
                  icon: Icons.chevron_left_rounded,
                ),
                const SizedBox(width: 6),
                _RoundAction(
                  tooltip: context.tr('resetCounter'),
                  onPressed: busy ? null : onReset,
                  icon: Icons.restart_alt_rounded,
                ),
                const SizedBox(width: 6),
                _RoundAction(
                  tooltip: context.tr('favorites'),
                  onPressed: busy ? null : onFavorite,
                  icon: favorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  activeColor: AppTheme.accentGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: busy || done ? null : onCount,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(context.tr('count')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: busy ? null : onComplete,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      done
                          ? context.tr('next')
                          : context.tr('markComplete'),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _RoundAction(
                  tooltip: context.tr('next'),
                  onPressed: canNext && !busy ? onNext : null,
                  icon: Icons.chevron_right_rounded,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('adhkarControlsHint'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.activeColor,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: activeColor),
      ),
    );
  }
}

class _CompletionOverlay extends StatelessWidget {
  const _CompletionOverlay({
    required this.categoryName,
    required this.onRestart,
    required this.onBack,
  });

  final String categoryName;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: ColoredBox(
        color: scheme.scrim.withValues(alpha: 0.45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: scheme.surface,
              elevation: 8,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 52,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.tr('adhkarCategoryFinished'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categoryName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('adhkarCategoryFinishedHelp'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onRestart,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(context.tr('adhkarRestart')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(context.tr('adhkarBackToCategory')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
