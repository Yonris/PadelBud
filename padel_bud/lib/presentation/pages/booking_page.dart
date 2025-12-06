import 'package:flutter/material.dart';
import 'package:padel_bud/core/payment_service.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/presentation/widgets/payment_dialog.dart';
import 'package:padel_bud/presentation/widgets/slot_card.dart';
import 'package:padel_bud/repositories/time_slot_repository.dart';
import '../../models/club_model.dart';
import '../../models/time_slot_model.dart';

class BookingPage extends StatefulWidget {
  final ClubModel club;

  const BookingPage({required this.club, Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _currentDay = DateTime.now();
  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<TimeSlotModel> _allSlots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSlotsOnce();
  }

  Future<void> _loadSlotsOnce() async {
    final slots = await TimeSlotRepository().getTimeSlotsForClub(
      clubId: widget.club.id,
    );

    setState(() {
      _allSlots = slots;
      _loading = false;
    });
  }

  List<TimeSlotModel> _getSlotsForCurrentDay() {
    return _allSlots.where((slot) {
      return slot.start.year == _currentDay.year &&
          slot.start.month == _currentDay.month &&
          slot.start.day == _currentDay.day;
    }).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  void _nextDay() {
    final nextDay = _currentDay.add(const Duration(days: 1));
    final lastDay = _today.add(const Duration(days: 7));
    if (!nextDay.isAfter(lastDay)) {
      setState(() => _currentDay = nextDay);
    }
  }

  void _previousDay() {
    final prevDay = _currentDay.subtract(const Duration(days: 1));
    if (!prevDay.isBefore(_today)) {
      setState(() => _currentDay = prevDay);
    }
  }

  String _getLocalizedDayName(DateTime date) {
    final localizations = AppLocalizations.of(context);
    switch (date.weekday) {
      case 1: return localizations.monday;
      case 2: return localizations.tuesday;
      case 3: return localizations.wednesday;
      case 4: return localizations.thursday;
      case 5: return localizations.friday;
      case 6: return localizations.saturday;
      case 7: return localizations.sunday;
      default: return '';
    }
  }

  void _bookSlot(TimeSlotModel slot) {
    if (!slot.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).thisSlotNotAvailable),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        productId: PaymentService.courtBookingProductId,
        amount:
            '${widget.club.price.toStringAsFixed(0)} ${widget.club.currency}',
        description:
            AppLocalizations.of(context).book + widget.club.name,
        startTime:
            '${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}',
        endTime:
            '${slot.end.hour.toString().padLeft(2, '0')}:${slot.end.minute.toString().padLeft(2, '0')}',
        onPaymentSuccess: () async {
          try {
            // Mark time slot as booked
            await TimeSlotRepository().markTimeSlotAsBooked(slot.id);

            // Reload slots to reflect the change
            await _loadSlotsOnce();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${AppLocalizations.of(context).bookedSuccessfully} ${widget.club.name} at "
                  "${slot.start.hour.toString().padLeft(2, '0')}:"
                  "${slot.start.minute.toString().padLeft(2, '0')}",
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.of(context).errorBooking}: $e',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel =
        "${_currentDay.day}/${_currentDay.month}/${_currentDay.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        title: Row(
          children: [
            Expanded(
              child: Text(
                "${AppLocalizations.of(context).book} ${widget.club.name}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // -------- Day Selector --------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentDay.isAfter(_today)
                        ? _previousDay
                        : null,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _currentDay.isAfter(_today)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),

                  Column(
                    children: [
                      Text(
                        _getLocalizedDayName(_currentDay),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  IconButton(
                    onPressed:
                        _currentDay.isBefore(
                          _today.add(const Duration(days: 7)),
                        )
                        ? _nextDay
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color:
                          _currentDay.isBefore(
                            _today.add(const Duration(days: 7)),
                          )
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // -------- Slot List --------
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSlotList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotList() {
    final slots = _getSlotsForCurrentDay();
    final availableSlots = slots.where((s) => s.available).toList();

    if (availableSlots.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noAvailableSlots,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: availableSlots.length,
      itemBuilder: (ctx, i) {
        final slot = availableSlots[i];

        final timeLabel =
            "${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')} - "
            "${slot.end.hour.toString().padLeft(2, '0')}:${slot.end.minute.toString().padLeft(2, '0')}";

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (i * 50)),
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
          child: SlotCard(
            timeLabel: timeLabel,
            price: '${slot.price.toStringAsFixed(0)} ILS',
            onBook: () => _bookSlot(slot),
          ),
        );
      },
    );
  }
}
