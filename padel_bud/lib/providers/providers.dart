import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:padel_bud/providers/auth_provider.dart';
import 'package:padel_bud/providers/location_provider.dart';
import 'package:padel_bud/providers/user_provider.dart';
import 'package:padel_bud/providers/locale_provider.dart';
export 'locale_provider.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

final userProvider = NotifierProvider<UserNotifier, UserState>(
  () => UserNotifier(),
);

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  () => LocationNotifier(),
);

final currentSearchRequestIdProvider = StateProvider<String?>((ref) => null);


