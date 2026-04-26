import 'package:flutter/material.dart';

/// Completion Celebration Dialog
/// Shown when a participant finishes the entire Quran.
class CompletionCelebrationDialog extends StatelessWidget {
  final String completedByName;

  const CompletionCelebrationDialog({
    super.key,
    required this.completedByName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.scaffoldBackgroundColor,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration emoji
            const Text(
              '🎉',
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'تهانينا!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 12),

            // Message
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'لقد أتم '),
                  TextSpan(
                    text: completedByName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const TextSpan(text: ' ختم القرآن الكريم!'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quranic verse
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '﴿ إِنَّ الَّذِينَ يَتْلُونَ كِتَابَ اللَّهِ وَأَقَامُوا الصَّلَاةَ\nوَأَنفَقُوا مِمَّا رَزَقْنَاهُمْ سِرًّا وَعَلَانِيَةً\nيَرْجُونَ تِجَارَةً لَّن تَبُورَ ﴾',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  color: Color(0xFFFFD700),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سورة فاطر - آية ٢٩',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),

            // Badge earned
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'حصل على وسام "أتم الختمة"',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'بارك الله فيه',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
