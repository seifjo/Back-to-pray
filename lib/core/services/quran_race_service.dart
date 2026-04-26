import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../models/quran_race_room.dart';

/// Quran Race Service
/// Handles all Firebase Realtime Database operations for race rooms
class QuranRaceService {
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref('rooms');

  /// Create a new room
  Future<void> createRoom(QuranRaceRoom room) async {
    print('DATABASE: [1/3] Initiating createRoom for ID: ${room.id}');
    try {
      await _roomsRef.child(room.id).set(room.toJson()).timeout(
            const Duration(seconds: 15),
          );
      print('DATABASE: [2/3] Room written successfully');
    } catch (e) {
      print('DATABASE: [X] Error in createRoom: $e');
      rethrow;
    }
  }

  /// Add a participant to a room
  Future<void> joinRoom(String roomId, RoomParticipant participant) async {
    await _roomsRef
        .child(roomId)
        .child('participants')
        .child(participant.odId)
        .set(participant.toJson())
        .timeout(const Duration(seconds: 15));
  }

  /// Remove a participant from a room
  Future<void> leaveRoom(String roomId, String odId) async {
    await _roomsRef
        .child(roomId)
        .child('participants')
        .child(odId)
        .remove();
  }

  /// Update a participant's reading progress
  Future<void> updateProgress(
    String roomId,
    String odId, {
    required int currentJuz,
    required int currentSurahNumber,
    required String currentSurahName,
    required int currentAyah,
    required double completionPercentage,
    required int totalPagesRead,
  }) async {
    await _roomsRef
        .child(roomId)
        .child('participants')
        .child(odId)
        .update({
      'currentJuz': currentJuz,
      'currentSurahNumber': currentSurahNumber,
      'currentSurahName': currentSurahName,
      'currentAyah': currentAyah,
      'completionPercentage': completionPercentage,
      'totalPagesRead': totalPagesRead,
      'lastActivity': DateTime.now().toIso8601String(),
      'isCurrentlyReading': true,
    });
  }

  /// Set reading status (green indicator)
  Future<void> setReadingStatus(String roomId, String odId, bool isReading) async {
    await _roomsRef
        .child(roomId)
        .child('participants')
        .child(odId)
        .update({
      'isCurrentlyReading': isReading,
      'lastActivity': DateTime.now().toIso8601String(),
    });
  }

  /// Award a badge to a participant
  Future<void> awardBadge(String roomId, String odId, String badgeId) async {
    final badgesRef = _roomsRef
        .child(roomId)
        .child('participants')
        .child(odId)
        .child('badges');
    
    final snapshot = await badgesRef.get();
    List<String> badges = [];
    if (snapshot.exists) {
      badges = List<String>.from(snapshot.value as List);
    }
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await badgesRef.set(badges).timeout(const Duration(seconds: 10));
    }
  }

  /// Listen to a room in real-time
  Stream<QuranRaceRoom?> listenToRoom(String roomId) {
    return _roomsRef.child(roomId).onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return QuranRaceRoom.fromJson(data);
    });
  }

  /// Get a room once
  Future<QuranRaceRoom?> getRoom(String roomId) async {
    final snapshot = await _roomsRef.child(roomId).get();
    if (!snapshot.exists) return null;
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return QuranRaceRoom.fromJson(data);
  }

  /// Get all public rooms
  Future<List<QuranRaceRoom>> getPublicRooms() async {
    final snapshot = await _roomsRef
        .orderByChild('isPublic')
        .equalTo(true)
        .limitToFirst(50)
        .get();

    if (!snapshot.exists) return [];

    final List<QuranRaceRoom> rooms = [];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data.forEach((key, value) {
      rooms.add(QuranRaceRoom.fromJson(Map<String, dynamic>.from(value as Map)));
    });
    return rooms;
  }

  /// Delete a room (admin only)
  Future<void> deleteRoom(String roomId) async {
    await _roomsRef.child(roomId).remove();
  }

  /// Check if a room exists
  Future<bool> roomExists(String roomId) async {
    final snapshot = await _roomsRef.child(roomId).child('id').get();
    return snapshot.exists;
  }
}
