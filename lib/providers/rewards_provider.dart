import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reward.dart';
import '../data/rewards_data.dart';
import './gamification_provider.dart';

/// Rewards Provider
/// Manages reward shop and purchases
class RewardsProvider extends ChangeNotifier {
  List<Reward> _rewards = [];
  String? _activeThemeId;
  GamificationProvider? _gamificationProvider;

  List<Reward> get rewards => _rewards;
  String? get activeThemeId => _activeThemeId;
  
  // Default theme constant
  static const String defaultThemeId = 'default';

  /// Get unlocked rewards
  List<Reward> get unlockedRewards {
    return _rewards.where((r) => r.isUnlocked).toList();
  }

  /// Get locked rewards
  List<Reward> get lockedRewards {
    return _rewards.where((r) => !r.isUnlocked).toList();
  }

  /// Get rewards by type
  List<Reward> getByType(RewardType type) {
    return _rewards.where((r) => r.type == type).toList();
  }

  /// Inject gamification provider
  void setGamificationProvider(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  RewardsProvider() {
    _loadRewards();
  }

  /// Load rewards from storage
  Future<void> _loadRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rewardsJson = prefs.getString('rewards');
      _activeThemeId = prefs.getString('active_theme_id');

      if (rewardsJson != null) {
        final List<dynamic> jsonList = jsonDecode(rewardsJson);
        _rewards = jsonList
            .map((json) => Reward.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Initialize from catalog
        _rewards = List.from(RewardsData.allRewards);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading rewards: $e');
      _rewards = List.from(RewardsData.allRewards);
    }
  }

  /// Save rewards to storage
  Future<void> _saveRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _rewards.map((r) => r.toJson()).toList();
      await prefs.setString('rewards', jsonEncode(jsonList));

      if (_activeThemeId != null) {
        await prefs.setString('active_theme_id', _activeThemeId!);
      }
    } catch (e) {
      debugPrint('Error saving rewards: $e');
    }
  }

  /// Purchase a reward
  Future<Map<String, dynamic>> purchaseReward(String rewardId) async {
    final index = _rewards.indexWhere((r) => r.id == rewardId);
    if (index == -1) {
      return {'success': false, 'error': 'Reward not found'};
    }

    final reward = _rewards[index];

    // Already unlocked
    if (reward.isUnlocked) {
      return {'success': false, 'error': 'Already unlocked'};
    }

    // Check if user has enough points
    final userPoints = _gamificationProvider?.recoveryPoints ?? 0;
    if (userPoints < reward.cost) {
      return {
        'success': false,
        'error': 'Not enough points',
        'needed': reward.cost - userPoints,
      };
    }

    // Spend points
    final spent = await _gamificationProvider?.spendRecoveryPoints(reward.cost) ?? false;
    if (!spent) {
      return {'success': false, 'error': 'Failed to spend points'};
    }

    // Unlock reward
    _rewards[index] = reward.copyWith(
      isUnlocked: true,
      unlockedDate: DateTime.now(),
    );

    // If theme, set as active
    if (reward.type == RewardType.theme && reward.themeId != null) {
      _activeThemeId = reward.themeId;
    }

    await _saveRewards();
    notifyListeners();

    return {
      'success': true,
      'reward': reward,
    };
  }

  /// Set active theme
  Future<void> setActiveTheme(String themeId) async {
    // Check if theme is unlocked
    final theme = _rewards.firstWhere(
      (r) => r.type == RewardType.theme && r.themeId == themeId,
      orElse: () => _rewards.first,
    );

    if (!theme.isUnlocked) {
      return;
    }

    _activeThemeId = themeId;
    await _saveRewards();
    notifyListeners();
  }

  /// Get affordable rewards count
  int getAffordableCount() {
    final userPoints = _gamificationProvider?.recoveryPoints ?? 0;
    return _rewards
        .where((r) => !r.isUnlocked && r.cost <= userPoints)
        .length;
  }

  /// Check if a feature is unlocked
  bool isFeatureUnlocked(String featureId) {
    final feature = _rewards.firstWhere(
      (r) => r.id == featureId && r.type == RewardType.feature,
      orElse: () => const Reward(
        id: '',
        title: '',
        description: '',
        type: RewardType.feature,
        cost: 0,
        icon: '',
      ),
    );
    return feature.id.isNotEmpty && feature.isUnlocked;
  }

  /// Get all owned themes
  List<Reward> getOwnedThemes() {
    return _rewards
        .where((r) => r.type == RewardType.theme && r.isUnlocked)
        .toList();
  }

  /// Reset to default theme
  Future<void> resetToDefaultTheme() async {
    _activeThemeId = null;
    await _saveRewards();
    notifyListeners();
  }
}
