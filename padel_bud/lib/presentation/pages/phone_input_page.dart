import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/presentation/pages/home_page.dart';
import 'package:padel_bud/presentation/pages/main_navigation_page.dart';
import 'package:padel_bud/presentation/pages/role_selection_page.dart';
import 'package:padel_bud/providers/auth_provider.dart';
import 'package:padel_bud/core/app_localizations.dart';
import '../../providers/providers.dart';

class PhoneInputPage extends ConsumerStatefulWidget {
  const PhoneInputPage({super.key});

  @override
  ConsumerState<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends ConsumerState<PhoneInputPage> {
  final phoneController = TextEditingController();
  String? selectedCountry = 'Israel';

  final Map<String, String> countryToCode = {
    'Israel': '+972',
    'United States': '+1',
    'Canada': '+1',
    'United Kingdom': '+44',
    'France': '+33',
    'Germany': '+49',
    'Spain': '+34',
    'Italy': '+39',
    'Australia': '+61',
    'Brazil': '+55',
    'Mexico': '+52',
    'Japan': '+81',
    'China': '+86',
    'India': '+91',
    'Russia': '+7',
    'South Africa': '+27',
    'Argentina': '+54',
    'Chile': '+56',
    'Colombia': '+57',
    'Greece': '+30',
  };

  void _showSmsDialog(String verificationId) {
    final smsController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).verificationCodeTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).enterSixDigitCode,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: smsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 2,
                      ),
                    ),
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      letterSpacing: 8,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final code = smsController.text.trim();
                      if (code.isEmpty || code.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).pleaseEnterValidCode),
                            backgroundColor: Colors.red.shade600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      await ref.read(authProvider.notifier).verifySmsCode(code);
                      if (mounted) {
                        Navigator.pop(context);
                        // Small delay to allow state updates
                        await Future.delayed(const Duration(milliseconds: 300));
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context).verifyPhone,
                      style: TextStyle(
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
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.user == null && next.user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Wait for user data to be loaded from Firestore
          await Future.delayed(const Duration(milliseconds: 800));
          
          if (!mounted) return;
          
          final userState = ref.read(userProvider);
          if (userState.initialized && userState.roleSelected) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                (route) => false,
              );
            }
          } else if (userState.initialized) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
                (route) => false,
              );
            }
          }
        });
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (prev?.codeSent == false && next.codeSent) {
        _showSmsDialog(next.verificationId!);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.sports_tennis,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context).welcomeToPadelBud,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).signInWithYourPhoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedCountry,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).countryState,
                      prefixIcon: const Icon(
                        Icons.public_outlined,
                        color: Color(0xFF2E7D32),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    items: countryToCode.keys.map((country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(
                          '$country ${countryToCode[country]}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).phoneNumber,
                      hintText: AppLocalizations.of(context).hintPhoneNumber,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: Color(0xFF2E7D32),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              selectedCountry != null
                                  ? countryToCode[selectedCountry]!
                                  : '+972',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
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
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final phone = phoneController.text.trim();
                            if (phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).pleaseEnterPhoneNumber),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            
                            // Add country code to phone number
                            final countryCode = selectedCountry != null
                                ? countryToCode[selectedCountry]!
                                : '+972';
                            final fullPhone = '$countryCode${phone.replaceAll(RegExp(r'[^0-9]'), '')}';
                            
                            await ref
                                .read(authProvider.notifier)
                                .sendPhoneVerification(fullPhone);
                          },
                    child: auth.isLoading
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
                            AppLocalizations.of(context).sendVerificationCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context).weWillSendCode,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
