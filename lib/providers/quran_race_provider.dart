import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/quran_race_room.dart';
import '../core/services/quran_race_service.dart';
import '../data/quran_metadata.dart';

/// Quran Race Provider
/// Manages state for the Quran Race Rooms feature
class QuranRaceProvider with ChangeNotifier {
  final QuranRaceService _service = QuranRaceService();

  // Persistence keys
  static const _keyRoomId = 'race_room_id';
  static const _keyDisplayName = 'race_display_name';

  // State
  QuranRaceRoom? _currentRoom;
  List<QuranRaceRoom> _publicRooms = [];
  bool _isLoading = false;
  String? _error;
  String _userDisplayName = 'قارئ';
  StreamSubscription? _roomSubscription;

  // Getters
  QuranRaceRoom? get currentRoom => _currentRoom;
  List<QuranRaceRoom> get publicRooms => _publicRooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get userDisplayName => _userDisplayName;
  bool get isInRoom => _currentRoom != null;
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  QuranRaceProvider() {
    _restoreSavedRoom();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  // ─── Persistence ───────────────────────────────────────────────

  /// Save room membership to disk
  Future<void> _saveRoomLocally(String roomId, String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRoomId, roomId);
    await prefs.setString(_keyDisplayName, displayName);
  }

  /// Clear saved room from disk
  Future<void> _clearSavedRoom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRoomId);
    await prefs.remove(_keyDisplayName);
  }

  /// Auto-rejoin the room on app restart
  Future<void> _restoreSavedRoom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRoomId = prefs.getString(_keyRoomId);
      final savedName = prefs.getString(_keyDisplayName);

      if (savedRoomId == null || savedRoomId.isEmpty) return;
      if (savedName != null && savedName.isNotEmpty) {
        _userDisplayName = savedName;
      }

      // Check if room still exists in Firebase
      final exists = await _service.roomExists(savedRoomId);
      if (!exists) {
        await _clearSavedRoom();
        return;
      }

      // Re-subscribe
      _listenToRoom(savedRoomId);
    } catch (e) {
      debugPrint('Failed to restore saved room: $e');
    }
  }

  // ─── Room Management ───────────────────────────────────────────

  /// Set user display name
  void setDisplayName(String name) {
    _userDisplayName = name;
    notifyListeners();
  }

  /// Create a new race room
  Future<bool> createRoom({
    required String name,
    required bool isPublic,
    required String goal,
    int? targetJuz,
    required String displayName,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      _error = 'يجب تسجيل الدخول أولاً';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (Firebase.apps.isEmpty) {
        _error = 'خدمة الغرف غير مفعلة (خطأ في التهيئة)';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Generate a short, memorable room ID (6 characters)
      final roomId = const Uuid().v4().substring(0, 6).toUpperCase();

      _userDisplayName = displayName;

      final room = QuranRaceRoom(
        id: roomId,
        name: name,
        creatorId: uid,
        creatorName: displayName,
        isPublic: isPublic,
        goal: goal,
        targetJuz: targetJuz,
        createdAt: DateTime.now(),
      );

      await _service.createRoom(room);

      // Auto-join as the creator
      final participant = RoomParticipant(
        odId: uid,
        displayName: displayName,
        joinedAt: DateTime.now(),
      );
      await _service.joinRoom(roomId, participant);

      // Persist room membership locally
      await _saveRoomLocally(roomId, displayName);

      // Listen to the room
      _listenToRoom(roomId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل إنشاء الغرفة: يرجى التأكد من اتصال الإنترنت أو إعدادات الهاتف';
      debugPrint('Create room failed: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Join an existing room by ID
  Future<bool> joinRoom({
    required String roomId,
    required String displayName,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      _error = 'يجب تسجيل الدخول أولاً';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (Firebase.apps.isEmpty) {
        _error = 'خدمة الغرف غير مفعلة (خطأ في التهيئة)';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final roomIdUpper = roomId.toUpperCase().trim();

      // Check if room exists
      final exists = await _service.roomExists(roomIdUpper);
      if (!exists) {
        _error = 'الغرفة غير موجودة';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _userDisplayName = displayName;

      final participant = RoomParticipant(
        odId: uid,
        displayName: displayName,
        joinedAt: DateTime.now(),
      );
      await _service.joinRoom(roomIdUpper, participant);

      // Persist room membership locally
      await _saveRoomLocally(roomIdUpper, displayName);

      // Listen to the room
      _listenToRoom(roomIdUpper);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل الانضمام: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Leave the current room
  Future<void> leaveRoom() async {
    final uid = currentUserId;
    if (uid == null || _currentRoom == null) return;

    try {
      await _service.leaveRoom(_currentRoom!.id, uid);
      _roomSubscription?.cancel();
      _currentRoom = null;
      await _clearSavedRoom();
      notifyListeners();
    } catch (e) {
      _error = 'فشل مغادرة الغرفة: $e';
      notifyListeners();
    }
  }

  // ─── Progress ──────────────────────────────────────────────────

  /// Update current user's Quran reading progress
  Future<void> updateMyProgress({
    required int surahNumber,
    required int ayahNumber,
    String? surahName,
  }) async {
    final uid = currentUserId;
    if (uid == null || _currentRoom == null) return;

    try {
      final juz = QuranMetadata.getJuzForPosition(surahNumber, ayahNumber);
      final percentage = QuranMetadata.calculateCompletionPercentage(surahNumber, ayahNumber);
      final pages = QuranMetadata.getTotalPagesRead(surahNumber, ayahNumber);
      final name = surahName ?? QuranMetadata.getSurahName(surahNumber);

      await _service.updateProgress(
        _currentRoom!.id,
        uid,
        currentJuz: juz,
        currentSurahNumber: surahNumber,
        currentSurahName: name,
        currentAyah: ayahNumber,
        completionPercentage: percentage,
        totalPagesRead: pages,
      );

      // Check for completion
      if (percentage >= 100.0) {
        await _service.awardBadge(_currentRoom!.id, uid, 'khatm_complete');
      }
    } catch (e) {
      // Silently fail — don't break the Quran reading experience
      debugPrint('Failed to update race progress: $e');
    }
  }

  /// Toggle reading status
  Future<void> setReadingStatus(bool isReading) async {
    final uid = currentUserId;
    if (uid == null || _currentRoom == null) return;

    try {
      await _service.setReadingStatus(_currentRoom!.id, uid, isReading);
    } catch (e) {
      debugPrint('Failed to set reading status: $e');
    }
  }

  // ─── Public Rooms ──────────────────────────────────────────────

  /// Load public rooms
  Future<void> loadPublicRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _publicRooms = await _service.getPublicRooms();
      _error = null;
    } catch (e) {
      _error = 'فشل تحميل الغرف: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Admin Actions ─────────────────────────────────────────────

  /// Delete a room (admin only)
  Future<void> deleteRoom() async {
    final uid = currentUserId;
    if (uid == null || _currentRoom == null) return;
    if (_currentRoom!.creatorId != uid) {
      _error = 'فقط منشئ الغرفة يمكنه حذفها';
      notifyListeners();
      return;
    }

    try {
      await _service.deleteRoom(_currentRoom!.id);
      _roomSubscription?.cancel();
      _currentRoom = null;
      await _clearSavedRoom();
      notifyListeners();
    } catch (e) {
      _error = 'فشل حذف الغرفة: $e';
      notifyListeners();
    }
  }

  /// Kick a participant from the room (admin only)
  Future<void> kickParticipant(String participantId) async {
    final uid = currentUserId;
    if (uid == null || _currentRoom == null) return;
    if (_currentRoom!.creatorId != uid) return;

    try {
      await _service.leaveRoom(_currentRoom!.id, participantId);
      // Room listener will update participants list automatically
    } catch (e) {
      debugPrint('Failed to kick participant: $e');
    }
  }

  // ─── Internal ──────────────────────────────────────────────────

  /// Listen to room changes in real-time
  void _listenToRoom(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription = _service.listenToRoom(roomId).listen(
      (room) {
        if (room == null) {
          // Room was deleted
          _currentRoom = null;
          _clearSavedRoom();
          notifyListeners();
          return;
        }
        _currentRoom = room;
        notifyListeners();
      },
      onError: (e) {
        _error = 'فقد الاتصال بالغرفة';
        notifyListeners();
      },
    );
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if current user is the room admin
  bool get isRoomAdmin =>
      _currentRoom != null && _currentRoom!.creatorId == currentUserId;

  /// Check if a specific participant is the room admin
  bool isParticipantAdmin(String odId) =>
      _currentRoom != null && _currentRoom!.creatorId == odId;

  /// Get my participant data
  RoomParticipant? get myParticipant {
    final uid = currentUserId;
    if (uid == null || _currentRoom == null) return null;
    return _currentRoom!.participants[uid];
  }
}
