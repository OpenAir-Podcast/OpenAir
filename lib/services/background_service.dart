import 'package:flutter/material.dart';
import 'package:openair/env.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:crypto/crypto.dart';

const String refreshSubscriptionsTask = "refreshSubscriptionsTask";
const String dailyRefreshTask = "dailyRefreshTask";

class BackgroundPodcastService {
  final Dio _dio = Dio();
  String? _userAgent;
  final String? podcastIndexApi = Env.podcastIndexApiKey;
  final String? podcastIndexSecret = Env.podcastIndexApiSecret;
  final String? podcastIndexUserAgent = Env.podcastUserAgent;

  Future<String> _getUserAgent() async {
    if (_userAgent != null) return _userAgent!;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _userAgent =
          '$podcastIndexUserAgent/${packageInfo.version} (${packageInfo.appName})';
      return _userAgent!;
    } catch (e) {
      return podcastIndexUserAgent ?? 'OpenAir';
    }
  }

  Future<Map> getEpisodesByFeedUrl(String feedUrl) async {
    final userAgent = await _getUserAgent();
    final unixTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final hash =
        sha1.convert('$podcastIndexApi$unixTime$podcastIndexSecret'.codeUnits);
    final headers = <String, String>{
      'X-Auth-Date': unixTime,
      'X-Auth-Key': podcastIndexApi ?? '',
      'Authorization': hash.toString(),
      'User-Agent': userAgent,
    };

    try {
      final response = await _dio.get(
        'https://api.podcastindex.org/api/1.0/episodes/byfeedurl',
        queryParameters: {
          'url': feedUrl,
          'max': 10,
        },
        options: Options(headers: headers),
      );
      return response.data ?? {};
    } catch (e) {
      debugPrint('Error fetching episodes: $e');
      return {};
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

    try {
      // Initialize Hive for background isolate
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final openAirPath = join(appDocumentDir.path, 'OpenAir');

      Hive.init(openAirPath);
      Hive.registerAdapter(SubscriptionModelAdapter());

      // Open settings box to check notification preferences
      final settingsBox = await Hive.openBox('settings');
      final settings = settingsBox.get('notifications');
      final receiveNotifications =
          settings?['receiveNotificationsForNewEpisodes'] ?? true;

      if (!receiveNotifications) {
        await Hive.close();
        return Future.value(true);
      }

      // Initialize notifications
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      // Open subscriptions box
      final subscriptionBox =
          await Hive.openBox<SubscriptionModel>('subscriptions');
      final subscriptions = subscriptionBox.values.toList();

      if (subscriptions.isEmpty) {
        await Hive.close();
        return Future.value(true);
      }

      // Initialize Podcast Index service
      final podcastService = BackgroundPodcastService();

      int newEpisodesCount = 0;
      final Map<String, int> podcastNewEpisodes = {};

      for (final subscription in subscriptions) {
        try {
          final response =
              await podcastService.getEpisodesByFeedUrl(subscription.feedUrl);

          if (response.isNotEmpty && response['status'] == true) {
            final newEpisodes = response['items'] as List? ?? [];
            final currentEpisodeCount = subscription.episodeCount;

            if (newEpisodes.length > currentEpisodeCount) {
              final episodesDiff = newEpisodes.length - currentEpisodeCount;
              newEpisodesCount += episodesDiff;
              podcastNewEpisodes[subscription.title] = episodesDiff;

              // Update subscription episode count
              subscription.episodeCount = newEpisodes.length;
              await subscription.save();
            }
          }
        } catch (e) {
          debugPrint('Error checking subscription ${subscription.title}: $e');
        }
      }

      // Show notification if new episodes found
      if (newEpisodesCount > 0) {
        String title;
        String body;

        if (newEpisodesCount == 1 && podcastNewEpisodes.length == 1) {
          // Single new episode from one podcast
          final podcastTitle = podcastNewEpisodes.keys.first;
          title = podcastTitle;
          body = 'New episode available';
        } else if (podcastNewEpisodes.length == 1) {
          // Multiple new episodes from one podcast
          final podcastTitle = podcastNewEpisodes.keys.first;
          final count = podcastNewEpisodes.values.first;
          title = podcastTitle;
          body = '$count new episodes available';
        } else {
          // New episodes from multiple podcasts
          title = 'New Episodes Available';
          body =
              '$newEpisodesCount new episodes from ${podcastNewEpisodes.length} podcasts';
        }

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'openair_background_channel',
          'OpenAir Background Updates',
          channelDescription: 'Notifications for new podcast episodes',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
          macOS: iOSPlatformChannelSpecifics,
        );

        await flutterLocalNotificationsPlugin.show(
          id: DateTime.now().millisecond,
          title: title,
          body: body,
          notificationDetails: platformChannelSpecifics,
        );
      }

      await Hive.close();
      return Future.value(true);
    } catch (err) {
      debugPrint("Background task error: $err");
      await Hive.close();
      return Future.value(false);
    }
  });
}
