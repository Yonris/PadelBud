import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/presentation/pages/buddies_page/found_games.dart';
import 'package:padel_bud/presentation/pages/buddies_page/searching_for_game.dart';
import 'package:padel_bud/presentation/pages/buddies_page/select_time.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/providers/user_provider.dart';

class BuddiesPage extends ConsumerWidget {
  const BuddiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    Widget page = const SizedBox.shrink();

    switch (user.buddiesState) {
      case BuddiesState.notStarted:
        page = const SelectTimePage();
        break;
      case BuddiesState.searching:
        page = const SearchingForMatchPage();
        break;
      case BuddiesState.matchFound:
        page = const FoundMatchPage();
        break;
    }

    return Scaffold(body: page);
  }
}
