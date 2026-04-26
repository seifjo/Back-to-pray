// Reward Model
// Shop items that users can unlock with recovery points

enum RewardType {
  theme,
  badge,
  feature,
}

extension RewardTypeExtension on RewardType {
  String get arabicName {
    switch (this) {
      case RewardType.theme:
        return 'ثيم';
      case RewardType.badge:
        return 'شارة';
      case RewardType.feature:
        return 'ميزة';
    }
  }
}

class Reward {
  final String id;
  final String title;
  final String description;
  final RewardType type;
  final int cost;
  final String? themeId; // For theme rewards
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.cost,
    this.themeId,
    this.icon = '🎁',
    this.isUnlocked = false,
    this.unlockedDate,
  });

  Reward copyWith({
    bool? isUnlocked,
    DateTime? unlockedDate,
  }) {
    return Reward(
      id: id,
      title: title,
      description: description,
      type: type,
      cost: cost,
      themeId: themeId,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'cost': cost,
      'themeId': themeId,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RewardType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RewardType.theme,
      ),
      cost: json['cost'] as int,
      themeId: json['themeId'] as String?,
      icon: json['icon'] as String? ?? '🎁',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'] as String)
          : null,
    );
  }
}
