import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/club_model.dart';

class ClubRepository {
  final _db = FirebaseFirestore.instance.collection('clubs');
  final _storage = FirebaseStorage.instance;

  Future<List<ClubModel>> getClubs() async {
    final snap = await _db.get();
    return snap.docs
        .map((d) => ClubModel.fromDocument(d))
        .toList();
  }

  Future<List<ClubModel>> getClubsByManager(String managerId) async {
    final snap = await _db.where('managerId', isEqualTo: managerId).get();
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

  Future<void> updateClubCurrency(String clubId, String newCurrency) async {
    await _db.doc(clubId).update({'currency': newCurrency});
  }

  Future<void> updateClubInfo({
    required String clubId,
    String? name,
    String? address,
    String? phone,
  }) async {
    final updates = <String, dynamic>{};
    
    if (name != null) updates['name'] = name;
    if (address != null) updates['address'] = address;
    if (phone != null) updates['phone'] = phone;
    
    if (updates.isNotEmpty) {
      await _db.doc(clubId).update(updates);
    }
  }

  Future<void> updateClubPhoto(String clubId, String photoUrl) async {
    await _db.doc(clubId).update({'imageUrl': photoUrl});
  }

  Future<String> uploadClubPhoto(String clubId, String filePath) async {
    try {
      final file = File(filePath);
      final fileName = 'clubs/$clubId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final uploadTask = await _storage.ref(fileName).putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}
