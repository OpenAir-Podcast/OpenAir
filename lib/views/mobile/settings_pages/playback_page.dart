import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:theme_provider/theme_provider.dart';

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
  late Map playbackData;

  late String fastForwardSkipTime;
  late String rewindSkipTime;
  late String playbackSpeed;

  late String enqueuePosition;
  late bool enqueueDownloaded;
  late bool autoplayNextInQueue;
  late String smartMarkAsCompleted;
  late bool keepSkippedEpisodes;

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('playback')),
      ),
      body: playback.when(
        data: (data) {
          playbackData = data!;

          enqueueDownloaded = playbackData['enqueueDownloaded'] ??= false;
          autoplayNextInQueue = playbackData['continuePlayback'] ??= false;
          keepSkippedEpisodes = playbackData['keepSkippedEpisodes'] ??= false;

          switch (playbackData['fastForwardInterval']) {
            case '3 seconds':
              fastForwardSkipTime = Translations.of(context).text('seconds3');
              break;
            case '5 seconds':
              fastForwardSkipTime = Translations.of(context).text('seconds5');
              break;
            case '10 seconds':
              fastForwardSkipTime = Translations.of(context).text('seconds10');
              break;
            case '15 seconds':
              fastForwardSkipTime = Translations.of(context).text('seconds15');
              break;
            case '30 seconds':
              fastForwardSkipTime = Translations.of(context).text('seconds30');
              break;
            case '45 seconds':
              fastForwardSkipTime = Translations.of(context).text('seconds45');
              break;
            case '60 seconds':
              fastForwardSkipTime = Translations.of(context).text('seconds60');
              break;
            default:
              fastForwardSkipTime = Translations.of(context).text('seconds10');
              break;
          }

          switch (playbackData['rewindInterval']) {
            case '3 seconds':
              rewindSkipTime = Translations.of(context).text('seconds3');
              break;
            case '5 seconds':
              rewindSkipTime = Translations.of(context).text('seconds5');
              break;
            case '10 seconds':
              rewindSkipTime = Translations.of(context).text('seconds10');
              break;
            case '15 seconds':
              rewindSkipTime = Translations.of(context).text('seconds15');
              break;
            case '30 seconds':
              rewindSkipTime = Translations.of(context).text('seconds30');
              break;
            case '45 seconds':
              rewindSkipTime = Translations.of(context).text('seconds45');
              break;
            case '60 seconds':
              rewindSkipTime = Translations.of(context).text('seconds60');
              break;
            default:
              rewindSkipTime = Translations.of(context).text('seconds10');
              break;
          }

          switch (playbackData['playbackSpeed']) {
            case '0.25x':
              playbackSpeed = Translations.of(context).text('x0.25');
              break;
            case '0.5x':
              playbackSpeed = Translations.of(context).text('x0.5');
              break;
            case '1.0x':
              playbackSpeed = Translations.of(context).text('x1.0');
              break;
            case '1.25x':
              playbackSpeed = Translations.of(context).text('x1.25');
              break;
            case '1.5x':
              playbackSpeed = Translations.of(context).text('x1.5');
              break;
            case '2.0x':
              playbackSpeed = Translations.of(context).text('x2.0');
              break;
            default:
              playbackSpeed = Translations.of(context).text('x1.0');
              break;
          }

          switch (playbackData['enqueuePosition']) {
            case 'Last':
              enqueuePosition = Translations.of(context).text('last');
              break;
            case 'First':
              enqueuePosition = Translations.of(context).text('first');
              break;
            case 'After Current Episode':
              enqueuePosition =
                  Translations.of(context).text('afterCurrentEpisode');
              break;
            default:
              enqueuePosition = Translations.of(context).text('last');
              break;
          }

          switch (playbackData['smartMarkAsCompleted']) {
            case 'Disabled':
              smartMarkAsCompleted = Translations.of(context).text('disabled');
              break;
            case '15 seconds':
              smartMarkAsCompleted = Translations.of(context).text('seconds15');
              break;
            case '30 seconds':
              smartMarkAsCompleted = Translations.of(context).text('seconds30');
              break;
            case '60 seconds':
              smartMarkAsCompleted = Translations.of(context).text('seconds60');
              break;
            case '3 minutes':
              smartMarkAsCompleted = Translations.of(context).text('minutes3');
              break;
            case '5 minutes':
              smartMarkAsCompleted = Translations.of(context).text('minutes5');
              break;
            default:
              smartMarkAsCompleted = Translations.of(context).text('seconds30');
              break;
          }

          return Column(
            spacing: settingsSpacer,
            children: [
              ListTile(
                title: Text(
                  Translations.of(context).text('skipInterval'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title:
                    Text(Translations.of(context).text('FastfarwordSkipTime')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: fastForwardSkipTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        fastForwardSkipTime = newValue!;

                        if (Translations.of(context).text('seconds3') ==
                            newValue) {
                          playbackData['fastForwardInterval'] = '3 seconds';
                        } else if (Translations.of(context).text('seconds5') ==
                            newValue) {
                          playbackData['fastForwardInterval'] = '5 seconds';
                        } else if (Translations.of(context).text('seconds10') ==
                            newValue) {
                          playbackData['fastForwardInterval'] = '10 seconds';
                        } else if (Translations.of(context).text('seconds15') ==
                            newValue) {
                          playbackData['fastForwardInterval'] = '15 seconds';
                        } else if (Translations.of(context).text('seconds30') ==
                            newValue) {
                          playbackData['fastForwardInterval'] = '30 seconds';
                        } else if (Translations.of(context).text('seconds45') ==
                            newValue) {
                          playbackData['fastForwardInterval'] = '45 seconds';
                        } else if (Translations.of(context).text('seconds60') ==
                            newValue) {
                          playbackData['fastForwardInterval'] = '60 seconds';
                        }

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .savePlaybackSettings(playbackData);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('seconds3'),
                      Translations.of(context).text('seconds5'),
                      Translations.of(context).text('seconds10'),
                      Translations.of(context).text('seconds15'),
                      Translations.of(context).text('seconds30'),
                      Translations.of(context).text('seconds45'),
                      Translations.of(context).text('seconds60'),
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
                title: Text(Translations.of(context).text('rewindSkipTime')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: rewindSkipTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        rewindSkipTime = newValue!;

                        if (Translations.of(context).text('seconds3') ==
                            newValue) {
                          playbackData['rewindInterval'] = '3 seconds';
                        } else if (Translations.of(context).text('seconds5') ==
                            newValue) {
                          playbackData['rewindInterval'] = '5 seconds';
                        } else if (Translations.of(context).text('seconds10') ==
                            newValue) {
                          playbackData['rewindInterval'] = '10 seconds';
                        } else if (Translations.of(context).text('seconds15') ==
                            newValue) {
                          playbackData['rewindInterval'] = '15 seconds';
                        } else if (Translations.of(context).text('seconds30') ==
                            newValue) {
                          playbackData['rewindInterval'] = '30 seconds';
                        } else if (Translations.of(context).text('seconds45') ==
                            newValue) {
                          playbackData['rewindInterval'] = '45 seconds';
                        } else if (Translations.of(context).text('seconds60') ==
                            newValue) {
                          playbackData['rewindInterval'] = '60 seconds';
                        }

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .savePlaybackSettings(playbackData);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('seconds3'),
                      Translations.of(context).text('seconds5'),
                      Translations.of(context).text('seconds10'),
                      Translations.of(context).text('seconds15'),
                      Translations.of(context).text('seconds30'),
                      Translations.of(context).text('seconds45'),
                      Translations.of(context).text('seconds60'),
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
                title: Text(Translations.of(context).text('playbackSpeed')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: playbackSpeed,
                    onChanged: (String? newValue) {
                      setState(() {
                        playbackSpeed = newValue!;

                        if (Translations.of(context).text('x0.25') ==
                            newValue) {
                          playbackData['playbackSpeed'] = '0.25x';
                        } else if (Translations.of(context).text('x0.5') ==
                            newValue) {
                          playbackData['playbackSpeed'] = '0.5x';
                        } else if (Translations.of(context).text('x1.0') ==
                            newValue) {
                          playbackData['playbackSpeed'] = '1.0x';
                        } else if (Translations.of(context).text('x1.25') ==
                            newValue) {
                          playbackData['playbackSpeed'] = '1.25x';
                        } else if (Translations.of(context).text('x1.5') ==
                            newValue) {
                          playbackData['playbackSpeed'] = '1.5x';
                        } else if (Translations.of(context).text('x2.0') ==
                            newValue) {
                          playbackData['playbackSpeed'] = '2.0x';
                        }

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .savePlaybackSettings(playbackData);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('x0.25'),
                      Translations.of(context).text('x0.5'),
                      Translations.of(context).text('x1.0'),
                      Translations.of(context).text('x1.25'),
                      Translations.of(context).text('x1.5'),
                      Translations.of(context).text('x2.0'),
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
                title: Text(
                  Translations.of(context).text('queue'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('enqueuePosition')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: enqueuePosition,
                    onChanged: (String? newValue) {
                      setState(() {
                        enqueuePosition = newValue!;

                        if (Translations.of(context).text('last') == newValue) {
                          playbackData['enqueuePosition'] = 'Last';
                        } else if (Translations.of(context).text('first') ==
                            newValue) {
                          playbackData['enqueuePosition'] = 'First';
                        } else if (Translations.of(context)
                                .text('afterCurrentEpisode') ==
                            newValue) {
                          playbackData['enqueuePosition'] =
                              'After current episode';
                        }

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .savePlaybackSettings(playbackData);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('last'),
                      Translations.of(context).text('first'),
                      Translations.of(context).text('afterCurrentEpisode'),
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
                title: Text(Translations.of(context).text('enqueueDownloaded')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [enqueueDownloaded, !enqueueDownloaded],
                  onPressed: (int index) {
                    setState(() {
                      enqueueDownloaded = !enqueueDownloaded;
                      playbackData['enqueueDownloaded'] = enqueueDownloaded;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .savePlaybackSettings(playbackData);
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
                    Text(Translations.of(context).text('autoPlayNextInQueue')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [autoplayNextInQueue, !autoplayNextInQueue],
                  onPressed: (int index) {
                    setState(() {
                      autoplayNextInQueue = !autoplayNextInQueue;
                      playbackData['continuePlayback'] = autoplayNextInQueue;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .savePlaybackSettings(playbackData);
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
                title: Text(Translations.of(context)
                    .text('autoMarkEpisodesAsComppleted')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: smartMarkAsCompleted,
                    onChanged: (String? newValue) {
                      setState(() {
                        smartMarkAsCompleted = newValue!;

                        if (Translations.of(context).text('disabled') ==
                            newValue) {
                          playbackData['smartMarkAsCompleted'] = 'Disabled';
                        } else if (Translations.of(context).text('seconds15') ==
                            newValue) {
                          playbackData['smartMarkAsCompleted'] = '15 seconds';
                        } else if (Translations.of(context).text('seconds30') ==
                            newValue) {
                          playbackData['smartMarkAsCompleted'] = '30 seconds';
                        } else if (Translations.of(context).text('seconds60') ==
                            newValue) {
                          playbackData['smartMarkAsCompleted'] = '60 seconds';
                        } else if (Translations.of(context).text('minutes3') ==
                            newValue) {
                          playbackData['smartMarkAsCompleted'] = '3 minutes';
                        } else if (Translations.of(context).text('minutes5') ==
                            newValue) {
                          playbackData['smartMarkAsCompleted'] = '5 minutes';
                        }

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .savePlaybackSettings(playbackData);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('disabled'),
                      Translations.of(context).text('seconds15'),
                      Translations.of(context).text('seconds30'),
                      Translations.of(context).text('seconds60'),
                      Translations.of(context).text('minutes3'),
                      Translations.of(context).text('minutes5'),
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
                    Text(Translations.of(context).text('keepSkippedEpisodes')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [keepSkippedEpisodes, !keepSkippedEpisodes],
                  onPressed: (int index) {
                    setState(() {
                      keepSkippedEpisodes = !keepSkippedEpisodes;
                      playbackData['keepSkippedEpisodes'] = keepSkippedEpisodes;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .savePlaybackSettings(playbackData);
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
                        overflow: TextOverflow.ellipsis,
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
