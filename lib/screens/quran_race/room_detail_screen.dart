import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/quran_race_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/quran_race/participant_card.dart';
import '../../widgets/quran_race/completion_celebration.dart';
import '../quran/quran_screen.dart';
import '../../providers/quran_provider.dart';
import '../../data/quran_data.dart';

/// Room Detail Screen
/// Shows inside-room view with leaderboard, participants, and live status.
class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<QuranRaceProvider>(
      builder: (context, raceProvider, _) {
        final room = raceProvider.currentRoom;
        if (room == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final leaderboard = room.leaderboard;
        final myParticipant = raceProvider.myParticipant;

        // Check if someone just completed
        for (final entry in room.participants.entries) {
          if (entry.value.hasCompletedKhatma &&
              entry.value.badges.contains('khatm_complete')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCompletionCelebration(context, entry.value.displayName);
            });
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room header
              _buildRoomHeader(context, theme, room, raceProvider),
              const SizedBox(height: 16),

              // Start Reading CTA
              _buildStartReadingCTA(context, theme),
              const SizedBox(height: 16),

              // My progress card
              if (myParticipant != null) ...[
                _buildMyProgressCard(theme, myParticipant),
                const SizedBox(height: 16),
              ],

              // Leaderboard title
              Row(
                children: [
                  Icon(Icons.leaderboard,
                      color: theme.colorScheme.secondary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'ترتيب المتسابقين',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${room.participants.length} مشترك',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Participants list
              if (leaderboard.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'لا يوجد مشتركون بعد',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ...leaderboard.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final participant = entry.value.value;
                  final isMe = entry.value.key == raceProvider.currentUserId;
                  final isAdmin = entry.value.key == room.creatorId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ParticipantCard(
                      participant: participant,
                      rank: rank,
                      isCurrentUser: isMe,
                      isAdmin: isAdmin,
                      onKick: raceProvider.isRoomAdmin && !isMe
                          ? () => _confirmKickParticipant(context, raceProvider, participant)
                          : null,
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Motivational footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '💡 التسابق في الخيرات من أعظم العبادات\nاستمر في القراءة وسيتم تحديث تقدمك تلقائياً',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Leave / Delete room
              _buildRoomActions(context, theme, raceProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoomHeader(
    BuildContext context,
    ThemeData theme,
    dynamic room,
    QuranRaceProvider raceProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Room name
          Text(
            room.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          // Goal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🎯 ${room.goalDisplayText}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          // Room ID & Share
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'رمز الغرفة: ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  room.id,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy, size: 18, color: theme.colorScheme.secondary),
                tooltip: 'نسخ الرمز',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: room.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رمز الغرفة')),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.share, size: 18, color: theme.colorScheme.secondary),
                tooltip: 'مشاركة',
                onPressed: () {
                  Share.share(
                    '📖 انضم معي في سباق ختم القرآن الكريم!\n\n'
                    '📍 اسم الغرفة: ${room.name}\n'
                    '🎯 الهدف: ${room.goalDisplayText}\n'
                    '🔑 رمز الدخول: ${room.id}\n\n'
                    'حمّل تطبيق "عد إليّ" وانضم للسباق الآن! 🚀',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyProgressCard(ThemeData theme, dynamic myParticipant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.person, color: theme.colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'تقدمي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'الجزء',
                value: '${myParticipant.currentJuz}',
                theme: theme,
              ),
              _StatItem(
                label: 'الصفحات',
                value: '${myParticipant.totalPagesRead}',
                theme: theme,
              ),
              _StatItem(
                label: 'الإنجاز',
                value: '${myParticipant.completionPercentage.toStringAsFixed(1)}%',
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: myParticipant.completionPercentage / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomActions(
    BuildContext context,
    ThemeData theme,
    QuranRaceProvider raceProvider,
  ) {
    return Column(
      children: [
        if (raceProvider.isRoomAdmin)
          OutlinedButton.icon(
            onPressed: () => _confirmDeleteRoom(context, raceProvider),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('حذف الغرفة', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _confirmLeaveRoom(context, raceProvider),
          icon: Icon(Icons.logout, color: Colors.orange[300]),
          label: Text('مغادرة الغرفة',
              style: TextStyle(color: Colors.orange[300])),
        ),
      ],
    );
  }

  Widget _buildStartReadingCTA(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToQuran(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ابدأ القراءة الآن',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'تابع تقدمك في الختمة ونافس أصدقاءك',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToQuran(BuildContext context) {
    final quranProvider = context.read<QuranProvider>();
    final surahNumber = quranProvider.lastSurahNumber ?? 1;
    final surah = QuranData.surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => QuranData.surahs.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(surah: surah),
      ),
    );
  }

  void _confirmLeaveRoom(BuildContext context, QuranRaceProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مغادرة الغرفة'),
        content: const Text('هل أنت متأكد من مغادرة الغرفة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.leaveRoom();
            },
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRoom(BuildContext context, QuranRaceProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الغرفة'),
        content: const Text('سيتم حذف الغرفة نهائياً لجميع المشتركين. هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteRoom();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmKickParticipant(BuildContext context, QuranRaceProvider provider, dynamic participant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إزالة مشارك'),
        content: Text('هل أنت متأكد من إزالة "${participant.displayName}" من الغرفة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.kickParticipant(participant.odId);
            },
            child: const Text('إزالة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCompletionCelebration(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => CompletionCelebrationDialog(completedByName: name),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _StatItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 2),
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
