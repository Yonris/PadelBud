import 'package:flutter/material.dart';
import 'package:padel_bud/presentation/widgets/club_image_widget.dart';
import 'package:padel_bud/core/app_localizations.dart';
import '../../models/club_model.dart';
import '../../repositories/club_repository.dart';
import 'club_manager_court_schedule_page.dart';

class ClubManagerDashboardPage extends StatefulWidget {
  const ClubManagerDashboardPage({Key? key}) : super(key: key);

  @override
  State<ClubManagerDashboardPage> createState() =>
      _ClubManagerDashboardPageState();
}

class _ClubManagerDashboardPageState extends State<ClubManagerDashboardPage> {
  List<ClubModel> _clubs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    try {
      final clubs = await ClubRepository().getClubs();
      setState(() {
        _clubs = clubs;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
      );
      setState(() => _loading = false);
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
            AppLocalizations.of(context).myCubs,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clubs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_center_sharp,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).noClubsCreated,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadClubs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _clubs.length,
                    itemBuilder: (context, index) {
                      return _buildClubCard(_clubs[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildClubCard(ClubModel club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ClubManagerCourtSchedulePage(club: club),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClubImageWidget(
                      club: club,
                      width: 60,
                      height: 60,
                      borderRadius: 14,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            club.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.sports_tennis,
                      label: '${club.numberOfCourts} ${AppLocalizations.of(context).courts}',
                      color: Colors.blue,
                    ),
                      const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.timer,
                      label: '${club.gameDuration} ${AppLocalizations.of(context).minutes}',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.attach_money,
                      label: '${club.price.toStringAsFixed(0)} ${club.currency}',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
