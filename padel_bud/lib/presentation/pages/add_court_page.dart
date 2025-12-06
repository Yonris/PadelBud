import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/core/app_localizations.dart';
import '../../models/court_model.dart';
import '../../models/club_model.dart';
import '../../repositories/court_repository.dart';
import '../../repositories/club_repository.dart';
import '../../repositories/time_slot_repository.dart';

class AddCourtPage extends ConsumerStatefulWidget {
  const AddCourtPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCourtPage> createState() => _AddCourtPageState();
}

class DaySchedule {
  TimeOfDay? start;
  TimeOfDay? end;
  bool closed;
  bool expanded;

  DaySchedule({
    this.start,
    this.end,
    this.closed = false,
    this.expanded = false,
  });
}

class _AddCourtPageState extends ConsumerState<AddCourtPage> {
  final _formKey = GlobalKey<FormState>();
  final _clubNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController(text: '150');
  final _numCourtsController = TextEditingController();
  int _gameDuration = 60;
  double _price = 50.0;
  String _currency = 'ILS';
  bool _isLoading = false;
  int _numCourts = 1;
  String? _clubImagePath;

  final Map<String, DaySchedule> _weekSchedule = {
    'Monday': DaySchedule(expanded: true),
    'Tuesday': DaySchedule(),
    'Wednesday': DaySchedule(),
    'Thursday': DaySchedule(),
    'Friday': DaySchedule(),
    'Saturday': DaySchedule(),
    'Sunday': DaySchedule(),
  };

