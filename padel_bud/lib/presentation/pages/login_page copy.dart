import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/providers/auth_provider.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/presentation/pages/main_navigation_page.dart';
import 'package:padel_bud/presentation/pages/role_selection_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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

  void _showSmsDialog(String verificationId, WidgetRef ref) {
    final smsController = TextEditingController();
    
    try {
      final localizations = AppLocalizations.of(context);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
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
                    localizations.verificationCodeTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.enterSixDigitCode,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ),
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
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(localizations.pleaseEnterValidCode),
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          return;
                        }
                        
                        try {
                          await ref.read(authProvider.notifier).verifySmsCode(code);
                          final authState = ref.read(authProvider);
                          if (dialogContext.mounted && authState.error == null) {
                            Navigator.pop(dialogContext);
                          }
                        } catch (e) {
                          print('[Login] Error verifying code: $e');
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        localizations.verifyPhone,
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
                        if (dialogContext.mounted) {
                          ref.read(authProvider.notifier).resetVerification();
                          Navigator.pop(dialogContext);
                        }
                      },
                      child: Text(
                        localizations.cancel,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print('[Login] Error showing SMS dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error showing dialog: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);

        ref.listen<AuthState>(authProvider, (prev, next) {
          if (prev?.user == null && next.user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await Future.delayed(const Duration(milliseconds: 800));

              if (!mounted) return;

              final userState = ref.read(userProvider);
              if (userState.initialized && userState.roleSelected) {
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationPage(),
                    ),
                    (route) => false,
                  );
                }
              } else if (userState.initialized) {
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectionPage(),
                    ),
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

          if ((prev?.codeSent != true) && next.codeSent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showSmsDialog(next.verificationId!, ref);
              }
            });
          }
        });

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Image.asset(
                            'lib/assets/logo.png',
                            height: 280,
                            width: 280,
                          ),
                        ),

                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Column(
                            children: [Text(
                                AppLocalizations.of(context).appDescription,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: DropdownButton<String>(
                                    value: selectedCountry,
                                    underline: SizedBox(),
                                    isExpanded: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    dropdownColor: Colors.white,
                                    iconEnabledColor: Colors.white,
                                    selectedItemBuilder: (BuildContext context) {
                                      return countryToCode.keys.map<Widget>((country) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '$country ${countryToCode[country]}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    items: countryToCode.keys.map((country) {
                                      return DropdownMenuItem<String>(
                                        value: country,
                                        child: Text(
                                          '$country ${countryToCode[country]}',
                                          style: const TextStyle(fontSize: 14, color: Colors.black),
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
                              ),

                              const SizedBox(height: 12),

                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    ).hintPhoneNumber,
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.phone_outlined,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            selectedCountry != null
                                                ? countryToCode[selectedCountry]!
                                                : '+972',
                                            style: const TextStyle(
                                              color: Colors.white,
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
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: authState.isLoading
                                      ? null
                                      : () async {
                                          final phone = phoneController.text
                                              .trim();
                                          if (phone.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  ).pleaseEnterPhoneNumber,
                                                ),
                                                backgroundColor:
                                                    Colors.red.shade600,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                            return;
                                          }

                                          final countryCode =
                                              selectedCountry != null
                                              ? countryToCode[selectedCountry]!
                                              : '+972';
                                          final fullPhone =
                                              '$countryCode${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

                                          await ref
                                              .read(authProvider.notifier)
                                              .sendPhoneVerification(fullPhone);
                                        },
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF2E7D32),
                                                ),
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          AppLocalizations.of(
                                            context,
                                          ).sendVerificationCode,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                AppLocalizations.of(context).weWillSendCode,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
