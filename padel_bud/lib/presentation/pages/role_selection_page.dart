import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/presentation/pages/main_navigation_page.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/providers/user_provider.dart';
import 'package:padel_bud/core/app_localizations.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  UserRole? _selectedRole;
  bool _isLoading = false;

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _confirmRole() async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userProvider.notifier).setUserRole(_selectedRole!);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent going back to previous screen
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.sports_tennis,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.of(context).selectRole,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).roleDescription,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  _buildRoleCard(
                    role: UserRole.player,
                    title: AppLocalizations.of(context).playerRole,
                    description: 'Find courts and play with other players',
                    icon: Icons.person_add_outlined,
                    isSelected: _selectedRole == UserRole.player,
                  ),
                  const SizedBox(height: 20),
                  _buildRoleCard(
                    role: UserRole.courtManager,
                    title: AppLocalizations.of(context).clubOwnerRole,
                    description: 'Manage your courts and bookings',
                    icon: Icons.business_outlined,
                    isSelected: _selectedRole == UserRole.courtManager,
                  ),
                  const SizedBox(height: 48),
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
                      onPressed: _selectedRole == null || _isLoading
                          ? null
                          : _confirmRole,
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
                              AppLocalizations.of(context).next,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2E7D32).withOpacity(0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
