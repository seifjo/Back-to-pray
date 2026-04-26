import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rewards_provider.dart';
import '../../core/theme/app_theme.dart';

/// Settings Screen
/// Theme management and app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<RewardsProvider>(
        builder: (context, rewardsProvider, _) {
          final ownedThemes = rewardsProvider.getOwnedThemes();
          final hasExportFeature = rewardsProvider.isFeatureUnlocked('feature_export');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Management Section
              const Text(
                '🎨 إدارة الثيمات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر الثيم المفضل لك',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),

              // Default Theme Card
              _buildThemeCard(
                context,
                title: 'الثيم الأصلي',
                description: 'الألوان الافتراضية للتطبيق',
                icon: '🏠',
                themeId: null,
                isActive: rewardsProvider.activeThemeId == null,
                onTap: () => _applyTheme(context, null, rewardsProvider),
              ),

              const SizedBox(height: 12),

              // Owned Themes
              if (ownedThemes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ليس لديك ثيمات إضافية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اذهب إلى متجر المكافآت لشراء ثيمات جديدة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...ownedThemes.map((theme) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildThemeCard(
                      context,
                      title: theme.title,
                      description: theme.description,
                      icon: theme.icon,
                      themeId: theme.themeId,
                      isActive: rewardsProvider.activeThemeId == theme.themeId,
                      onTap: () => _applyTheme(
                        context,
                        theme.themeId,
                        rewardsProvider,
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 32),

              // Export Data Section (if unlocked)
              if (hasExportFeature) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  '📤 تصدير البيانات',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _exportData(context),
                  icon: const Icon(Icons.download),
                  label: const Text('تصدير بياناتي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'صدّر رحلتك وإنجازاتك كملف JSON',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required String? themeId,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isActive ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? const BorderSide(color: AppTheme.accentCyan, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Theme Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.accentCyan.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Theme Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppTheme.accentCyan : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Active Indicator
              if (isActive)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.accentCyan,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyTheme(
    BuildContext context,
    String? themeId,
    RewardsProvider provider,
  ) {
    if (themeId == null) {
      provider.resetToDefaultTheme();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استعادة الثيم الأصلي'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } else {
      provider.setActiveTheme(themeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تطبيق الثيم الجديد'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  void _exportData(BuildContext context) {
    // TODO: Implement actual data export
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: const Text(
          'سيتم قريباً تنفيذ ميزة تصدير البيانات.\n\n'
          'ستتمكن من حفظ:\n'
          '• تقدم رحلتك\n'
          '• إنجازاتك\n'
          '• إحصائياتك\n\n'
          'كملف JSON على جهازك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
