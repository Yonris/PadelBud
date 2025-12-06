import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/models/time_slot_model.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/repositories/matches_repository.dart';
import 'package:padel_bud/repositories/time_slot_repository.dart';
import 'package:padel_bud/repositories/user_repository.dart';

class UserState {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final int buddiesState;
  final bool initialized;
  final GeoPoint? currentLocation;
  final String? matchId;
  final UserRole role;
  final bool roleSelected;
  final double? level;

  const UserState({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.buddiesState = BuddiesState.notStarted,
    this.initialized = false,
    this.currentLocation,
    this.matchId,
    this.role = UserRole.player,
    this.roleSelected = false,
    this.level = 1.0,
  });

  UserState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    int? buddiesState,
    bool? initialized,
    GeoPoint? currentLocation,
    String? matchId,
    UserRole? role,
    bool? roleSelected,
    double? level,
  }) {
    return UserState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      buddiesState: buddiesState ?? this.buddiesState,
      initialized: initialized ?? this.initialized,
      matchId: matchId ?? this.matchId,
      currentLocation: currentLocation ?? this.currentLocation,
      role: role ?? this.role,
      roleSelected: roleSelected ?? this.roleSelected,
      level: level ?? this.level,
    );
  }
}

class UserNotifier extends Notifier<UserState> {
  StreamSubscription? _userSub;

  @override
  UserState build() {
    final authUser = ref.read(authProvider).user;
    
    if (authUser == null) {
      return const UserState();
    }
    
    final uid = authUser.uid;

    // Cancel any previous subscription (safe on hot-reload / rebuild)
    _userSub?.cancel();

    // Subscribe to the Firestore user stream
    _userSub = UserRepository()
        .userStream(uid)
        .listen(
          (userDoc) {
            if (userDoc == null) return;
            state = state.copyWith(
              firstName: userDoc.firstName,
              lastName: userDoc.lastName,
              email: userDoc.email,
              phoneNumber: userDoc.phoneNumber,
              profilePictureUrl: userDoc.profilePictureUrl,
              buddiesState: userDoc.buddiesState,
              matchId: userDoc.matchId,
              role: userDoc.role,
              roleSelected: userDoc.roleSelected,
              level: userDoc.level,
              initialized: true,
            );
          },
          onError: (err) {
            // optional: handle/log errors
          },
        );

    // Ensure subscription is canceled when provider is disposed
    ref.onDispose(() {
      _userSub?.cancel();
    });

    return const UserState();
  }

  void updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    GeoPoint? currentLocation,
    String? matchId,
    int? buddiesState,
    UserRole? role,
    bool? roleSelected,
    double? level,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      currentLocation: currentLocation,
      buddiesState: buddiesState,
      matchId: matchId,
      role: role,
      roleSelected: roleSelected,
      level: level,
    );
    UserRepository().updateUserData(
      currentUserId: ref.read(authProvider).user!.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      currentLocation: currentLocation,
      profilePictureUrl: profilePictureUrl,
      matchId: matchId,
      role: role,
      roleSelected: roleSelected,
      level: level,
    );
  }

  Future<void> setUserRole(UserRole role) async {
    state = state.copyWith(role: role, roleSelected: true);
    await UserRepository().updateUserData(
      currentUserId: ref.read(authProvider).user!.uid,
      role: role,
      roleSelected: true,
    );
  }

  Future<TimeSlotModel> getCurrentMatchTimeSlot() async {
    final matchId = state.matchId!;
    final timeSlotId = await MatchesRepository().getTimeSlotId(matchId: matchId);

    TimeSlotModel matchedTimeSlot =
        await TimeSlotRepository().getTimeSlotById(timeSlotId) as TimeSlotModel;
    return matchedTimeSlot;
  }

  void setSearchingForBuddies(int isSearching) {
    state = state.copyWith(buddiesState: isSearching);
    UserRepository().updateUserData(
      currentUserId: ref.read(authProvider).user!.uid,
      buddiesState: isSearching,
    );
  }
}
