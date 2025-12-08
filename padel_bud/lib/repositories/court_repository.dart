import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/court_model.dart';

class CourtRepository {
  final _db = FirebaseFirestore.instance.collection('courts');

  Future<List<CourtModel>> getCourts() async {
    final snap = await _db.get();
    return snap.docs
        .map((d) => CourtModel.fromDocument(d))
        .toList();
  }

  Future<List<CourtModel>> getCourtsByManager(String managerId) async {
    final snap = await _db.where('managerId', isEqualTo: managerId).get();
    return snap.docs
        .map((d) => CourtModel.fromDocument(d))
        .toList();
  }

  Future<String> addCourt(CourtModel court) async {
    final docRef = await _db.add(court.toJson());
    return docRef.id;
  }

  Future<CourtModel?> getCourtById(String courtId) async {
    final doc = await _db.doc(courtId).get();
    if (!doc.exists) return null;
    return CourtModel.fromDocument(doc);
  }
}
