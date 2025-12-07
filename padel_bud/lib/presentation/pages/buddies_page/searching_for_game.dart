import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/models/user_model.dart';
import 'package:padel_bud/providers/providers.dart';
import 'package:padel_bud/providers/user_provider.dart';
import 'package:padel_bud/repositories/search_requests_repository.dart';

class SearchingForMatchPage extends ConsumerStatefulWidget {
  const SearchingForMatchPage({super.key});

  @override
  ConsumerState<SearchingForMatchPage> createState() =>
      _SearchingForMatchPageState();
}

class _SearchingForMatchPageState extends ConsumerState<SearchingForMatchPage> {
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
            AppLocalizations.of(context).findingPlayers,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.group_add,
                  color: Color(0xFF2E7D32),
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context).searchingForPlayers,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).matchingYouWithPlayers,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF2E7D32),
                  ),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final searchRequestId = ref.read(currentSearchRequestIdProvider);
                    if (searchRequestId != null) {
                      await SearchRequestsRepository().deleteSearchRequest(searchRequestId);
                      ref.read(currentSearchRequestIdProvider.notifier).state = null;
                    }
                    ref
                        .read(userProvider.notifier)
                        .setSearchingForBuddies(BuddiesState.notStarted);
                  },
                  child: Text(
                    AppLocalizations.of(context).cancelSearch,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
