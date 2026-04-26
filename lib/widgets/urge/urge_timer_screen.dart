import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/urge_resistance_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../data/dhikr_content.dart';

/// Full-Screen Urge Timer
/// 90-second breathing timer with dhikr and animations
class UrgeTimerScreen extends StatefulWidget {
  const UrgeTimerScreen({super.key});

  @override
  State<UrgeTimerScreen> createState() => _UrgeTimerScreenState();
}

class _UrgeTimerScreenState extends State<UrgeTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _hasStarted = false;
  int _currentDhikrIndex = 0;
  Timer? _dhikrRotationTimer;

  @override
  void initState() {
    super.initState();

    // Breathing animation (expand/contract)
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Fade animation for dhikr text rotation (3 seconds)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start fade in
    _fadeController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeController.dispose();
    _dhikrRotationTimer?.cancel();
    super.dispose();
  }

  void _startDhikrRotation() {
    // Rotate dhikr every 3 seconds
    _dhikrRotationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      
      setState(() {
        // Fade out
        _fadeController.reverse().then((_) {
          if (!mounted) return;
          
          // Change dhikr
          _currentDhikrIndex++;
          
          // Fade in
          _fadeController.forward();
        });
      });
    });
  }

  void _startTimer(BuildContext context) {
    final urgeProvider = context.read<UrgeResistanceProvider>();

    // Setup callback for success
    urgeProvider.onUrgeResistSuccess = (int xp) {
      // Award XP through gamification provider
      final gamProvider = context.read<GamificationProvider>();
      gamProvider.addXP(xp, reason: 'Urge resisted');

      // Show success screen
      _showSuccessScreen(context, xp);
    };

    urgeProvider.startUrgeTimer();
    _startDhikrRotation(); // Start dhikr rotation
    setState(() {
      _hasStarted = true;
    });
  }

  void _showSuccessScreen(BuildContext context, int xp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '🎉 انتصرت!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'أحسنت! قاومت الرغبة بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D7377).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$xp XP',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14FFEC),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'أنت أقوى من الأمس',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Close timer screen
            },
            child: const Text('رائع!', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Consumer<UrgeResistanceProvider>(
        builder: (context, urgeProvider, child) {
          if (!_hasStarted && !urgeProvider.isTimerActive) {
            return _buildStartScreen(context);
          }

          if (!urgeProvider.isTimerActive) {
            // Timer finished or stopped
            return const SizedBox.shrink();
          }

          return _buildTimerScreen(context, urgeProvider);
        },
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              '💪',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 32),
            const Text(
              'أنت أقوى من رغباتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '90 ثانية فقط\nتنفس، اذكر الله، وانتصر',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _startTimer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7377),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'ابدأ الآن',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'رجوع',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerScreen(
      BuildContext context, UrgeResistanceProvider provider) {
    final secondsRemaining = provider.secondsRemaining;
    
    // Get all dhikr content
    final allDhikrContent = [
      ...DhikrContent.getUrgeResistanceDhikr(),
      ...DhikrContent.quranVerses,
      ...DhikrContent.protectiveDuas,
    ];
    
    final currentDhikr =
        allDhikrContent[_currentDhikrIndex % allDhikrContent.length];

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A2E),
                const Color(0xFF0D7377).withValues(alpha: 0.3),
                const Color(0xFF1A1A2E),
              ],
            ),
          ),
        ),

        // Main content - CENTERED
        Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Breathing circle animation
                  ScaleTransition(
                    scale: _breathingAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF14FFEC).withValues(alpha: 0.6),
                            const Color(0xFF0D7377).withValues(alpha: 0.2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF14FFEC).withValues(alpha: 0.4),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          secondsRemaining.toString(),
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Dhikr text with fade animation - CENTERED
                  SizedBox(
                    height: 200, // Fixed height to prevent layout shift
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          currentDhikr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Color(0xFF14FFEC),
                            fontWeight: FontWeight.w600,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Breathing guidance - CENTERED
                  const Text(
                    'تنفس ببطء وعمق...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Exit button at bottom
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('هل أنت متأكد؟'),
                    content: const Text(
                      'الاستمرار سيساعدك على التعافي',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('استمر'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.cancelTimer();
                          _dhikrRotationTimer?.cancel();
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('خروج'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'خروج',
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
