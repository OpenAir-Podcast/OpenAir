import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_localizations_plus/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';

import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:theme_provider/theme_provider.dart';

final FutureProvider<Map?> userInterfaceSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.getUserInterfaceSettings();
});

class UserInterface extends ConsumerStatefulWidget {
  const UserInterface({super.key});

  @override
  ConsumerState<UserInterface> createState() => _UserInterfaceState();
}

class _UserInterfaceState extends ConsumerState<UserInterface> {
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

  void _applyTheme(Map userInterface, BuildContext context, String themeMode,
      String fontSizeFactor) {
    final platformBrightness =
        View.of(context).platformDispatcher.platformBrightness;
    final effectiveTheme = themeMode == 'System'
        ? (platformBrightness == Brightness.dark ? 'Dark' : 'Light')
        : themeMode;
    final brightness = effectiveTheme == 'Dark' ? 'dark' : 'light';

    switch (fontSizeFactor) {
      case 'Small':
        ThemeProvider.controllerOf(context)
            .setTheme('blue_accent_${brightness}_small');
        break;
      case 'Medium':
        ThemeProvider.controllerOf(context)
            .setTheme('blue_accent_${brightness}_medium');
        break;
      case 'Large':
        ThemeProvider.controllerOf(context)
            .setTheme('blue_accent_${brightness}_large');
        break;
      case 'Extra Large':
        ThemeProvider.controllerOf(context)
            .setTheme('blue_accent_${brightness}_extra_large');
        break;
      default:
        ThemeProvider.controllerOf(context)
            .setTheme('blue_accent_${brightness}_medium');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userInterfaceSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('userInterface'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: settings.when(
        data: (data) {
          final userInterface = data!;

          final fontSizeFactor = userInterface['fontSizeFactor'] ?? 'Medium';
          final themeMode = userInterface['themeMode'] ?? 'System';
          final storedLanguage = userInterface['language'] ?? 'English';

          final fontSizeLabels = {
            'Small': Translations.of(context).text('small'),
            'Medium': Translations.of(context).text('medium'),
            'Large': Translations.of(context).text('large'),
            'Extra Large': Translations.of(context).text('extraLarge'),
          };

          final languageOptions = {
            "English": const Locale('en', 'US'),
            "Español": const Locale('es', 'ES'),
            "Français": const Locale('fr', 'FR'),
            "Deutsch": const Locale('de', 'DE'),
            "Italiano": const Locale('it', 'IT'),
            "Português": const Locale('pt', 'PT'),
            "Русский": const Locale('ru', 'RU'),
            "中文": const Locale('zh', 'CN'),
            "日本語": const Locale('ja', 'JP'),
            "한국어": const Locale('ko', 'KR'),
            "العربية": const Locale('ar', 'AE'),
            "עברית": const Locale('he', 'IL'),
            "Nederlands": const Locale('nl', 'NL'),
            "Svenska": const Locale('sv', 'SE'),
          };

          final languageSaveValues = {
            "English": 'English',
            "Español": 'Spanish',
            "Français": 'French',
            "Deutsch": 'German',
            "Italiano": 'Italian',
            "Português": 'Portuguese',
            "Русский": 'Russian',
            "中文": 'Chinese',
            "日本語": 'Japanese',
            "한국어": 'Korean',
            "العربية": 'Arabic',
            "עברית": 'Hebrew',
            "Nederlands": 'Dutch',
            "Svenska": 'Swedish',
          };

          final reverseLanguageSaveValues = {
            for (var entry in languageSaveValues.entries)
              entry.value: entry.key,
          };

          final displayLanguage =
              reverseLanguageSaveValues[storedLanguage] ?? storedLanguage;

          final localeStrings = {
            "English": Localization.en_US,
            "Español": Localization.es_ES,
            "Français": Localization.fr_FR,
            "Deutsch": Localization.de_DE,
            "Italiano": Localization.it_IT,
            "Português": Localization.pt_PT,
            "Русский": Localization.ru_RU,
            "中文": Localization.zh_CN,
            "日本語": Localization.ja_JP,
            "한국어": Localization.ko_KR,
            "العربية": Localization.ar_AE,
            "עברית": Localization.he_IL,
            "Nederlands": Localization.nl_NL,
            "Svenska": Localization.sv_SE,
          };

          final themeIcons = {
            'System': Icons.brightness_auto_rounded,
            'Light': Icons.light_mode_rounded,
            'Dark': Icons.dark_mode_rounded,
          };

          return Column(
            children: [
              _buildSectionHeader('appearance', context),
              _buildCard(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          Translations.of(context).text('themeMode'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ['System', 'Light', 'Dark'].map((mode) {
                          final isSelected = themeMode == mode;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _ThemeOption(
                                icon: themeIcons[mode]!,
                                label: Translations.of(context)
                                    .text(mode.toLowerCase()),
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    userInterface['themeMode'] = mode;
                                    themeModeConfig = mode;
                                    _applyTheme(userInterface, context, mode,
                                        fontSizeFactor);
                                    ref
                                        .watch(openAirProvider)
                                        .hiveService
                                        .saveUserInterfaceSettings(
                                            userInterface);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                context,
              ),
              const SizedBox(height: 16),
              _buildCard(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          Translations.of(context).text('fontSize'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Small', 'Medium', 'Large', 'Extra Large']
                            .map((size) {
                          final isSelected = fontSizeFactor == size;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: _SizeOption(
                                label: fontSizeLabels[size]!,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    userInterface['fontSizeFactor'] = size;
                                    fontSizeConfig = size;
                                    _applyTheme(userInterface, context,
                                        themeMode, size);
                                    ref
                                        .watch(openAirProvider)
                                        .hiveService
                                        .saveUserInterfaceSettings(
                                            userInterface);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                context,
              ),
              _buildSectionHeader('language', context),
              _buildCard(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          Translations.of(context).text('language'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          isExpanded: true,
                          initialValue: displayLanguage,
                          onChanged: (newValue) {
                            if (newValue == null) return;
                            final saveValue = languageSaveValues[newValue]!;
                            final localeStr = localeStrings[newValue]!;
                            final locale = languageOptions[newValue]!;

                            setState(() {
                              userInterface['language'] = saveValue;
                              userInterface['locale'] = localeStr;
                              languageConfig = saveValue;
                              localeConfig = localeStr;
                              localeSettings = localeStr;
                              onChanged = false;

                              Translations.changeLanguage(localeStr);
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(locale);

                              ref
                                  .watch(openAirProvider)
                                  .hiveService
                                  .saveUserInterfaceSettings(userInterface);
                            });
                          },
                          items: languageOptions.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                context,
              ),
              const SizedBox(height: 24),
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

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
