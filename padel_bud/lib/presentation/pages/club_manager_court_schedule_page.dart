import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padel_bud/core/app_localizations.dart';
import '../../models/club_model.dart';
import '../../models/court_model.dart';
import '../../models/time_slot_model.dart';
import '../../repositories/court_repository.dart';
import '../../repositories/time_slot_repository.dart';

class ClubManagerCourtSchedulePage extends StatefulWidget {
  final ClubModel club;

  const ClubManagerCourtSchedulePage({required this.club, Key? key})
    : super(key: key);

  @override
  State<ClubManagerCourtSchedulePage> createState() =>
      _ClubManagerCourtSchedulePageState();
}

class _ClubManagerCourtSchedulePageState
    extends State<ClubManagerCourtSchedulePage> {
  List<CourtModel> _courts = [];
  Map<String, List<TimeSlotModel>> _courtTimeSlots = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get all courts for this club
      final allCourts = await CourtRepository().getCourts();
      final courts = allCourts
          .where((c) => c.clubId == widget.club.id)
          .toList();
      courts.sort((a, b) => a.courtNumber.compareTo(b.courtNumber));

      // Get time slots for each court individually
      final Map<String, List<TimeSlotModel>> courtSlots = {};
      for (final court in courts) {
        final slots = await TimeSlotRepository().getTimeSlots(
          courtId: court.id,
        );
        slots.sort((a, b) => a.start.compareTo(b.start));
        courtSlots[court.id] = slots;
      }

      setState(() {
        _courts = courts;
        _courtTimeSlots = courtSlots;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
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
            widget.club.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courts.isEmpty
          ? const Center(
              child: Text(
                'No courts found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _courts.length,
                itemBuilder: (context, index) {
                  final court = _courts[index];
                  final slots = _courtTimeSlots[court.id] ?? [];
                  return _buildCourtCard(court, slots);
                },
              ),
            ),
    );
  }

  Widget _buildCourtCard(CourtModel court, List<TimeSlotModel> slots) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_tennis,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        court.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: slots.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).noAvailableSlots,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : Column(
                    children: [
                      _buildSlotStats(slots),
                      const SizedBox(height: 16),
                      _buildSlotList(slots),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotStats(List<TimeSlotModel> slots) {
    final availableCount = slots.where((s) => s.available).length;
    final bookedCount = slots.where((s) => !s.available).length;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).available,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$availableCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).booked,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bookedCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotList(List<TimeSlotModel> slots) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(slots.length, (index) {
          final slot = slots[index];
          final isAvailable = slot.available;
          final startTime = DateFormat('HH:mm').format(slot.start);
          final endTime = DateFormat('HH:mm').format(slot.end);
          final date = DateFormat('MMM d').format(slot.start);

          return Container(
            decoration: BoxDecoration(
              border: index < slots.length - 1
                  ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isAvailable ? Icons.check_circle : Icons.block,
                      color: isAvailable ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$startTime - $endTime',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAvailable ? AppLocalizations.of(context).available : AppLocalizations.of(context).booked,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
