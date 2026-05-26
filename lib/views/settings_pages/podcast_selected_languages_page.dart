import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';

final FutureProvider<Map?> languageSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getPodcastLanguageSettings();
});

class PodcastSelectedLanguagesPage extends ConsumerStatefulWidget {
  const PodcastSelectedLanguagesPage({super.key});

  @override
  ConsumerState<PodcastSelectedLanguagesPage> createState() =>
      LanguagePageState();
}

class LanguagePageState extends ConsumerState<PodcastSelectedLanguagesPage> {
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ar': 'العربية ',
    'he': 'עברית ',
    'nl': 'Nederlands',
    'sv': 'Svenska',
  };

  Widget _buildCard(Widget child, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }

  void _savePodcastLanguageSettings(Map languageData, BuildContext context) {
    ref
        .watch(openAirProvider)
        .hiveService
        .savePodcastLanguageSettings(languageData);
  }

  @override
  Widget build(BuildContext context) {
    final languageSettings = ref.watch(languageSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('language'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: languageSettings.when(
        data: (data) {
          final settingsData = data!;
          final List<dynamic> selectedLanguages =
              settingsData['languages'] ?? ['en'];

          return ListView(
            children: [
              _buildSectionHeader(
                Translations.of(context).text('selectLanguages'),
                context,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  '${selectedLanguages.length} ${selectedLanguages.length == 1 ? Translations.of(context).text('language') : Translations.of(context).text('languages')} selected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ),
              _buildCard(
                Column(
                  children: [
                    ...supportedLanguages.entries.toList().asMap().entries.map(
                      (entry) {
                        int index = entry.key;
                        MapEntry<String, String> languageEntry = entry.value;
                        String code = languageEntry.key;
                        String name = languageEntry.value;
                        bool isSelected = selectedLanguages.contains(code);

                        return Column(
                          children: [
                            if (index > 0)
                              Divider(
                                height: 1,
                                color: Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.15),
                              ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedLanguages.remove(code);
                                    } else {
                                      selectedLanguages.add(code);
                                    }

                                    settingsData['languages'] =
                                        selectedLanguages;

                                    _savePodcastLanguageSettings(
                                        settingsData, context);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value ?? false) {
                                              selectedLanguages.add(code);
                                            } else {
                                              selectedLanguages.remove(code);
                                            }

                                            settingsData['languages'] =
                                                selectedLanguages;

                                            _savePodcastLanguageSettings(
                                                settingsData, context);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                context,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  Translations.of(context).text('languageDescription'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(Translations.of(context).text('oopsAnErrorOccurred')),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
