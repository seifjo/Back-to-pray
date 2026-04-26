/// Urge Resistance Event
/// Tracks when user resists an urge using the timer
class UrgeEvent {
  final DateTime timestamp;
  final bool success;
  final int durationSeconds;
  final int xpEarned;
  final String? notes;

  const UrgeEvent({
    required this.timestamp,
    required this.success,
    required this.durationSeconds,
    this.xpEarned = 0,
    this.notes,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'durationSeconds': durationSeconds,
      'xpEarned': xpEarned,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory UrgeEvent.fromJson(Map<String, dynamic> json) {
    return UrgeEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
      durationSeconds: json['durationSeconds'] as int,
      xpEarned: json['xpEarned'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
  }

  /// Copy with modifications
  UrgeEvent copyWith({
    DateTime? timestamp,
    bool? success,
    int? durationSeconds,
    int? xpEarned,
    String? notes,
  }) {
    return UrgeEvent(
      timestamp: timestamp ?? this.timestamp,
      success: success ?? this.success,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      xpEarned: xpEarned ?? this.xpEarned,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UrgeEvent &&
        other.timestamp == timestamp &&
        other.success == success &&
        other.durationSeconds == durationSeconds &&
        other.xpEarned == xpEarned &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      timestamp,
      success,
      durationSeconds,
      xpEarned,
      notes,
    );
  }
}

/// Statistics for urge resistance
class UrgeResistanceStats {
  final int totalUrges;
  final int successfulResistances;
  final int failedResistances;
  final int consecutiveSuccesses;
  final int totalXPEarned;
  final List<UrgeEvent> recentEvents;

  const UrgeResistanceStats({
    this.totalUrges = 0,
    this.successfulResistances = 0,
    this.failedResistances = 0,
    this.consecutiveSuccesses = 0,
    this.totalXPEarned = 0,
    this.recentEvents = const [],
  });

  /// Success rate percentage (0-100)
  double get successRate {
    if (totalUrges == 0) return 0.0;
    return (successfulResistances / totalUrges * 100);
  }

  /// Get events from last N days
  List<UrgeEvent> getEventsFromLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return recentEvents.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  /// Copy with modifications
  UrgeResistanceStats copyWith({
    int? totalUrges,
    int? successfulResistances,
    int? failedResistances,
    int? consecutiveSuccesses,
    int? totalXPEarned,
    List<UrgeEvent>? recentEvents,
  }) {
    return UrgeResistanceStats(
      totalUrges: totalUrges ?? this.totalUrges,
      successfulResistances: successfulResistances ?? this.successfulResistances,
      failedResistances: failedResistances ?? this.failedResistances,
      consecutiveSuccesses: consecutiveSuccesses ?? this.consecutiveSuccesses,
      totalXPEarned: totalXPEarned ?? this.totalXPEarned,
      recentEvents: recentEvents ?? this.recentEvents,
    );
  }
}
