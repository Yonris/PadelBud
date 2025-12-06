import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';

class ClubRepository {
  final _db = FirebaseFirestore.instance.collection('clubs');

  Future<List<ClubModel>> getClubs() async {
    final snap = await _db.get();
    return snap.docs
        .map((d) => ClubModel.fromDocument(d))
        .toList();
  }

  Future<ClubModel?> getClubById(String clubId) async {
    final doc = await _db.doc(clubId).get();
    if (!doc.exists) return null;
    return ClubModel.fromDocument(doc);
  }

  Future<String> addClub(ClubModel club) async {
    final docRef = await _db.add(club.toJson());
    return docRef.id;
  }

  Future<void> updateClub(String clubId, ClubModel club) async {
    await _db.doc(clubId).update(club.toJson());
  }
}
