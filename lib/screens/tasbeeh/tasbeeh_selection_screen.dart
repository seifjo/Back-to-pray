import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tasbeeh.dart';
import '../../providers/tasbeeh_provider.dart';

class TasbeehSelectionScreen extends StatelessWidget {
  const TasbeehSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasbeehProvider>();
    final english = !context.isArabic;
    final favorites = provider.favoriteDhikr;
    final builtIn = provider.allDhikr.where((item) => !item.isCustom).toList();
    final custom = provider.allDhikr.where((item) => item.isCustom).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tasbeehSelectTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('tasbeehAddCustom'),
            onPressed: () => _editCustom(context, provider),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (favorites.isNotEmpty) ...[
            Text(
              context.tr('favorites'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...favorites.map(
              (item) => _DhikrTile(
                item: item,
                english: english,
                selected: item.id == provider.selectedId,
                onSelect: () async {
                  await provider.selectDhikr(item.id);
                  if (context.mounted) Navigator.pop(context);
                },
                onFavorite: () => provider.toggleFavorite(item.id),
                onEdit: item.isCustom
                    ? () => _editCustom(context, provider, existing: item)
                    : null,
                onDelete: item.isCustom
                    ? () => provider.deleteCustom(item.id)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            context.tr('tasbeehBuiltIn'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...builtIn.map(
            (item) => _DhikrTile(
              item: item,
              english: english,
              selected: item.id == provider.selectedId,
              onSelect: () async {
                await provider.selectDhikr(item.id);
                if (context.mounted) Navigator.pop(context);
              },
              onFavorite: () => provider.toggleFavorite(item.id),
            ),
          ),
          if (custom.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              context.tr('tasbeehCustom'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...custom.map(
              (item) => _DhikrTile(
                item: item,
                english: english,
                selected: item.id == provider.selectedId,
                onSelect: () async {
                  await provider.selectDhikr(item.id);
                  if (context.mounted) Navigator.pop(context);
                },
                onFavorite: () => provider.toggleFavorite(item.id),
                onEdit: () => _editCustom(context, provider, existing: item),
                onDelete: () => provider.deleteCustom(item.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editCustom(
    BuildContext context,
    TasbeehProvider provider, {
    TasbeehDhikr? existing,
  }) async {
    final arabic = TextEditingController(text: existing?.arabic ?? '');
    final nameEn = TextEditingController(text: existing?.nameEn ?? '');
    final nameAr = TextEditingController(text: existing?.nameAr ?? '');
    final goal = TextEditingController(
      text: existing?.personalTarget?.toString() ?? '',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existing == null
              ? context.tr('tasbeehAddCustom')
              : context.tr('tasbeehEditCustom'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: arabic,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: context.tr('tasbeehArabicText'),
                ),
              ),
              TextField(
                controller: nameAr,
                decoration: InputDecoration(
                  labelText: context.tr('tasbeehNameAr'),
                ),
              ),
              TextField(
                controller: nameEn,
                decoration: InputDecoration(
                  labelText: context.tr('tasbeehNameEn'),
                ),
              ),
              TextField(
                controller: goal,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('tasbeehGoalHint'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
    if (saved != true) return;
    if (arabic.text.trim().isEmpty) return;
    final target = int.tryParse(goal.text.trim());
    if (existing == null) {
      await provider.addCustom(
        arabic: arabic.text,
        nameEn: nameEn.text,
        nameAr: nameAr.text,
        personalTarget: target,
      );
    } else {
      await provider.updateCustom(
        id: existing.id,
        arabic: arabic.text,
        nameEn: nameEn.text,
        nameAr: nameAr.text,
        personalTarget: target,
      );
    }
  }
}

class _DhikrTile extends StatelessWidget {
  final TasbeehDhikr item;
  final bool english;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DhikrTile({
    required this.item,
    required this.english,
    required this.selected,
    required this.onSelect,
    required this.onFavorite,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: selected
          ? AppTheme.primaryGreen.withValues(alpha: 0.12)
          : scheme.surface,
      child: ListTile(
        onTap: onSelect,
        title: Text(
          item.arabic,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'serif', fontSize: 20),
        ),
        subtitle: Text(
          [
            item.displayName(english),
            if (item.usesPersonalGoal)
              '${context.tr('tasbeehPersonalGoal')}: ${item.personalTarget}'
            else if (item.hasTraditionalTarget)
              '${context.tr('tasbeehTraditionalGoal')}: ${item.traditionalTarget}'
            else
              context.tr('tasbeehUnlimited'),
          ].join(' · '),
        ),
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
            if (onEdit != null)
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ),
    );
  }
}
