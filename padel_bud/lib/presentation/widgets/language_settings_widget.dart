import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_bud/core/app_localizations_ext.dart';
import 'package:padel_bud/providers/locale_provider.dart';

class LanguageSettingsWidget extends ConsumerWidget {
  const LanguageSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.language,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LanguageButton(
                label: 'English',
                isSelected: currentLocale.languageCode == 'en',
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                },
              ),
              _LanguageButton(
                label: 'עברית',
                isSelected: currentLocale.languageCode == 'he',
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('he'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
