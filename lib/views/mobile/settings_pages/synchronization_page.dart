import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';

final FutureProvider<Map?> synchronizationSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getSynchronizationSettings();
});

class SynchronizationPage extends ConsumerStatefulWidget {
  const SynchronizationPage({super.key});

  @override
  ConsumerState<SynchronizationPage> createState() =>
      SynchronizationPageState();
}

class SynchronizationPageState extends ConsumerState<SynchronizationPage> {
  late Map synchronizationData;

  late bool syncFavourites;
  late bool syncQueue;
  late bool syncHistory;
  late bool syncPlaybackPosition;
  late bool syncSettings;

  @override
  Widget build(BuildContext context) {
    final synchronization = ref.watch(synchronizationSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('synchronization')),
      ),
      body: synchronization.when(
        data: (data) {
          synchronizationData = data!;

          syncFavourites = synchronizationData['syncFavourites'] ?? true;
          syncQueue = synchronizationData['syncQueue'] ?? true;
          syncHistory = synchronizationData['syncHistory'] ?? true;
          syncPlaybackPosition =
              synchronizationData['syncPlaybackPosition'] ?? true;
          syncSettings = synchronizationData['syncSettings'] ?? true;

          return Column(
            spacing: settingsSpacer,
            children: [
              ListTile(
                title: Text(
                  Translations.of(context).text('synchronization'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('syncFavourites')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [syncFavourites, !syncFavourites],
                  onPressed: (int index) {
                    setState(() {
                      syncFavourites = !syncFavourites;
                      synchronizationData['syncFavourites'] = syncFavourites;

                      syncFavouritesConfig = syncFavourites;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveSynchronizationSettings(synchronizationData);
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('on'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('off'),
                      ),
                    ),
                  ],
                )),
              ),
              ListTile(
                title: Text(Translations.of(context).text('syncQueue')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [syncQueue, !syncQueue],
                  onPressed: (int index) {
                    setState(() {
                      syncQueue = !syncQueue;
                      synchronizationData['syncQueue'] = syncQueue;

                      syncQueueConfig = syncQueue;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveSynchronizationSettings(synchronizationData);
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('on'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('off'),
                      ),
                    ),
                  ],
                )),
              ),
              ListTile(
                title: Text(Translations.of(context).text('syncHistory')),
                trailing: SizedBox(
                  child: ToggleButtons(
                    isSelected: [syncHistory, !syncHistory],
                    onPressed: (int index) {
                      setState(() {
                        syncHistory = !syncHistory;
                        synchronizationData['syncHistory'] = syncHistory;

                        syncHistoryConfig = syncHistory;

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .saveSynchronizationSettings(synchronizationData);
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Translations.of(context).text('on'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Translations.of(context).text('off'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title:
                    Text(Translations.of(context).text('syncPlaybackPosition')),
                trailing: SizedBox(
                  child: ToggleButtons(
                    isSelected: [syncPlaybackPosition, !syncPlaybackPosition],
                    onPressed: (int index) {
                      setState(() {
                        syncPlaybackPosition = !syncPlaybackPosition;
                        synchronizationData['syncPlaybackPosition'] =
                            syncPlaybackPosition;

                        syncPlaybackPositionConfig = syncPlaybackPosition;

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .saveSynchronizationSettings(synchronizationData);
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Translations.of(context).text('on'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Translations.of(context).text('off'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('syncSettings')),
                trailing: SizedBox(
                  child: ToggleButtons(
                    isSelected: [syncSettings, !syncSettings],
                    onPressed: (int index) {
                      setState(() {
                        syncSettings = !syncSettings;
                        synchronizationData['syncSettings'] = syncSettings;

                        syncSettingsConfig = syncSettings;

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .saveSynchronizationSettings(synchronizationData);
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Translations.of(context).text('on'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Translations.of(context).text('off'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 60.0,
                  width: 200.0,
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).primaryColor),
                        foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary),
                      ),
                      onPressed: ref.read(openAirProvider).synchronize,
                      child: Text(
                          Translations.of(context).text('synchronizeNow'))),
                ),
              )
            ],
          );
        },
        error: (error, stackTrace) {
          return Text(Translations.of(context).text('oopsAnErrorOccurred'));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
