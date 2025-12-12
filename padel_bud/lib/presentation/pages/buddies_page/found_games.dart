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
import 'package:padel_bud/repositories/matches_repository.dart';
import 'package:padel_bud/repositories/user_repository.dart';
import 'package:padel_bud/repositories/search_requests_repository.dart';
import 'package:padel_bud/repositories/time_slot_repository.dart';

class FoundMatchPage extends ConsumerWidget {
  const FoundMatchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final matchId = userState.matchId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
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
      body: matchId == null
          ? Center(child: Text(AppLocalizations.of(context).noMatchFound))
          : _buildMatchBody(context, ref, matchId),
    );
  }

  Widget _buildMatchBody(BuildContext context, WidgetRef ref, String matchId) {
    return ref.watch(foundMatchInfoProvider(matchId)).when(
      data: (matchInfo) {
        if (matchInfo == null) {
          return Center(child: Text(AppLocalizations.of(context).noMatchFound));
        }

        final users = matchInfo['users'] as List<UserModel>?;
        
        // Ensure all user profile images are loaded before rendering
        if (users != null && users.isNotEmpty) {
          return FutureBuilder<void>(
            future: _preloadUserImages(context, users),
            builder: (context, preloadSnapshot) {
              if (preloadSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildMatchContent(context, ref, matchInfo);
            },
          );
        }
        
        return _buildMatchContent(context, ref, matchInfo);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          '${AppLocalizations.of(context).error}: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildMatchContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> matchInfo,
  ) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF2E7D32),
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
                                      hasAccepted:
                                          (matchInfo['acceptedUserIds'] as List<String>?)?.contains(users[i].id) ?? false,
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
                                        hasAccepted:
                                            (matchInfo['acceptedUserIds'] as List<String>?)?.contains(users[i].id) ?? false,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
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
                          onPaymentSuccess: () async {
                            final matchId = ref.read(userProvider).matchId;
                            final currentUserId = ref.read(authProvider).user?.uid;
                            
                            if (matchId != null && currentUserId != null) {
                              await MatchesRepository().addUserToAcceptedList(
                                matchId: matchId,
                                userId: currentUserId,
                              );
                            }
                            
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
                      _handleSkipInBackground(context, ref);
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
  }

  Future<void> _preloadUserImages(BuildContext context, List<UserModel> users) async {
    for (final user in users) {
      if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
        try {
          await precacheImage(
            NetworkImage(user.profilePictureUrl!),
            context,
          );
        } catch (e) {
          print('DEBUG: Error preloading image for ${user.firstName}: $e');
        }
      }
    }
  }

  void _handleSkipInBackground(BuildContext context, WidgetRef ref) {
    final userState = ref.read(userProvider);
    final currentUserId = ref.read(authProvider).user?.uid;
    final matchId = userState.matchId;

    if (matchId == null || currentUserId == null) {
      return;
    }

    // Perform cleanup in the background without blocking the UI
    _performSkipCleanup(matchId, currentUserId);
  }

  void _performSkipCleanup(String matchId, String currentUserId) async {
    try {
      final matchesRepo = MatchesRepository();
      final userRepo = UserRepository();
      final searchReqRepo = SearchRequestsRepository();
      final timeSlotRepo = TimeSlotRepository();

      // Get match details to get the time slot ID
      final matchDetails = await matchesRepo.getMatchDetails(matchId: matchId);
      final timeSlotId = matchDetails?['timeSlotId'] as String?;

      // Get all user IDs in the match
      final userIds = await matchesRepo.getMatchUserIds(matchId: matchId);
      final otherUserIds = userIds.where((id) => id != currentUserId).toList();

      // Delete the match
      await matchesRepo.deleteMatch(matchId: matchId);

      // Set time slot back to available
      if (timeSlotId != null) {
        await timeSlotRepo.setTimeSlotAvailable(timeSlotId);
      }

      // Delete current user's search request
      final currentUserSearchReqId = await searchReqRepo.getSearchRequestIdForUser(currentUserId);
      if (currentUserSearchReqId != null) {
        await searchReqRepo.deleteSearchRequest(currentUserSearchReqId);
      }

      // Reset the 3 other users
      for (final userId in otherUserIds) {
        // Get their search request ID
        final searchReqId = await searchReqRepo.getSearchRequestIdForUser(userId);
        if (searchReqId != null) {
          // Set search request to available
          await searchReqRepo.setSearchRequestAvailable(searchReqId, true);
        }

        // Reset user's state
        await userRepo.updateUserData(
          currentUserId: userId,
          buddiesState: BuddiesState.searching,
          matchId: null,
        );
      }
    } catch (e) {
      print('Error in background skip cleanup: $e');
    }
  }

  Widget _buildPlayerAvatar({
    required UserModel user,
    required bool hasAccepted,
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
            if (hasAccepted)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
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
