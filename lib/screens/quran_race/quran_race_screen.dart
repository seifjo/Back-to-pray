import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/quran_race_provider.dart';
import '../../core/theme/app_theme.dart';
import 'room_detail_screen.dart';
import 'create_room_dialog.dart';
import 'join_room_dialog.dart';

/// Quran Race Screen — Lobby
/// Users can create rooms, join rooms, and browse public rooms.
class QuranRaceScreen extends StatefulWidget {
  const QuranRaceScreen({super.key});

  @override
  State<QuranRaceScreen> createState() => _QuranRaceScreenState();
}

class _QuranRaceScreenState extends State<QuranRaceScreen> {
  @override
  void initState() {
    super.initState();
    // Load public rooms on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranRaceProvider>().loadPublicRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('raceTitle')),
        centerTitle: true,
      ),
      body: Consumer<QuranRaceProvider>(
        builder: (context, raceProvider, child) {
          // If user is in a room, navigate to room detail
          if (raceProvider.isInRoom) {
            return const RoomDetailScreen();
          }

          return RefreshIndicator(
            onRefresh: () => raceProvider.loadPublicRooms(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Motivational header
                  _buildMotivationalHeader(theme),
                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(context, raceProvider),
                  const SizedBox(height: 24),

                  // Error message
                  if (raceProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              raceProvider.error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => raceProvider.clearError(),
                          ),
                        ],
                      ),
                    ),

                  // Public rooms
                  _buildPublicRoomsSection(theme, raceProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMotivationalHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            theme.colorScheme.secondary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 48,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            '﴿ فَاسْتَبِقُوا الْخَيْرَاتِ ﴾',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'سابق إخوانك في ختم القرآن الكريم',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, QuranRaceProvider raceProvider) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Create Room — with lightning effect
        Expanded(
          child: _AnimatedActionButton(
            icon: Icons.add_circle_outline,
            label: 'إنشاء غرفة',
            color: theme.colorScheme.primary,
            onTap: () => _showCreateRoomDialog(context),
            showLightning: true,
          ),
        ),
        const SizedBox(width: 12),
        // Join Room
        Expanded(
          child: _AnimatedActionButton(
            icon: Icons.login_rounded,
            label: 'انضمام بالرمز',
            color: theme.colorScheme.secondary,
            onTap: () => _showJoinRoomDialog(context),
          ),
        ),
      ],
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateRoomDialog(),
    );
  }

  void _showJoinRoomDialog(BuildContext context, {String? roomId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JoinRoomDialog(initialRoomId: roomId),
    );
  }

  Widget _buildPublicRoomsSection(ThemeData theme, QuranRaceProvider raceProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.public, color: theme.colorScheme.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'غرف عامة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (raceProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (raceProvider.publicRooms.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.groups_outlined,
                    size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'لا توجد غرف عامة حالياً',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'كن أول من ينشئ غرفة!',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          ...raceProvider.publicRooms.map((room) => _PublicRoomCard(
                room: room,
                onJoin: () => _showJoinRoomDialog(context, roomId: room.id),
              )),
      ],
    );
  }
}

/// Animated action button with optional lightning/glow effect
class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool showLightning;

  const _AnimatedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.showLightning = false,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.showLightning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowValue = widget.showLightning ? _glowAnimation.value : 0.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.color.withValues(alpha: 0.25 + (glowValue * 0.15)),
                    widget.color.withValues(alpha: 0.1 + (glowValue * 0.1)),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3 + (glowValue * 0.4)),
                  width: 1.0 + (glowValue * 0.5),
                ),
                boxShadow: widget.showLightning
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.2 * glowValue),
                          blurRadius: 12 * glowValue,
                          spreadRadius: 2 * glowValue,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(widget.icon, color: widget.color, size: 32),
                      if (widget.showLightning)
                        Positioned(
                          top: -2,
                          right: -4,
                          child: Opacity(
                            opacity: 0.6 + (glowValue * 0.4),
                            child: Icon(
                              Icons.bolt_rounded,
                              color: Colors.amber,
                              size: 18 + (glowValue * 4),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Public room card
class _PublicRoomCard extends StatelessWidget {
  final dynamic room;
  final VoidCallback onJoin;

  const _PublicRoomCard({required this.room, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Room icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.groups, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${room.participants.length} مشتركين • ${room.goalDisplayText}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Join button
          TextButton(
            onPressed: onJoin,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.secondary,
            ),
            child: const Text('انضمام'),
          ),
        ],
      ),
    );
  }
}
