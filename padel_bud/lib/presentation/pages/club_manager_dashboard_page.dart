import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/presentation/widgets/club_image_widget.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/core/utils/currency_utils.dart';
import 'package:padel_bud/providers/providers.dart';
import '../../models/club_model.dart';
import '../../repositories/club_repository.dart';
import 'club_manager_court_schedule_page.dart';

class ClubManagerDashboardPage extends ConsumerStatefulWidget {
  const ClubManagerDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ClubManagerDashboardPage> createState() =>
      _ClubManagerDashboardPageState();
}

class _ClubManagerDashboardPageState
    extends ConsumerState<ClubManagerDashboardPage> {
  List<ClubModel> _clubs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    try {
      final userId = ref.read(authProvider).user?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }
      final clubs = await ClubRepository().getClubsByManager(userId);

      // Preload club images
      if (mounted) {
        await _preloadClubImages(clubs);
      }

      if (mounted) {
        setState(() {
          _clubs = clubs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _preloadClubImages(List<ClubModel> clubs) async {
    for (final club in clubs) {
      if (club.imageUrl != null && club.imageUrl!.isNotEmpty) {
        try {
          await precacheImage(NetworkImage(club.imageUrl!), context);
        } catch (e) {
          print('DEBUG: Error preloading image for ${club.name}: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).myCubs,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : _clubs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      Icons.business_center_sharp,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).noClubsCreated,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first club to manage courts',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: _loadClubs,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: _clubs.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 300 + (index * 100)),
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
                    child: _buildClubCard(_clubs[index]),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildClubCard(ClubModel club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ClubManagerCourtSchedulePage(club: club),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with club image and name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClubImageWidget(
                        club: club,
                        width: 70,
                        height: 70,
                        borderRadius: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  club.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Stats row
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.sports_tennis,
                      label:
                          '${club.numberOfCourts} ${AppLocalizations.of(context).courts}',
                      backgroundColor: Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    _buildStatChip(
                      icon: Icons.schedule,
                      label: '${club.gameDuration} min',
                      backgroundColor: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: _buildStatChip(
                        label:
                            '${CurrencyUtils.getSymbol(club.currency)}${club.price.toStringAsFixed(0)}',
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ClubManagerCourtSchedulePage(club: club),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Manage Schedule',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    IconData? icon,
    required String label,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        // ← centers contents
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // ← ensures centering
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: backgroundColor),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: backgroundColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // ← guarantees centered text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
