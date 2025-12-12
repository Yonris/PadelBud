import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:padel_bud/providers/auth_provider.dart';
import 'package:padel_bud/providers/location_provider.dart';
import 'package:padel_bud/providers/user_provider.dart';
import 'package:padel_bud/providers/locale_provider.dart';
import 'package:padel_bud/repositories/matches_repository.dart';
import 'package:padel_bud/repositories/user_repository.dart';
import 'package:padel_bud/repositories/court_repository.dart';
import 'package:padel_bud/repositories/club_repository.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/models/time_slot_model.dart';
export 'locale_provider.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

final userProvider = NotifierProvider<UserNotifier, UserState>(
  () => UserNotifier(),
);

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  () => LocationNotifier(),
);

final currentSearchRequestIdProvider = StateProvider<String?>((ref) => null);

final foundMatchInfoProvider = FutureProvider.family<Map<String, dynamic>?, String?>((ref, matchId) async {
  if (matchId == null || matchId.isEmpty) {
    return null;
  }

  try {
    final matchesRepo = MatchesRepository();
    final userRepo = UserRepository();
    final courtRepo = CourtRepository();
    final clubRepo = ClubRepository();

    // Watch the match document stream to trigger updates when match changes
    await ref.watch(foundMatchStreamProvider(matchId).future);

    // Get time slot from user provider
    TimeSlotModel? timeSlot;
    try {
      timeSlot = await ref.read(userProvider.notifier).getCurrentMatchTimeSlot();
    } catch (e) {
      print('DEBUG: Error getting timeSlot: $e');
    }

    final userIds = await matchesRepo.getMatchUserIds(matchId: matchId);

    List<UserModel> users = [];
    for (final uid in userIds) {
      final user = await userRepo.getUser(uid);
      if (user != null) {
        users.add(user);
      }
    }

    // Get club information
    dynamic club;
    if (timeSlot != null) {
      final court = await courtRepo.getCourtById(timeSlot.courtId);
      if (court != null) {
        club = await clubRepo.getClubById(court.clubId);
      }
    }

    // Get accepted user IDs from match document
    final matchDetails = await matchesRepo.getMatchDetails(matchId: matchId);
    final acceptedUserIds = List<String>.from(matchDetails?['acceptedUserIds'] ?? []);

    return {'timeSlot': timeSlot, 'users': users, 'club': club, 'acceptedUserIds': acceptedUserIds};
  } catch (e) {
    rethrow;
  }
});

final foundMatchStreamProvider = StreamProvider.family<Map<String, dynamic>?, String?>((ref, matchId) {
  if (matchId == null || matchId.isEmpty) {
    return Stream.value(null);
  }
  final matchesRepo = MatchesRepository();
  return matchesRepo.matchStream(matchId: matchId);
});


