import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { player, courtManager }

class BuddiesState {
  static const int notStarted = 0;
  static const int searching = 1;
  static const int matchFound = 2;
}

extension UserRoleExtension on UserRole {
  String get value => this == UserRole.player ? 'player' : 'courtManager';
  
  static UserRole fromString(String value) {
    return value == 'courtManager' ? UserRole.courtManager : UserRole.player;
  }
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profilePictureUrl;
  final GeoPoint? currentLocation;
  final String? matchId;
  final int buddiesState;
  final UserRole role;
  final bool roleSelected;
  final double level;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    this.buddiesState = BuddiesState.notStarted,
    this.matchId,
    this.currentLocation,
    this.role = UserRole.player,
    this.roleSelected = false,
    this.level = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'profilePictureUrl': profilePictureUrl,
    'buddiesState': buddiesState,
    'matchId': matchId,
    'currentLocation': currentLocation,
    'role': role.value,
    'roleSelected': roleSelected,
    'level': level,
  };

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      profilePictureUrl: data['profilePictureUrl'],
      buddiesState: data['buddiesState'] ?? BuddiesState.notStarted,
      matchId: data['matchId'],
      currentLocation: data['currentLocation'],
      role: UserRoleExtension.fromString(data['role'] ?? 'player'),
      roleSelected: data['roleSelected'] ?? false,
      level: (data['level'] ?? 1.0).toDouble(),
    );
  }
}
