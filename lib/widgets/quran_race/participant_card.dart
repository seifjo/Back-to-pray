import 'package:flutter/material.dart';
import '../../models/quran_race_room.dart';
import '../../core/theme/app_theme.dart';

/// Participant Card
/// Displays a single participant's progress in the race room.
class ParticipantCard extends StatelessWidget {
  final RoomParticipant participant;
  final int rank;
  final bool isCurrentUser;
  final bool isAdmin;
  final VoidCallback? onKick;

  const ParticipantCard({
    super.key,
    required this.participant,
    required this.rank,
    this.isCurrentUser = false,
    this.isAdmin = false,
    this.onKick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Top row: rank, name, live indicator
          Row(
            children: [
              _buildRankBadge(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            participant.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isCurrentUser
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'أنت',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                        if (isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield, size: 10, color: AppTheme.accentGold),
                                const SizedBox(width: 3),
                                Text(
                                  'مدير',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Live status
                    _buildLiveStatus(theme),
                  ],
                ),
              ),
              // Completion percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${participant.completionPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Text(
                    'إنجاز',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              // Kick button (Admin only)
              if (onKick != null && !isCurrentUser) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.person_remove_outlined, color: Colors.red, size: 20),
                  onPressed: onKick,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'إزالة من الغرفة',
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: participant.completionPercentage / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(
                _getProgressColor(theme, participant.completionPercentage),
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                icon: Icons.library_books_outlined,
                label: 'جزء ${participant.currentJuz}',
                theme: theme,
              ),
              _InfoChip(
                icon: Icons.book_outlined,
                label: participant.currentSurahName,
                theme: theme,
              ),
              _InfoChip(
                icon: Icons.format_list_numbered,
                label: 'آية ${participant.currentAyah}',
                theme: theme,
              ),
            ],
          ),

          // Badges
          if (participant.badges.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: participant.badges.map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getBadgeLabel(badge),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankBadge(ThemeData theme) {
    Color badgeColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Gold
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Silver
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = AppTheme.textSecondary;
        icon = null;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: badgeColor, size: 22)
            : Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
      ),
    );
  }

  Widget _buildLiveStatus(ThemeData theme) {
    if (participant.isCurrentlyReading) {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'يقرأ الآن',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // Show last activity
    final lastActivity = participant.lastActivity;
    if (lastActivity != null) {
      final diff = DateTime.now().difference(lastActivity);
      String timeText;
      if (diff.inMinutes < 1) {
        timeText = 'الآن';
      } else if (diff.inMinutes < 60) {
        timeText = 'منذ ${diff.inMinutes} دقيقة';
      } else if (diff.inHours < 24) {
        timeText = 'منذ ${diff.inHours} ساعة';
      } else {
        timeText = 'منذ ${diff.inDays} يوم';
      }

      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'آخر نشاط $timeText',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Color _getProgressColor(ThemeData theme, double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return theme.colorScheme.secondary;
    if (percentage >= 25) return theme.colorScheme.primary;
    return theme.colorScheme.primary.withValues(alpha: 0.7);
  }

  String _getBadgeLabel(String badge) {
    switch (badge) {
      case 'khatm_complete':
        return '🏆 أتم الختمة';
      case 'fastest_today':
        return '⚡ أسرع قارئ اليوم';
      case 'most_consistent':
        return '🔥 أكثر التزاماً';
      default:
        return badge;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
