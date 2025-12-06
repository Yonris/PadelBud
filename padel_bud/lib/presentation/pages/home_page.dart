import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/models/search_request.dart';
import 'package:padel_bud/providers/location_provider.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/repositories/club_repository.dart';
import 'package:padel_bud/core/app_localizations.dart';
import '../../models/club_model.dart';
import '../widgets/court_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    ref.read(locationProvider.notifier).updateLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClubModel> getFilteredAndSortedClubs(
    List<ClubModel> clubs,
    GeoPoint? userLocation,
  ) {
    // First apply search filter
    List<ClubModel> filteredClubs = clubs;
    if (_searchQuery.isNotEmpty) {
      filteredClubs = clubs
          .where((club) =>
              club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              club.address.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (userLocation == null) {
      // If no location available, show filtered clubs
      return filteredClubs;
    }

    // Sort clubs by distance but show all of them
    return SearchRequestModel.sortClubsByDistance(filteredClubs, userLocation);
  }

  Future<void> _refreshCourts() async {
    final locationNotifier = ref.read(locationProvider.notifier);
    await locationNotifier.updateLocation();

    if (!mounted) return;

    ref
        .read(userProvider.notifier)
        .updateUser(
          currentLocation: ref.read(locationProvider).currentLocation,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocationState>(locationProvider, (prev, next) {
      if (prev?.currentLocation != next.currentLocation &&
          next.currentLocation != null) {
        ref
            .read(userProvider.notifier)
            .updateUser(currentLocation: next.currentLocation);
      }
    });

    final locationState = ref.watch(locationProvider);
    final userLocation = locationState.currentLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        toolbarHeight: 140,
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
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).bookCourt,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).searchClubs,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<ClubModel>>(
        future: ClubRepository().getClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final allClubs = snapshot.data ?? [];

          final clubs = getFilteredAndSortedClubs(allClubs, userLocation);

          if (clubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_tennis, size: 70, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    userLocation == null
                        ? AppLocalizations.of(context).waitingForLocation
                        : AppLocalizations.of(context).noClubsAvailable,
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  if (userLocation == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.blue,
            onRefresh: _refreshCourts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clubs.length,
              itemBuilder: (ctx, i) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 350 + (i * 80)),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: CourtCard(club: clubs[i], userLocation: userLocation),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
