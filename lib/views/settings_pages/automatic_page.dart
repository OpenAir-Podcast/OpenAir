import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';

final FutureProvider<Map?> downloadSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getAutomaticSettings();
});

class AutomaticPage extends ConsumerStatefulWidget {
  const AutomaticPage({super.key});

  @override
  ConsumerState<AutomaticPage> createState() => AutomaticPageState();
}

class AutomaticPageState extends ConsumerState<AutomaticPage> {
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

  Widget _buildDropdownTile({
    required String label,
    required String currentValue,
    required List<String> options,
    required Map<String, String> valueMap,
    required Function(String) onSave,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 140,
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              isExpanded: true,
              initialValue: currentValue,
              onChanged: (newValue) {
                if (newValue == null) return;
                final internalValue = valueMap[newValue];
                if (internalValue != null) onSave(internalValue);
              },
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, textAlign: TextAlign.center),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String label,
    String? subtitle,
    required bool value,
    required Function(bool)? onChanged,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged ?? (_) {},
          ),
        ],
      ),
    );
  }

  void _saveAutomaticSettings(Map downloadsData, BuildContext context) {
    ref.watch(openAirProvider).hiveService.saveAutomaticSettings(downloadsData);
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(downloadSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('automatic'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: playback.when(
        data: (data) {
          final downloadsData = data!;

          final refreshOptions = [
            'Never',
            'Every hour',
            'Every 2 hours',
            'Every 4 hours',
            'Every 8 hours',
            'Every 12 hours',
            'Every day',
            'Every 3 days',
          ];

          final refreshScheduleMap = {
            'Never': Duration.zero,
            'Every hour': const Duration(hours: 1),
            'Every 2 hours': const Duration(hours: 2),
            'Every 4 hours': const Duration(hours: 4),
            'Every 8 hours': const Duration(hours: 8),
            'Every 12 hours': const Duration(hours: 12),
            'Every day': const Duration(days: 1),
            'Every 3 days': const Duration(days: 3),
          };

          final refreshLabels = {
            'Never': Translations.of(context).text('never'),
            'Every hour': Translations.of(context).text('everyHour'),
            'Every 2 hours': Translations.of(context).text('every2Hours'),
            'Every 4 hours': Translations.of(context).text('every4Hours'),
            'Every 8 hours': Translations.of(context).text('every8Hours'),
            'Every 12 hours': Translations.of(context).text('every12Hours'),
            'Every day': Translations.of(context).text('everyDay'),
            'Every 3 days': Translations.of(context).text('everyDay3'),
          };

          final limitOptions = [
            '5',
            '10',
            '25',
            '50',
            '75',
            '100',
            '500',
            'Unlimited',
          ];

          final limitLabels = {
            for (var l in limitOptions)
              l: l == 'Unlimited'
                  ? Translations.of(context).text('unlimited')
                  : l,
          };

          final storedRefresh = downloadsData['refreshPodcasts'] ?? 'Never';
          final storedLimit = downloadsData['downloadEpisodeLimit'] ?? '25';

          final downloadNewEpisodes =
              downloadsData['downloadNewEpisodes'] ?? true;
          final downloadQueuedEpisodes =
              downloadsData['downloadQueuedEpisodes'] ?? false;
          final deletePlayedEpisodes =
              downloadsData['deletePlayedEpisodes'] ?? false;
          final keepFavouriteEpisodes =
              downloadsData['keepFavouriteEpisodes'] ?? false;

          return ListView(
            children: [
              _buildSectionHeader(
                  Translations.of(context).text('refresh'), context),
              _buildCard(
                Column(
                  children: [
                    _buildDropdownTile(
                      label: Translations.of(context).text('refreshPodcasts'),
                      currentValue: refreshLabels[storedRefresh]!,
                      options:
                          refreshOptions.map((e) => refreshLabels[e]!).toList(),
                      valueMap: {
                        for (var option in refreshOptions)
                          refreshLabels[option]!: option,
                      },
                      onSave: (value) {
                        downloadsData['refreshPodcasts'] = value;
                        refreshPodcastsConfig = value;

                        if (value == 'Never') {
                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .clearSchedule();
                        } else {
                          final duration = refreshScheduleMap[value];
                          if (duration != null) {
                            ref
                                .read(openAirProvider)
                                .hiveService
                                .refreshTimer
                                .schedule(DateTime.now().add(duration));
                          }
                        }

                        _saveAutomaticSettings(downloadsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader(
                  Translations.of(context).text('downloads'), context),
              _buildCard(
                Column(
                  children: [
                    _buildToggleTile(
                      label:
                          Translations.of(context).text('downloadNewEpisodes'),
                      value: downloadNewEpisodes,
                      onChanged: (value) {
                        downloadsData['downloadNewEpisodes'] = value;
                        downloadNewEpisodesConfig = value;
                        _saveAutomaticSettings(downloadsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      label: Translations.of(context)
                          .text('downloadQueuedEpisodes'),
                      value: downloadQueuedEpisodes,
                      onChanged: (value) {
                        downloadsData['downloadQueuedEpisodes'] = value;
                        downloadQueuedEpisodesConfig = value;
                        _saveAutomaticSettings(downloadsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildDropdownTile(
                      label:
                          Translations.of(context).text('downloadEpisodeLimit'),
                      currentValue: limitLabels[storedLimit]!,
                      options:
                          limitOptions.map((e) => limitLabels[e]!).toList(),
                      valueMap: {
                        for (var option in limitOptions)
                          limitLabels[option]!: option,
                      },
                      onSave: (value) {
                        downloadsData['downloadEpisodeLimit'] = value;
                        downloadEpisodeLimitConfig = value;
                        _saveAutomaticSettings(downloadsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader(
                  Translations.of(context).text('cleanup'), context),
              _buildCard(
                Column(
                  children: [
                    _buildToggleTile(
                      label:
                          Translations.of(context).text('deletePlayedEpisodes'),
                      value: deletePlayedEpisodes,
                      onChanged: (value) {
                        downloadsData['deletePlayedEpisodes'] = value;
                        deletePlayedEpisodesConfig = value;
                        _saveAutomaticSettings(downloadsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      label: Translations.of(context)
                          .text('keepFavouriteEpisodes'),
                      subtitle: deletePlayedEpisodes
                          ? null
                          : Translations.of(context)
                              .text('enableDeletePlayedFirst'),
                      value:
                          deletePlayedEpisodes ? keepFavouriteEpisodes : false,
                      onChanged: deletePlayedEpisodes
                          ? (value) {
                              downloadsData['keepFavouriteEpisodes'] = value;
                              keepFavouriteEpisodesConfig = value;
                              _saveAutomaticSettings(downloadsData, context);
                              setState(() {});
                            }
                          : null,
                      context: context,
                    ),
                  ],
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
