import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:padel_bud/presentation/pages/main_navigation_page.dart';
import 'package:padel_bud/presentation/pages/role_selection_page.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/presentation/pages/login_page.dart';
import 'package:padel_bud/core/app_localizations_delegate.dart';
import 'package:padel_bud/providers/locale_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);

    // If auth is still initializing, show loading
    if (auth.isLoading) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('he'),
        ],
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final authUser = auth.user;

    if (authUser == null) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('he'),
        ],
        title: 'PadelBud',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginPage(),
      );
    }

    // User is authenticated, now check role
    final user = ref.watch(userProvider);

    if (!user.initialized) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('he'),
        ],
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // User is authenticated but role not selected yet
    if (!user.roleSelected) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('he'),
        ],
        title: 'PadelBud',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const RoleSelectionPage(),
      );
    }

    // User is authenticated and role is selected
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('he'),
      ],
      title: 'PadelBud',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MainNavigationPage(),
    );
  }
}