  Future<void> _pickClubImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _clubImagePath = pickedFile.path;
      });
    }
  }

  Future<String?> _uploadClubImageToFirebase(String imagePath) async {
    try {
      final userId = ref.read(authProvider).user?.uid;
      if (userId == null) return null;

      final file = File(imagePath);
      final fileName =
          'club_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref_ = FirebaseStorage.instance.ref().child(fileName);
      await ref_.putFile(file);

      final downloadUrl = await ref_.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading club image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).failedToUploadImage}: $e',
          ),
        ),
      );
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pickALocation)),
      );
      return;
    }
    GeoPoint? inputLocation = await _getLocationFromAddress(
      _addressController.text,
    );
    if (inputLocation == null) return;
    setState(() => _isLoading = true);

    try {
      // Upload club image if provided
      String? clubImageUrl;
      if (_clubImagePath != null && !_clubImagePath!.startsWith('http')) {
        clubImageUrl = await _uploadClubImageToFirebase(_clubImagePath!);
        if (clubImageUrl == null) {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Parse number of courts from controller
      final numCourts = int.tryParse(_numCourtsController.text) ?? 1;

      // Create the club
      final club = ClubModel(
        id: '',
        name: _clubNameController.text.trim(),
        location: inputLocation,
        address: _addressController.text.trim(),
        numberOfCourts: numCourts,
        gameDuration: _gameDuration,
        currency: _currency,
        price: _price,
        schedule: _weekSchedule.map(
          (day, sched) => MapEntry(day, {
            'closed': sched.closed,
            'start': sched.start?.format(context),
            'end': sched.end?.format(context),
          }),
        ),
        imageUrl: clubImageUrl,
      );

      final clubId = await ClubRepository().addClub(club);

      // Create multiple courts
      final List<String> courtIds = [];
      for (int c = 1; c <= numCourts; c++) {
        final court = CourtModel(
          id: '',
          name: 'Court $c',
          clubId: clubId,
          courtNumber: c,
        );

        final courtId = await CourtRepository().addCourt(court);
        courtIds.add(courtId);
      }

      final now = DateTime.now();
      final List<Map<String, dynamic>> timeSlots = [];

      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final weekdayName = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][date.weekday - 1]; // Internal key for schedule lookup

        final daySched = _weekSchedule[weekdayName];
        if (daySched == null ||
            daySched.closed ||
            daySched.start == null ||
            daySched.end == null)
          continue;

        final startMinutes = daySched.start!.hour * 60 + daySched.start!.minute;
        final endMinutes = daySched.end!.hour * 60 + daySched.end!.minute;

        for (
          int t = startMinutes;
          t + _gameDuration <= endMinutes;
          t += _gameDuration
        ) {
          final slotStart = DateTime(
            date.year,
            date.month,
            date.day,
            t ~/ 60,
            t % 60,
          );
          final slotEnd = slotStart.add(Duration(minutes: _gameDuration));

          // Create time slots for each court
          for (final courtId in courtIds) {
            timeSlots.add({
              'courtId': courtId,
              'start': slotStart,
              'end': slotEnd,
              'available': true,
              'buddies': 0,
              'price': _price,
            });
          }
        }
      }

      for (final slot in timeSlots) {
        await TimeSlotRepository().addTimeSlot(slot);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).clubAddedSuccessfully}',
          ),
        ),
      );

      _clubNameController.clear();
      _addressController.clear();
      _priceController.text = '50';
      _numCourtsController.text = '1';
      _price = 50.0;
      _numCourts = 1;
      _weekSchedule.forEach((_, sched) {
        sched.closed = false;
        sched.start = null;
        sched.end = null;
      });
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).failedToAddClub}: $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay? initial) async {
    return showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 8, minute: 0),
    );
  }

  Future<GeoPoint?> _getLocationFromAddress(String address) async {
    final locationNotifier = ref.read(locationProvider.notifier);
    final location = await locationNotifier.getGeoPointFromAddress(address);
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location from address')),
      );
      return null;
    } else {
      return location;
    }
  }

  void _copyDayToAll(String day) {
    final copy = _weekSchedule[day]!;
    _weekSchedule.forEach((key, sched) {
      if (key != day) {
        sched.start = copy.start;
        sched.end = copy.end;
        sched.closed = copy.closed;
      }
    });
    setState(() {});
  }

  String _getTranslatedDayName(String englishDay) {
    final localizations = AppLocalizations.of(context);
    switch (englishDay) {
      case 'Monday':
        return localizations.monday;
      case 'Tuesday':
        return localizations.tuesday;
      case 'Wednesday':
        return localizations.wednesday;
      case 'Thursday':
        return localizations.thursday;
      case 'Friday':
        return localizations.friday;
      case 'Saturday':
        return localizations.saturday;
      case 'Sunday':
        return localizations.sunday;
      default:
        return englishDay;
    }
  }

  String _getWeekdayName(int weekday) {
    final localizations = AppLocalizations.of(context);
    switch (weekday) {
      case 1:
        return localizations.monday;
      case 2:
        return localizations.tuesday;
      case 3:
        return localizations.wednesday;
      case 4:
        return localizations.thursday;
      case 5:
        return localizations.friday;
      case 6:
        return localizations.saturday;
      case 7:
        return localizations.sunday;
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _numCourtsController.dispose();
    super.dispose();
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
            AppLocalizations.of(context).createClub,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader(AppLocalizations.of(context).clubInformation),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _clubNameController,
                label: AppLocalizations.of(context).clubName,
                icon: Icons.business,
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context).enterClubName
                    : null,
              ),
              const SizedBox(height: 14),
              _buildFormField(
                controller: _addressController,
                label: AppLocalizations.of(context).clubAddress,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _numCourtsController,
                label: AppLocalizations.of(context).numberOfCourts,
                icon: Icons.numbers,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return AppLocalizations.of(context).enterNumberOfCourts;
                  final num = int.tryParse(v);
                  if (num == null || num < 1)
                    return AppLocalizations.of(context).validNumber;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickClubImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_clubImagePath != null)
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_clubImagePath!),
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context).tapToChangePhoto,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Color(0xFF1E88E5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context).addClubPhoto,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).tapToUploadPhoto,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildPriceField(),
              const SizedBox(height: 32),
              _buildSectionHeader(AppLocalizations.of(context).operatingHours),
              const SizedBox(height: 12),
              ..._weekSchedule.entries.map((entry) {
                final day = entry.key;
                final sched = entry.value;
                return _buildDayCard(day, sched);
              }).toList(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).createCourt,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDayCard(String day, DaySchedule sched) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sched.closed ? Colors.grey.shade200 : Colors.blue.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTranslatedDayName(day),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (!sched.closed &&
                        sched.start != null &&
                        sched.end != null)
                      Text(
                        '${sched.start?.format(context)} - ${sched.end?.format(context)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else if (sched.closed)
                      Text(
                        AppLocalizations.of(context).closed,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        AppLocalizations.of(context).notSet,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          initiallyExpanded: sched.expanded,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context).markAsClosed),
                    value: sched.closed,
                    onChanged: (v) => setState(() => sched.closed = v ?? false),
                    activeColor: const Color(0xFF1E88E5),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (!sched.closed) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeButton(
                            label:
                                sched.start?.format(context) ??
                                AppLocalizations.of(context).startTime,
                            onPressed: () async {
                              final t = await _pickTime(sched.start);
                              if (t != null) setState(() => sched.start = t);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeButton(
                            label:
                                sched.end?.format(context) ??
                                AppLocalizations.of(context).endTime,
                            onPressed: () async {
                              final t = await _pickTime(sched.end);
                              if (t != null) setState(() => sched.end = t);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!sched.closed) const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _copyDayToAll(day),
                      icon: const Icon(Icons.content_copy, size: 18),
                      label: Text(AppLocalizations.of(context).copyToAllDays),

                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 18, color: Colors.blue.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).gameDuration,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<int>(
            value: _gameDuration,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.timer_outlined,
                color: Color(0xFF1E88E5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
            ),
            items: [30, 45, 60, 90, 120]
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text('$m ${AppLocalizations.of(context).minutes}'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _gameDuration = v ?? 60),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).pricePerGame,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter price',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFF1E88E5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      setState(() => _price = parsed);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _currency,
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.currency_exchange,
                      color: Color(0xFF1E88E5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  items:
                      ['ILS', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF']
                          .map(
                            (currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _currency = v ?? 'ILS'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
