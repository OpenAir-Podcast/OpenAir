import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';

final FutureProvider<Map?> playbackSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getPlaybackSettings();
});

class PlaybackPage extends ConsumerStatefulWidget {
  const PlaybackPage({super.key});

  @override
  ConsumerState<PlaybackPage> createState() => PlaybackPageState();
}

class PlaybackPageState extends ConsumerState<PlaybackPage> {
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
            width: 160,
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
    required bool value,
    required Function(bool) onChanged,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _savePlaybackSettings(Map playbackData, BuildContext context) {
    ref.watch(openAirProvider).hiveService.savePlaybackSettings(playbackData);
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('playback'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: playback.when(
        data: (data) {
          final playbackData = data!;

          final skipOptions = [
            '3',
            '5',
            '10',
            '15',
            '30',
            '45',
            '60',
          ];

          final speedOptions = [
            '0.5x',
            '1.0x',
            '1.25x',
            '1.5x',
            '2.0x',
          ];

          final enqueueOptions = [
            Translations.of(context).text('last'),
            Translations.of(context).text('first'),
            Translations.of(context).text('afterCurrentEpisode'),
          ];

          final smartMarkOptions = [
            Translations.of(context).text('disabled'),
            Translations.of(context).text('seconds15'),
            Translations.of(context).text('seconds30'),
            Translations.of(context).text('seconds60'),
            Translations.of(context).text('minutes3'),
            Translations.of(context).text('minutes5'),
          ];

          final storedRewind = playbackData['rewindInterval'] ?? '10 seconds';
          final storedFastForward =
              playbackData['fastForwardInterval'] ?? '10 seconds';
          final storedSpeed = playbackData['playbackSpeed'] ?? '1.0x';
          final storedEnqueue = playbackData['enqueuePosition'] ?? 'Last';
          final storedSmartMark =
              playbackData['smartMarkAsCompleted'] ?? 'Disabled';

          final enqueueDownloaded = playbackData['enqueueDownloaded'] ?? false;
          final autoplayNextInQueue = playbackData['continuePlayback'] ?? false;
          final keepSkippedEpisodes =
              playbackData['keepSkippedEpisodes'] ?? false;

          return ListView(
            children: [
              _buildSectionHeader(
                  Translations.of(context).text('skipInterval'), context),
              _buildCard(
                Column(
                  children: [
                    _buildDropdownTile(
                      label: Translations.of(context).text('rewindSkipTime'),
                      currentValue: '${storedRewind.split(' ')[0]}s',
                      options: skipOptions.map((s) => '${s}s').toList(),
                      valueMap: {
                        for (var s in skipOptions) '${s}s': '$s seconds',
                      },
                      onSave: (value) {
                        playbackData['rewindInterval'] = value;
                        rewindIntervalConfig = value.split(' ')[0];
                        _savePlaybackSettings(playbackData, context);
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
                          Translations.of(context).text('fastForwardSkipTime'),
                      currentValue: '${storedFastForward.split(' ')[0]}s',
                      options: skipOptions.map((s) => '${s}s').toList(),
                      valueMap: {
                        for (var s in skipOptions) '${s}s': '$s seconds',
                      },
                      onSave: (value) {
                        playbackData['fastForwardInterval'] = value;
                        fastForwardIntervalConfig = value.split(' ')[0];
                        _savePlaybackSettings(playbackData, context);
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
                      label: Translations.of(context).text('playbackSpeed'),
                      currentValue: storedSpeed,
                      options: speedOptions,
                      valueMap: {for (var s in speedOptions) s: s},
                      onSave: (value) {
                        playbackData['playbackSpeed'] = value;
                        playbackSpeedConfig = value;
                        _savePlaybackSettings(playbackData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader(
                  Translations.of(context).text('queue'), context),
              _buildCard(
                Column(
                  children: [
                    _buildDropdownTile(
                      label: Translations.of(context).text('enqueuePosition'),
                      currentValue: {
                        'Last': Translations.of(context).text('last'),
                        'First': Translations.of(context).text('first'),
                        'After current episode': Translations.of(context)
                            .text('afterCurrentEpisode'),
                      }[storedEnqueue]!,
                      options: enqueueOptions,
                      valueMap: {
                        Translations.of(context).text('last'): 'Last',
                        Translations.of(context).text('first'): 'First',
                        Translations.of(context).text('afterCurrentEpisode'):
                            'After current episode',
                      },
                      onSave: (value) {
                        playbackData['enqueuePosition'] = value;
                        enqueuePositionConfig = value;
                        _savePlaybackSettings(playbackData, context);
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
                      label: Translations.of(context).text('enqueueDownloaded'),
                      value: enqueueDownloaded,
                      onChanged: (value) {
                        playbackData['enqueueDownloaded'] = value;
                        enqueueDownloadedConfig = value;
                        _savePlaybackSettings(playbackData, context);
                        if (value == true) {
                          ref.watch(openAirProvider).downloadEnqueue(context);
                        }
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
                      label:
                          Translations.of(context).text('autoPlayNextInQueue'),
                      value: autoplayNextInQueue,
                      onChanged: (value) {
                        playbackData['continuePlayback'] = value;
                        autoplayNextInQueueConfig = value;
                        _savePlaybackSettings(playbackData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader(
                  Translations.of(context).text('navigation'), context),
              _buildCard(
                Column(
                  children: [
                    _buildToggleTile(
                      label: Translations.of(context)
                          .text('navigatePodcastEpisodes'),
                      value: playbackData['navigatePodcastEpisodes'] ?? true,
                      onChanged: (value) {
                        playbackData['navigatePodcastEpisodes'] = value;
                        navigatePodcastEpisodesConfig = value;
                        _savePlaybackSettings(playbackData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader(
                  Translations.of(context).text('completion'), context),
              _buildCard(
                Column(
                  children: [
                    _buildDropdownTile(
                      label: Translations.of(context)
                          .text('autoMarkEpisodesAsCompleted'),
                      currentValue: {
                        'Disabled': Translations.of(context).text('disabled'),
                        '15 seconds':
                            Translations.of(context).text('seconds15'),
                        '30 seconds':
                            Translations.of(context).text('seconds30'),
                        '60 seconds':
                            Translations.of(context).text('seconds60'),
                        '3 minutes': Translations.of(context).text('minutes3'),
                        '5 minutes': Translations.of(context).text('minutes5'),
                      }[storedSmartMark]!,
                      options: smartMarkOptions,
                      valueMap: {
                        Translations.of(context).text('disabled'): 'Disabled',
                        Translations.of(context).text('seconds15'):
                            '15 seconds',
                        Translations.of(context).text('seconds30'):
                            '30 seconds',
                        Translations.of(context).text('seconds60'):
                            '60 seconds',
                        Translations.of(context).text('minutes3'): '3 minutes',
                        Translations.of(context).text('minutes5'): '5 minutes',
                      },
                      onSave: (value) {
                        playbackData['smartMarkAsCompleted'] = value;
                        final secondsMap = {
                          'Disabled': 'Disabled',
                          '15 seconds': '15',
                          '30 seconds': '30',
                          '60 seconds': '60',
                          '3 minutes': '180',
                          '5 minutes': '300',
                        };
                        smartMarkAsCompletionConfig = secondsMap[value]!;
                        _savePlaybackSettings(playbackData, context);
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
                      label:
                          Translations.of(context).text('keepSkippedEpisodes'),
                      value: keepSkippedEpisodes,
                      onChanged: (value) {
                        playbackData['keepSkippedEpisodes'] = value;
                        keepSkippedEpisodesConfig = value;
                        _savePlaybackSettings(playbackData, context);
                        setState(() {});
                      },
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
