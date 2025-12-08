import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/time_slot_model.dart';
import '../models/court_model.dart';

class TimeSlotRepository {
  final _db = FirebaseFirestore.instance.collection('time_slots');
  final _courtsDb = FirebaseFirestore.instance.collection('courts');

  Future<List<TimeSlotModel>> getTimeSlots({required String courtId}) async {
    final snap = await _db.where('courtId', isEqualTo: courtId).get();
    return snap.docs.map((d) => TimeSlotModel.fromDocument(d)).toList();
  }

  Future<List<TimeSlotModel>> getTimeSlotsForClub({required String clubId}) async {
    // Get all courts in the club
    final courtsSnap = await _courtsDb.where('clubId', isEqualTo: clubId).get();
    final courtIds = courtsSnap.docs.map((d) => d.id).toList();
    
    if (courtIds.isEmpty) return [];

    // Get all time slots for all courts in the club
    final snap = await _db.where('courtId', whereIn: courtIds).get();
    final allSlots = snap.docs.map((d) => TimeSlotModel.fromDocument(d)).toList();
    
    // Group by time (start and end) and keep only one slot per time if at least one is available
    final Map<String, TimeSlotModel> aggregatedSlots = {};
    for (final slot in allSlots) {
      final key = '${slot.start.toIso8601String()}_${slot.end.toIso8601String()}';
      if (!aggregatedSlots.containsKey(key)) {
        aggregatedSlots[key] = slot;
      } else if (slot.available && !aggregatedSlots[key]!.available) {
        // Replace with available slot
        aggregatedSlots[key] = slot;
      }
    }
    
    return aggregatedSlots.values.toList();
  }

  Future<void> addTimeSlot(Map<String, dynamic> slot) async {
    await _db.add(slot);
  }

  Future<TimeSlotModel?> getTimeSlotById(String id) async {
    final doc = await _db.doc(id).get();
    if (!doc.exists) return null;
    return TimeSlotModel.fromDocument(doc);
  }

  Future<void> updateTimeSlot(String timeSlotId, Map<String, dynamic> updates) async {
    await _db.doc(timeSlotId).update(updates);
  }

  Future<void> markTimeSlotAsBooked(String timeSlotId) async {
    await _db.doc(timeSlotId).update({'available': false});
  }

  Future<void> setTimeSlotAvailable(String timeSlotId) async {
    await _db.doc(timeSlotId).update({'available': true});
  }

  Future<void> updateCourtPrices(String courtId, double newPrice) async {
    final snap = await _db.where('courtId', isEqualTo: courtId).get();
    final batch = FirebaseFirestore.instance.batch();
    
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'price': newPrice});
    }
    
    await batch.commit();
  }
}
