import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:theme_provider/theme_provider.dart';

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
  late Map downloadsData;

  late String refreshPodcasts;
  late bool downloadNewEpisodes;
  late bool downloadQueuedEpisodes;
  late String downloadEpisodeLimit;

  late bool deletePlayedEpisodes;
  late bool keepFavouriteEpisodes;

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(downloadSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('automatic')),
      ),
      body: playback.when(
        data: (data) {
          downloadsData = data!;

          downloadNewEpisodes = downloadsData['downloadNewEpisodes'] ?? true;
          downloadQueuedEpisodes =
              downloadsData['downloadQueuedEpisodes'] ?? false;

          deletePlayedEpisodes = downloadsData['deletePlayedEpisodes'] ?? false;
          keepFavouriteEpisodes =
              downloadsData['keepFavouriteEpisodes'] ?? false;

          switch (downloadsData['refreshPodcasts']) {
            case 'Never':
              refreshPodcasts = Translations.of(context).text('never');
              break;
            case 'Every hour':
              refreshPodcasts = Translations.of(context).text('everyHour');
              break;
            case 'Every 2 hours':
              refreshPodcasts = Translations.of(context).text('every2Hours');
              break;
            case 'Every 4 hours':
              refreshPodcasts = Translations.of(context).text('every4Hours');
              break;
            case 'Every 8 hours':
              refreshPodcasts = Translations.of(context).text('every8Hours');
              break;
            case 'Every 12 hours':
              refreshPodcasts = Translations.of(context).text('every12Hours');
              break;
            case 'Every day':
              refreshPodcasts = Translations.of(context).text('everyDay');
              break;
            case 'Every 3 days':
              refreshPodcasts = Translations.of(context).text('everyDay3');
              break;
            default:
              refreshPodcasts = Translations.of(context).text('never');
          }

          switch (downloadsData['downloadEpisodeLimit']) {
            case '5':
              downloadEpisodeLimit = '5';
              break;

            case '10':
              downloadEpisodeLimit = '10';
              break;

            case '25':
              downloadEpisodeLimit = '25';
              break;
            case '50':
              downloadEpisodeLimit = '50';
              break;
            case '75':
              downloadEpisodeLimit = '75';
              break;
            case '100':
              downloadEpisodeLimit = '100';
              break;
            case '500':
              downloadEpisodeLimit = '500';
              break;
            case 'Unlimited':
              downloadEpisodeLimit = Translations.of(context).text('unlimited');
              break;
            default:
              downloadEpisodeLimit = '25';
          }

          return Column(
            spacing: settingsSpacer,
            children: [
              ListTile(
                title: Text(
                  Translations.of(context).text('automatic'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('refreshPodcasts')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: refreshPodcasts,
                    onChanged: (String? newValue) {
                      setState(() {
                        refreshPodcasts = newValue!;

                        if (Translations.of(context).text('never') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Never';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .clearSchedule();
                        } else if (Translations.of(context).text('everyHour') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Every hour';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .schedule(
                                  DateTime.now().add(const Duration(hours: 1)));
                        } else if (Translations.of(context)
                                .text('every2Hours') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Every 2 hours';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .schedule(
                                  DateTime.now().add(const Duration(hours: 2)));
                        } else if (Translations.of(context)
                                .text('every4Hours') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Every 4 hours';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .schedule(
                                  DateTime.now().add(const Duration(hours: 4)));
                        } else if (Translations.of(context)
                                .text('every8Hours') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Every 8 hours';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .schedule(
                                  DateTime.now().add(const Duration(hours: 8)));
                        } else if (Translations.of(context)
                                .text('every12Hours') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Every 12 hours';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .schedule(DateTime.now()
                                  .add(const Duration(hours: 12)));
                        } else if (Translations.of(context).text('everyDay') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Every day';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .schedule(
                                  DateTime.now().add(const Duration(days: 1)));
                        } else if (Translations.of(context).text('everyDay3') ==
                            newValue) {
                          downloadsData['refreshPodcasts'] = 'Every 3 days';

                          ref
                              .read(openAirProvider)
                              .hiveService
                              .refreshTimer
                              .schedule(
                                  DateTime.now().add(const Duration(days: 3)));
                        }

                        refreshPodcastsConfig = refreshPodcasts;

                        ref
                            .read(openAirProvider)
                            .hiveService
                            .saveAutomaticSettings(downloadsData);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('never'),
                      Translations.of(context).text('everyHour'),
                      Translations.of(context).text('every2Hours'),
                      Translations.of(context).text('every4Hours'),
                      Translations.of(context).text('every8Hours'),
                      Translations.of(context).text('every12Hours'),
                      Translations.of(context).text('everyDay'),
                      Translations.of(context).text('everyDay3'),
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ListTile(
                title:
                    Text(Translations.of(context).text('downloadNewEpisodes')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [downloadNewEpisodes, !downloadNewEpisodes],
                  onPressed: (int index) {
                    setState(() {
                      downloadNewEpisodes = !downloadNewEpisodes;
                      downloadsData['downloadNewEpisodes'] =
                          downloadNewEpisodes;

                      downloadNewEpisodesConfig = downloadNewEpisodes;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveAutomaticSettings(downloadsData);
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
                title: Text(
                    Translations.of(context).text('downloadQueuedEpisodes')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [downloadQueuedEpisodes, !downloadQueuedEpisodes],
                  onPressed: (int index) {
                    setState(() {
                      downloadQueuedEpisodes = !downloadQueuedEpisodes;
                      downloadsData['downloadQueuedEpisodes'] =
                          downloadQueuedEpisodes;

                      downloadQueuedEpisodesConfig = downloadQueuedEpisodes;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveAutomaticSettings(downloadsData);
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
                title:
                    Text(Translations.of(context).text('downloadEpisodeLimit')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: downloadEpisodeLimit,
                    onChanged: (String? newValue) {
                      setState(() {
                        downloadEpisodeLimit = newValue!;

                        if ('5' == newValue) {
                          downloadsData['downloadEpisodeLimit'] = '5';
                        } else if ('10' == newValue) {
                          downloadsData['downloadEpisodeLimit'] = '10';
                        } else if ('25' == newValue) {
                          downloadsData['downloadEpisodeLimit'] = '25';
                        } else if ('50' == newValue) {
                          downloadsData['downloadEpisodeLimit'] = '50';
                        } else if ('75' == newValue) {
                          downloadsData['downloadEpisodeLimit'] = '75';
                        } else if ('100' == newValue) {
                          downloadsData['downloadEpisodeLimit'] = '100';
                        } else if ('500' == newValue) {
                          downloadsData['downloadEpisodeLimit'] = '500';
                        } else if (Translations.of(context).text('unlimited') ==
                            newValue) {
                          downloadsData['downloadEpisodeLimit'] = 'Unlimited';
                        }

                        downloadEpisodeLimitConfig = downloadEpisodeLimit;

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .saveAutomaticSettings(downloadsData);
                      });
                    },
                    items: <String>[
                      '5',
                      '10',
                      '25',
                      '50',
                      '75',
                      '100',
                      '500',
                      Translations.of(context).text('unlimited'),
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Divider(),
              ListTile(
                title:
                    Text(Translations.of(context).text('deletePlayedEpisodes')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [deletePlayedEpisodes, !deletePlayedEpisodes],
                  onPressed: (int index) {
                    setState(() {
                      deletePlayedEpisodes = !deletePlayedEpisodes;
                      downloadsData['deletePlayedEpisodes'] =
                          deletePlayedEpisodes;

                      deletePlayedEpisodesConfig = deletePlayedEpisodes;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveAutomaticSettings(downloadsData);
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
                title: Text(
                    Translations.of(context).text('keepFavouriteEpisodes')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [keepFavouriteEpisodes, !keepFavouriteEpisodes],
                  onPressed: deletePlayedEpisodes
                      ? (int index) {
                          setState(() {
                            keepFavouriteEpisodes = !keepFavouriteEpisodes;
                            downloadsData['keepFavouriteEpisodes'] =
                                keepFavouriteEpisodes;

                            keepFavouriteEpisodesConfig = keepFavouriteEpisodes;

                            ref
                                .watch(openAirProvider)
                                .hiveService
                                .saveAutomaticSettings(downloadsData);
                          });
                        }
                      : null,
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
