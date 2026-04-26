import 'package:flutter/material.dart';
import '../../models/reward.dart';
import '../../core/theme/app_theme.dart';

/// Reward Card Widget
/// Displays individual reward in shop
class RewardCard extends StatelessWidget {
  final Reward reward;
  final int userPoints;
  final VoidCallback onPurchase;

  const RewardCard({
    super.key,
    required this.reward,
    required this.userPoints,
    required this.onPurchase,
  });

  bool get canAfford => userPoints >= reward.cost;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: reward.isUnlocked ? 0 : 3,
      color: reward.isUnlocked
          ? Colors.white.withValues(alpha: 0.05)
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: reward.isUnlocked
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryGreen.withValues(alpha: 0.3),
                              AppTheme.secondaryGreen.withValues(alpha: 0.1),
                            ],
                          )
                        : null,
                    color: !reward.isUnlocked ? Colors.white10 : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      reward.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Purchase button
                if (!reward.isUnlocked)
                  ElevatedButton(
                    onPressed: canAfford ? onPurchase : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford
                          ? AppTheme.primaryGreen
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart, size: 16),
                        const SizedBox(width: 8),
                        Text('${reward.cost} نقطة'),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'مفتوح',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Locked overlay
          if (!reward.isUnlocked && !canAfford)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.lock, size: 40, color: Colors.white54),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
