import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/core/utils/currency_utils.dart';
import 'package:padel_bud/providers/providers.dart';
import '../../models/club_model.dart';
import '../../models/court_model.dart';
import '../../models/time_slot_model.dart';
import '../../repositories/club_repository.dart';
import '../../repositories/court_repository.dart';
import '../../repositories/time_slot_repository.dart';

class ClubManagerCourtSchedulePage extends ConsumerStatefulWidget {
  final ClubModel club;

  const ClubManagerCourtSchedulePage({required this.club, Key? key})
    : super(key: key);

  @override
  ConsumerState<ClubManagerCourtSchedulePage> createState() =>
      _ClubManagerCourtSchedulePageState();
}

class _ClubManagerCourtSchedulePageState
    extends ConsumerState<ClubManagerCourtSchedulePage>
    with TickerProviderStateMixin {
  List<CourtModel> _courts = [];
  Map<String, List<TimeSlotModel>> _courtTimeSlots = {};
  Map<String, bool> _expandedCourts = {}; // Track which courts are expanded
  Set<String> _updatingSlots = {}; // Track slots being updated
  bool _loading = true;
  late TabController _tabController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userId = ref.read(authProvider).user?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      // Get all courts for this manager and club
      final allCourts = await CourtRepository().getCourtsByManager(userId);
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
        // Initialize all courts as expanded by default
        _expandedCourts = {for (var court in courts) court.id: true};
        _loading = false;
      });
      _fadeController.forward();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      setState(() => _loading = false);
    }
  }

  void _showEditPriceDialog(CourtModel court, List<TimeSlotModel> slots) {
    final priceController = TextEditingController(
      text: slots.isNotEmpty ? slots.first.price.toStringAsFixed(0) : '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${AppLocalizations.of(context).editPrice} - ${court.name}',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).price,
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).willUpdateAllSlots,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            onPressed: () => _updateCourtPrice(court, priceController.text),
            child: Text(
              AppLocalizations.of(context).update,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCourtPrice(CourtModel court, String priceText) async {
    final newPrice = double.tryParse(priceText);
    if (newPrice == null || newPrice < 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).enterValidPrice)),
      );
      return;
    }

    try {
      await TimeSlotRepository().updateCourtPrices(court.id, newPrice);

      // Update local state
      final slots = _courtTimeSlots[court.id] ?? [];
      for (final slot in slots) {
        slot.price = newPrice;
      }
      setState(() {});

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).priceUpdated)),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
      );
    }
  }

  void _showEditClubDetailsDialog() {
    final nameController = TextEditingController(text: widget.club.name);
    final addressController = TextEditingController(text: widget.club.address);
    final phoneController = TextEditingController(
      text: widget.club.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).editClubDetails),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).clubName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).clubAddress,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).clubPhone,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
            onPressed: () async {
              await _updateClubDetails(
                nameController.text,
                addressController.text,
                phoneController.text,
              );
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).update,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateClubDetails(
    String name,
    String address,
    String phone,
  ) async {
    try {
      await ClubRepository().updateClubInfo(
        clubId: widget.club.id,
        name: name,
        address: address,
        phone: phone,
      );

      // Update local state for immediate UI feedback
      widget.club.name = name;
      widget.club.address = address;
      widget.club.phone = phone;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).clubAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectPhoto),
        content: Text(AppLocalizations.of(context).tapToChangePhoto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              AppLocalizations.of(context).camera,
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
            ),
            icon: const Icon(Icons.photo_library, color: Colors.white),
            label: Text(
              AppLocalizations.of(context).gallery,
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).uploadingPhoto),
            duration: const Duration(seconds: 2),
          ),
        );

        // Upload image to Firebase Storage
        final clubRepository = ClubRepository();
        final imageUrl = await clubRepository.uploadClubPhoto(
          widget.club.id,
          pickedFile.path,
        );

        // Update club document with the Firebase Storage URL
        await clubRepository.updateClubPhoto(widget.club.id, imageUrl);

        widget.club.imageUrl = imageUrl;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).photoUploadSuccess),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCurrencyDialog() {
    final currencies = ['ILS', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF'];
    String selectedCurrency = widget.club.currency;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectCurrency),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: selectedCurrency,
                activeColor: Colors.green.shade600,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCurrency = value);
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
            onPressed: () async {
              await _updateCurrency(selectedCurrency);
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).update,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCurrency(String newCurrency) async {
    try {
      await ClubRepository().updateClubCurrency(widget.club.id, newCurrency);

      // Update local state for immediate UI feedback
      widget.club.currency = newCurrency;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).currencyUpdated),
            backgroundColor: Colors.green,
          ),
        );
        // Trigger rebuild to show new currency
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleTimeSlotAvailability(TimeSlotModel slot) async {
    setState(() => _updatingSlots.add(slot.id));

    try {
      final timeSlotRepo = TimeSlotRepository();
      if (slot.available) {
        await timeSlotRepo.markTimeSlotAsBooked(slot.id);
      } else {
        await timeSlotRepo.setTimeSlotAvailable(slot.id);
      }

      // Update local state
      slot.available = !slot.available;
      setState(() => _updatingSlots.remove(slot.id));

      
    } catch (e) {
      setState(() => _updatingSlots.remove(slot.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        iconTheme: const IconThemeData(color: Colors.white),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: [
            Tab(text: AppLocalizations.of(context).clubDetails),
            Tab(text: AppLocalizations.of(context).courtSchedule),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildClubDetailsTab(), _buildCourtScheduleTab()],
            ),
    );
  }

  Widget _buildClubDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClubInfoSection(),
          const SizedBox(height: 20),
          _buildImageSection(),
          const SizedBox(height: 20),
          _buildCurrencySection(),
          const SizedBox(height: 20),
          _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildClubInfoSection() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).clubInformation,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildClubInfoRow('Name', widget.club.name),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: Text(
                AppLocalizations.of(context).editClubDetails,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _showEditClubDetailsDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library, color: Colors.green.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).clubPhoto,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.club.imageUrl != null && widget.club.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.club.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: Text(
                AppLocalizations.of(context).uploadPhoto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _showPhotoPickerDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySection() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_exchange,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).currency,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: Text(
                      CurrencyUtils.getSymbol(widget.club.currency ?? 'ILS'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.club.currency ?? 'ILS',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: Text(
                AppLocalizations.of(context).changeCurrency,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _showCurrencyDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: Text(
                    CurrencyUtils.getSymbol(widget.club.currency ?? 'ILS'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).pricing,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).setPricesForCourts,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          if (_courts.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courts.length,
              itemBuilder: (context, index) {
                final court = _courts[index];
                final slots = _courtTimeSlots[court.id] ?? [];
                final price = slots.isNotEmpty ? slots.first.price : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              court.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${AppLocalizations.of(context).currentPrice}: ${CurrencyUtils.getSymbol(widget.club.currency ?? 'ILS')}$price',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _showEditPriceDialog(court, slots),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Center(
              child: Text(
                AppLocalizations.of(context).noCourtsFound,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourtScheduleTab() {
    return _courts.isEmpty
        ? const Center(
            child: Text(
              'No courts found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadData,
            color: Colors.green.shade600,
            child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _courts.length,
                itemBuilder: (context, index) {
                  final court = _courts[index];
                  final slots = _courtTimeSlots[court.id] ?? [];
                  final isExpanded = _expandedCourts[court.id] ?? true;
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _fadeController,
                        curve: Interval(
                          index * 0.05,
                          (index * 0.05) + 0.4,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                    child: _buildCourtCard(court, slots, isExpanded),
                  );
                },
              ),
            );
  }

  Widget _buildCourtCard(
    CourtModel court,
    List<TimeSlotModel> slots,
    bool isExpanded,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedCourts[court.id] = !isExpanded;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.green.shade200, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${slots.length} ${AppLocalizations.of(context).available}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.green.shade600,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(20),
              child: slots.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context).noAvailableSlots,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildSlotStats(slots),
                        const SizedBox(height: 18),
                        _buildSlotList(slots),
                      ],
                    ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 100),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotStats(List<TimeSlotModel> slots) {
    final availableCount = slots.where((s) => s.available).length;
    final bookedCount = slots.where((s) => !s.available).length;

    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context).available,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$availableCount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 18,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context).booked,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$bookedCount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlotList(List<TimeSlotModel> slots) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: List.generate(slots.length, (index) {
          final slot = slots[index];
          final isAvailable = slot.available;
          final isUpdating = _updatingSlots.contains(slot.id);
          final startTime = DateFormat('HH:mm').format(slot.start);
          final endTime = DateFormat('HH:mm').format(slot.end);
          final date = DateFormat('MMM d, EEE').format(slot.start);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white,
              border: index < slots.length - 1
                  ? Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    )
                  : null,
              borderRadius: index == 0
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    )
                  : index == slots.length - 1
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(13),
                      bottomRight: Radius.circular(13),
                    )
                  : BorderRadius.zero,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleTimeSlotAvailability(slot),
                borderRadius: index == 0
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                      )
                    : index == slots.length - 1
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(13),
                        bottomRight: Radius.circular(13),
                      )
                    : BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 80),
                        curve: Curves.easeOutCubic,
                        scale: isUpdating ? 1.1 : 1.0,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: isAvailable
                                ? LinearGradient(
                                    colors: [
                                      Colors.green.shade100,
                                      Colors.green.shade50,
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.red.shade100,
                                      Colors.red.shade50,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isAvailable
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isAvailable ? Icons.check_circle : Icons.event_busy,
                            color: isAvailable
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$startTime - $endTime',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isUpdating)
                        Container(
                          width: 44,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      else
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isAvailable
                                ? LinearGradient(
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.red.shade50,
                                      Colors.red.shade100,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isAvailable
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isAvailable
                                ? AppLocalizations.of(context).available
                                : AppLocalizations.of(context).booked,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isAvailable
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
