import 'package:flutter/material.dart';

/// Recovery Journey Stages
enum RecoveryStage {
  withdrawal,
  endurance,
  stability,
  strength,
  freedom,
}

/// Stage information for visual journey map
class RecoveryStageInfo {
  final RecoveryStage stage;
  final String titleArabic;
  final String icon;
  final Color color;
  final int daysRequired;
  final String description;

  const RecoveryStageInfo({
    required this.stage,
    required this.titleArabic,
    required this.icon,
    required this.color,
    required this.daysRequired,
    required this.description,
  });

  /// Check if stage is unlocked based on clean days
  bool isUnlocked(int cleanDays) {
    return cleanDays >= daysRequired;
  }

  /// Get progress percentage in this stage (0-100)
  double getProgressInStage(int cleanDays) {
    if (!isUnlocked(cleanDays)) return 0.0;

    final nextStage = RecoveryStages.getNextStage(stage);
    if (nextStage == null) return 100.0;

    final nextStageInfo = RecoveryStages.getStageInfo(nextStage);
    final daysInStage = cleanDays - daysRequired;
    final stageDuration = nextStageInfo.daysRequired - daysRequired;

    return ((daysInStage / stageDuration) * 100).clamp(0.0, 100.0);
  }
}

/// Static recovery stage definitions
class RecoveryStages {
  static const List<RecoveryStageInfo> allStages = [
    RecoveryStageInfo(
      stage: RecoveryStage.withdrawal,
      titleArabic: 'الانسحاب',
      icon: '🌱',
      color: Color(0xFFFF6B6B),
      daysRequired: 0,
      description: 'مرحلة البداية - التخلص من السموم والتكيف',
    ),
    RecoveryStageInfo(
      stage: RecoveryStage.endurance,
      titleArabic: 'الصمود',
      icon: '💪',
      color: Color(0xFFFFB84D),
      daysRequired: 7,
      description: 'بناء القوة والمقاومة',
    ),
    RecoveryStageInfo(
      stage: RecoveryStage.stability,
      titleArabic: 'الاستقرار',
      icon: '🛡️',
      color: Color(0xFF4ECDC4),
      daysRequired: 30,
      description: 'ترسيخ العادات الجديدة والاستقرار النفسي',
    ),
    RecoveryStageInfo(
      stage: RecoveryStage.strength,
      titleArabic: 'القوة',
      icon: '⚡',
      color: Color(0xFF95E1D3),
      daysRequired: 90,
      description: 'القوة الكاملة والسيطرة على النفس',
    ),
    RecoveryStageInfo(
      stage: RecoveryStage.freedom,
      titleArabic: 'الحرية',
      icon: '🦅',
      color: Color(0xFFFFD700),
      daysRequired: 180,
      description: 'الحرية التامة والتحرر الكامل',
    ),
  ];

  /// Get stage info by stage enum
  static RecoveryStageInfo getStageInfo(RecoveryStage stage) {
    return allStages.firstWhere((s) => s.stage == stage);
  }

  /// Get current stage based on clean days
  static RecoveryStageInfo getCurrentStage(int cleanDays) {
    // Start from the end and work backwards
    for (int i = allStages.length - 1; i >= 0; i--) {
      if (cleanDays >= allStages[i].daysRequired) {
        return allStages[i];
      }
    }
    return allStages[0]; // Default to withdrawal
  }

  /// Get next stage (null if at final stage)
  static RecoveryStage? getNextStage(RecoveryStage currentStage) {
    final currentIndex = allStages.indexWhere((s) => s.stage == currentStage);
    if (currentIndex == -1 || currentIndex >= allStages.length - 1) {
      return null;
    }
    return allStages[currentIndex + 1].stage;
  }

  /// Get all unlocked stages
  static List<RecoveryStageInfo> getUnlockedStages(int cleanDays) {
    return allStages.where((s) => s.isUnlocked(cleanDays)).toList();
  }

  /// Get all locked stages
  static List<RecoveryStageInfo> getLockedStages(int cleanDays) {
    return allStages.where((s) => !s.isUnlocked(cleanDays)).toList();
  }

  /// Get days needed for next stage
  static int? getDaysToNextStage(int cleanDays) {
    final currentStage = getCurrentStage(cleanDays);
    final nextStage = getNextStage(currentStage.stage);
    if (nextStage == null) return null;

    final nextStageInfo = getStageInfo(nextStage);
    return nextStageInfo.daysRequired - cleanDays;
  }

  /// Get progress percentage through all stages (0-100)
  static double getOverallProgress(int cleanDays) {
    final maxDays = allStages.last.daysRequired;
    return ((cleanDays / maxDays) * 100).clamp(0.0, 100.0);
  }
}
