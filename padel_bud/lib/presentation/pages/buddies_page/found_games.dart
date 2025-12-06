import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/core/payment_service.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/models/club_model.dart';
import 'package:padel_bud/models/time_slot_model.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/presentation/widgets/payment_dialog.dart';
import 'package:padel_bud/presentation/widgets/club_image_widget.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/providers/user_provider.dart';
import 'package:padel_bud/repositories/matches_repository.dart';
import 'package:padel_bud/repositories/user_repository.dart';
import 'package:padel_bud/repositories/court_repository.dart';
import 'package:padel_bud/repositories/club_repository.dart';

class FoundMatchPage extends ConsumerWidget {
  const FoundMatchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            AppLocalizations.of(context).matchFound,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getMatchInfo(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${AppLocalizations.of(context).error}: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final matchInfo = snapshot.data;
          if (matchInfo == null) {
            return Center(child: Text(AppLocalizations.of(context).noMatchFound));
          }

          final slot = matchInfo['timeSlot'] as TimeSlotModel?;
          final club = matchInfo['club'] as ClubModel?;
          final users = matchInfo['users'] as List<UserModel>?;
          final currentUserId = ref.read(authProvider).user?.uid;

          if (slot == null) {
            return Center(child: Text(AppLocalizations.of(context).noMatchFound));
          }

          final timeLabel =
              "${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')} - "
              "${slot.end.hour.toString().padLeft(2, '0')}:${slot.end.minute.toString().padLeft(2, '0')}";

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Time
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF1E88E5),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    timeLabel,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Location with Club Image
                              if (club != null)
                                Column(
                                  children: [
                                    ClubImageWidget(
                                      club: club,
                                      width: 80,
                                      height: 80,
                                      borderRadius: 14,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      club.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 18),
                              Container(
                                height: 1.5,
                                color: Colors.grey.shade200,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).players,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (users != null && users.isNotEmpty)
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (int i = 0; i < 2 && i < users.length; i++) ...[
                                          _buildPlayerAvatar(
                                            user: users[i],
                                            isCurrentUser:
                                                users[i].id == currentUserId,
                                          ),
                                          if (i == 0)
                                            const SizedBox(width: 24),
                                        ],
                                      ],
                                    ),
                                    if (users.length > 2) ...[
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          for (int i = 2; i < 4 && i < users.length; i++) ...[
                                            _buildPlayerAvatar(
                                              user: users[i],
                                              isCurrentUser:
                                                  users[i].id == currentUserId,
                                            ),
                                            if (i == 2)
                                              const SizedBox(width: 24),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                )
                              else
                                Text(AppLocalizations.of(context).noPlayersFound, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Buttons at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => PaymentDialog(
                                productId:
                                    PaymentService.matchAcceptanceProductId,
                                amount: '20 ILS',
                                description: 'Accept match and join the game',
                                onPaymentSuccess: () {
                                  ref
                                      .read(userProvider.notifier)
                                      .setSearchingForBuddies(
                                        BuddiesState.notStarted,
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context).acceptMatch,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(userProvider.notifier)
                                .setSearchingForBuddies(
                                    BuddiesState.notStarted);
                          },
                          child: Text(
                            AppLocalizations.of(context).skip,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _getMatchInfo(WidgetRef ref) async {
    try {
      final userState = ref.read(userProvider);
      final matchId = userState.matchId;
      print('DEBUG: matchId = $matchId');
      if (matchId == null) {
        print('DEBUG: matchId is null');
        return null;
      }

      final matchesRepo = MatchesRepository();
      final userRepo = UserRepository();
      final courtRepo = CourtRepository();
      final clubRepo = ClubRepository();

      // Get time slot from user provider
      TimeSlotModel? timeSlot;
      try {
        timeSlot = await ref.read(userProvider.notifier).getCurrentMatchTimeSlot();
        print('DEBUG: timeSlot = ${timeSlot?.id}');
      } catch (e) {
        print('DEBUG: Error getting timeSlot: $e');
      }

      // Get user IDs from match
      final userIds = await matchesRepo.getMatchUserIds(matchId: matchId);
      print('DEBUG: userIds = $userIds');

      // Get user details
      List<UserModel> users = [];
      for (final uid in userIds) {
        final user = await userRepo.getUser(uid);
        if (user != null) {
          users.add(user);
          print('DEBUG: Added user ${user.firstName}');
        }
      }

      // Get club information
      dynamic club;
      if (timeSlot != null) {
        final court = await courtRepo.getCourtById(timeSlot.courtId);
        print('DEBUG: court = ${court?.name}');
        if (court != null) {
          club = await clubRepo.getClubById(court.clubId);
          print('DEBUG: club = ${club?.name}');
        }
      }

      print('DEBUG: Returning match info with ${users.length} users');
      return {'timeSlot': timeSlot, 'users': users, 'club': club};
    } catch (e) {
      print('Error getting match info: $e');
      rethrow;
    }
  }

  Widget _buildPlayerAvatar({
    required UserModel user,
    required bool isCurrentUser,
  }) {
    final displayName = user.firstName.isNotEmpty ? user.firstName : 'User';
    final initials = displayName[0].toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: user.profilePictureUrl != null &&
                      user.profilePictureUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        user.profilePictureUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            if (isCurrentUser)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 75,
          child: Text(
            displayName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
