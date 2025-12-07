import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/models/search_request.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/providers/user_provider.dart';
import 'package:padel_bud/repositories/search_requests_repository.dart';

class SelectTimePage extends ConsumerStatefulWidget {
  const SelectTimePage({super.key});

  @override
  ConsumerState<SelectTimePage> createState() => _SelectTimePageState();
}

class _SelectTimePageState extends ConsumerState<SelectTimePage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
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
            AppLocalizations.of(context).findBuddies,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).whenWantToPlay,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).selectDateAndTimeToFindPlayers,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                _buildDateCard(context),
                const SizedBox(height: 20),
                _buildTimeCard(context),
                const SizedBox(height: 40),
                _buildMatchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_today,
            color: Color(0xFF2E7D32),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).date,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          selectedDate == null
              ? AppLocalizations.of(context).selectDate
              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF1E88E5)),
        onTap: pickDate,
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.access_time,
            color: Color(0xFF2E7D32),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).time,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          selectedTime == null ? AppLocalizations.of(context).selectTime : selectedTime!.format(context),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF2E7D32)),
        onTap: pickTime,
      ),
    );
  }

  Widget _buildMatchButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: (selectedDate != null && selectedTime != null)
            ? () async {
                final searchRequest = SearchRequestModel(
                  id: '',
                  userId: ref.read(authProvider).user!.uid,
                  location: ref.read(locationProvider).currentLocation!,
                  dateTime: DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  ),
                );
                final docRef = await SearchRequestsRepository().createSearchRequest(searchRequest);
                ref.read(currentSearchRequestIdProvider.notifier).state = docRef.id;
                ref
                    .read(userProvider.notifier)
                    .setSearchingForBuddies(BuddiesState.searching);
              }
            : null,
        child: Text(
          AppLocalizations.of(context).findMatch,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
