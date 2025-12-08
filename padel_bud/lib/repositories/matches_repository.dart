import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/time_slot_model.dart';

class MatchesRepository {
  final _db = FirebaseFirestore.instance.collection('matches');

  Future<String> getTimeSlotId({required String matchId}) async {
    final snap = await _db.doc(matchId).get();
    return snap.data()!['timeSlotId'];
  }

  Future<void> addTimeSlot(Map<String, dynamic> slot) async {
    await _db.add(slot);
  }

  Future<TimeSlotModel?> getTimeSlotById(String id) async {
    final doc = await _db.doc(id).get();
    if (!doc.exists) return null;
    return TimeSlotModel.fromDocument(doc);
  }

  Future<Map<String, dynamic>?> getMatchDetails({required String matchId}) async {
    final snap = await _db.doc(matchId).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Future<List<String>> getMatchUserIds({required String matchId}) async {
    final snap = await _db.doc(matchId).get();
    if (!snap.exists) return [];
    final userIds = List<String>.from(snap.data()?['userIds'] ?? []);
    return userIds;
  }

  Future<void> deleteMatch({required String matchId}) async {
    await _db.doc(matchId).delete();
  }
}
