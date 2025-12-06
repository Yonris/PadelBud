import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/presentation/pages/buddies_page/buddies_page.dart';
import 'package:padel_bud/presentation/pages/profile_page.dart';
import 'package:padel_bud/presentation/pages/home_page.dart';
import 'package:padel_bud/presentation/pages/add_court_page.dart';
import 'package:padel_bud/presentation/pages/club_manager_dashboard_page.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/core/app_localizations.dart';
class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _selectedIndex = 1;

  List<Widget> _getPages(UserRole role) {
    if (role == UserRole.courtManager) {
      return <Widget>[
        const EditProfilePage(),
        const AddCourtPage(),
        const ClubManagerDashboardPage(),
        const HomePage(),
        const BuddiesPage(),
      ];
    }
    return <Widget>[
      const EditProfilePage(),
      const HomePage(),
      const BuddiesPage(),
    ];
  }

  List<BottomNavigationBarItem> _getNavItems(UserRole role, BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (role == UserRole.courtManager) {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: loc.profile,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_business_outlined),
          activeIcon: const Icon(Icons.add_business),
          label: loc.createCourt,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          activeIcon: const Icon(Icons.calendar_today),
          label: loc.schedule,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: loc.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.group_outlined),
          activeIcon: const Icon(Icons.group),
          label: loc.buddies,
        ),
      ];
    }
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: loc.profile,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: loc.home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.group_outlined),
        activeIcon: const Icon(Icons.group),
        label: loc.buddies,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final pages = _getPages(userState.role);
    final navItems = _getNavItems(userState.role, context);

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: navItems,
      ),
    );
  }
}
