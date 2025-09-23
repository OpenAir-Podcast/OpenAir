import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

final FutureProvider<Map?> notificationsSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getNotificationsSettings();
});

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => NotificationsPageState();
}

class NotificationsPageState extends ConsumerState<NotificationsPage> {
  late Map notificationsData;

  late bool receiveNotificationsForNewEpisodes;
  late bool receiveNotificationsWhenPlaying;
  late bool receiveNotificationsWhenDownloading;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('notifications')),
      ),
      body: notifications.when(
        data: (data) {
          notificationsData = data!;

          receiveNotificationsForNewEpisodes =
              notificationsData['receiveNotificationsForNewEpisodes'] ??= true;
          receiveNotificationsWhenPlaying =
              notificationsData['receiveNotificationsWhenPlaying'] ??= true;
          receiveNotificationsWhenDownloading =
              notificationsData['receiveNotificationsWhenDownloading'] ??= true;

          return Column(
            spacing: settingsSpacer,
            children: [
              ListTile(
                title: Text(
                  Translations.of(context).text('alerts'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context)
                    .text('receiveNotificationsForNewEpisodes')),
                subtitle: Text(
                  Translations.of(context)
                      .text('receiveNotificationsForNewEpisodes'),
                ),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [
                    receiveNotificationsForNewEpisodes,
                    !receiveNotificationsForNewEpisodes
                  ],
                  onPressed: (int index) {
                    setState(() {
                      receiveNotificationsForNewEpisodes =
                          !receiveNotificationsForNewEpisodes;
                      notificationsData['receiveNotificationsForNewEpisodes'] =
                          receiveNotificationsForNewEpisodes;

                      receiveNotificationsForNewEpisodesConfig =
                          receiveNotificationsForNewEpisodes;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveNotificationsSettings(notificationsData);
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
                    .text('receiveNotificationsWhenPlaying')),
                subtitle: Text(
                  Translations.of(context)
                      .text('receiveNotificationsWhenPlayingSubtitle'),
                ),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [
                    receiveNotificationsWhenPlaying,
                    !receiveNotificationsWhenPlaying
                  ],
                  onPressed: (int index) {
                    setState(() {
                      receiveNotificationsWhenPlaying =
                          !receiveNotificationsWhenPlaying;
                      notificationsData['receiveNotificationsWhenPlaying'] =
                          receiveNotificationsWhenPlaying;

                      receiveNotificationsWhenPlayConfig =
                          receiveNotificationsWhenPlaying;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveNotificationsSettings(notificationsData);
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
                  Translations.of(context)
                      .text('receiveNotificationsWhenDownloading'),
                ),
                subtitle: Text(
                  Translations.of(context)
                      .text('receiveNotificationsWhenDownloadingSubtitle'),
                ),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [
                    receiveNotificationsWhenDownloading,
                    !receiveNotificationsWhenDownloading
                  ],
                  onPressed: (int index) {
                    setState(() {
                      receiveNotificationsWhenDownloading =
                          !receiveNotificationsWhenDownloading;
                      notificationsData['receiveNotificationsWhenDownloading'] =
                          receiveNotificationsWhenDownloading;

                      receiveNotificationsWhenDownloadConfig =
                          receiveNotificationsWhenDownloading;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveNotificationsSettings(notificationsData);
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
