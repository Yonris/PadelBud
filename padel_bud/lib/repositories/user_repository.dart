import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(UserModel user) async {
    await _db.doc(user.id).set(user.toJson());
  }

  Stream<UserModel?> userStream(String uid) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return UserModel.fromDocument(snapshot);
        });
  }

  Future<void> updateUserData({
    required String currentUserId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    int? buddiesState,
    GeoPoint? currentLocation,
    String? matchId,
    UserRole? role,
    bool? roleSelected,
    double? level,
  }) async {
    final userId = currentUserId;
    final data = <String, dynamic>{};
    if (firstName != null) {
      data['firstName'] = firstName;
    }
    if (lastName != null) {
      data['lastName'] = lastName;
    }
    if (email != null) {
      data['email'] = email;
    }
    if (phoneNumber != null) {
      data['phoneNumber'] = phoneNumber;
    }
    if (profilePictureUrl != null) {
      data['profilePictureUrl'] = profilePictureUrl;
    }
    if (buddiesState != null) {
      data['buddiesState'] = buddiesState;
    }
    if (currentLocation != null) {
      data['currentLocation'] = currentLocation;
    }
    if (matchId != null) {
      data['matchId'] = matchId;
    }
    if (role != null) {
      data['role'] = role.value;
    }
    if (roleSelected != null) {
      data['roleSelected'] = roleSelected;
    }
    if (level != null) {
      data['level'] = level;
    }

    await _db.doc(userId).update(data);
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _db.doc(id).get();
    if (!doc.exists) return null;
    return UserModel.fromDocument(doc);
  }
}
