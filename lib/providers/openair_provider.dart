import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/feed_model.dart';
import 'package:openair/hive_models/history_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/services/supabase_service.dart';
import 'package:openair/views/mobile/nav_pages/feeds_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

final openAirProvider = ChangeNotifierProvider<OpenAirProvider>(
  (ref) => OpenAirProvider(ref),
);

class OpenAirProvider extends ChangeNotifier {
  late StreamSubscription? mPlayerSubscription;

  late BuildContext context;

  final String storagePath = 'openair/downloads';

  Directory? directory;

  int navIndex = 1;

  late bool hasConnection;

  final Ref ref;

  OpenAirProvider(this.ref);

  late HiveService hiveService;
  late SupabaseService supabaseService;

  Future<void> initial(
    BuildContext context,
  ) async {
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    this.context = context;

    hiveService = ref.read(hiveServiceProvider);
    if (context.mounted) await hiveService.initial(context);
    supabaseService = ref.read(supabaseServiceProvider);

    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        hasConnection = false;
      } else {
        hasConnection = true;
      }
    } catch (e) {
      debugPrint(e.toString());
      hasConnection = false;
    }

    automaticDownloadQueuedEpisodes();
  }

  Future<bool> getConnectionStatus() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  void getConnectionStatusTriggered() {
    getConnectionStatus().then((value) {
      hasConnection = value;
      notifyListeners();
    });
  }

  void setNavIndex(int navIndex) {
    this.navIndex = navIndex;
    notifyListeners();
  }

  // Database Operations:
  Future<bool> isSubscribed(String podcastTitle) async {
    SubscriptionModel? resultSet =
        await hiveService.getSubscription(podcastTitle);

    if (resultSet != null) {
      return true;
    }

    return false;
  }

  Future<Map<String, SubscriptionModel>> getSubscriptions() async {
    return await hiveService.getSubscriptions();
  }

  Future<String> getSubscriptionsCount(String title) async {
    // Gets episodes count from last stored index of episodes
    int currentSubEpCount =
        await hiveService.podcastSubscribedEpisodeCount(title);

    // Gets episodes count from PodcastIndex
    try {
      int podcastEpisodeCount = await ref
          .read(podcastIndexProvider)
          .getPodcastEpisodeCountByTitle(title);

      int result = podcastEpisodeCount - currentSubEpCount;

      return result.toString();
    } on DioException catch (e) {
      debugPrint(
          'DioError getting episode count for podcast $title: ${e.message}');

      if (e.response != null) {
        debugPrint('Response: ${e.response?.data}');
      }
      return '...'; // Or some other indicator of an error
    } catch (e) {
      debugPrint('Error getting episode count for podcast $title: $e');
      return '...';
    }
  }

  Future<String> getAccumulatedSubscriptionCount() async {
    return await hiveService.podcastAccumulatedSubscribedEpisodes();
  }

  Future<String> getFeedsCount() async {
    return await hiveService.feedsCount();
  }

  Future<int> getInboxCount() async {
    return await hiveService.getNewInboxCount();
  }

  Future<String> getQueueCount() async {
    return await hiveService.queueCount();
  }

  Future<int> getDownloadsCount() async {
    return await hiveService.downloadsCount();
  }

  Future getQueue() async {
    return await hiveService.getQueue();
  }

  Future getQueueByGuid(String guid) async {
    return await hiveService.getQueueByGuid(guid);
  }

  Future<bool> isEpisodeNew(String guid) async {
    Map? resultSet = await hiveService.getEpisode(guid);

    if (resultSet != null) {
      return false;
    }

    return true;
  }

  Future<List<Map>> getSubscribedEpisodes() async {
    return hiveService.getEpisodes();
  }

  Future<List<DownloadModel>> getSortedDownloadedEpisodes() async {
    return hiveService.getSortedDownloads();
  }

  Future<List<HistoryModel>> getSortedHistory() async {
    return hiveService.getSortedHistory();
  }

  void share() {
    debugPrint('share button clicked');
  }

  void exportPodcastToOpml() async {}

  Future<void> exportToDb(String path) async {
    // Delete the database if it exists
    await deleteDatabase(path);

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE subscriptions (
            id INTEGER PRIMARY KEY,
            url TEXT,
            title TEXT,
            author TEXT,
            image TEXT,
            artwork TEXT,
            description TEXT,
            episodeCount INTEGER,
            updated_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE queue (
            guid TEXT PRIMARY KEY,
            title TEXT,
            author TEXT,
            image TEXT,
            datePublished INTEGER,
            description TEXT,
            feedUrl TEXT,
            duration TEXT,
            downloadSize TEXT,
            enclosureType TEXT,
            enclosureLength INTEGER,
            enclosureUrl TEXT,
            podcast TEXT,
            pos INTEGER,
            podcastCurrentPositionInMilliseconds REAL,
            currentPlaybackPositionString TEXT,
            currentPlaybackRemainingTimeString TEXT,
            playerPosition INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE history (
            guid TEXT PRIMARY KEY,
            image TEXT,
            title TEXT,
            author TEXT,
            datePublished INTEGER,
            description TEXT,
            feedUrl TEXT,
            duration TEXT,
            size TEXT,
            podcastId TEXT,
            enclosureLength INTEGER,
            enclosureUrl TEXT,
            playDate INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE downloads (
            guid TEXT PRIMARY KEY,
            image TEXT,
            title TEXT,
            author TEXT,
            datePublished INTEGER,
            description TEXT,
            feedUrl TEXT,
            duration INTEGER,
            size TEXT,
            podcastId INTEGER,
            enclosureLength INTEGER,
            enclosureUrl TEXT,
            downloadDate INTEGER,
            fileName TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            guid TEXT,
            title TEXT,
            author TEXT,
            image TEXT,
            datePublished INTEGER,
            description TEXT,
            feedUrl TEXT,
            duration INTEGER,
            enclosureType TEXT,
            enclosureLength INTEGER,
            enclosureUrl TEXT,
            podcast TEXT,
            size TEXT,
            podcastId TEXT,
            downloadDate INTEGER,
            fileName TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE feed (
            guid TEXT PRIMARY KEY
          )
        ''');

        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_interface TEXT,
            playback TEXT,
            automatic TEXT,
            synchronization TEXT,
            import_export TEXT,
            notifications TEXT
          )
        ''');
      },
    );

    // Export subscriptions
    final localSubscriptions = await hiveService.getSubscriptions();
    for (final sub in localSubscriptions.values) {
      await database.insert('subscriptions', sub.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Export queue
    final localQueue = await hiveService.getQueue();
    for (final item in localQueue.values) {
      final queueItem = Map<String, dynamic>.from(item);

      if (queueItem['podcast'] != null) {
        queueItem['podcast'] = jsonEncode(queueItem['podcast']);
      }

      if (queueItem['playerPosition'] is Duration) {
        queueItem['playerPosition'] =
            (queueItem['playerPosition'] as Duration).inMilliseconds;
      }

      await database.insert('queue', queueItem,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Export history
    final history = await hiveService.getHistory();

    for (final episode in history.values) {
      await database.insert('history', episode.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Export downloads
    final downloads = await hiveService.getDownloads();

    for (final episode in downloads.values) {
      final downloadItem = episode.toJson();
      downloadItem['duration'] = episode.duration.inMilliseconds;

      downloadItem['downloadDate'] =
          episode.downloadDate.millisecondsSinceEpoch;

      await database.insert('downloads', downloadItem.cast<String, Object?>(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Export favorites
    final localFavorites = await hiveService.getFavoriteEpisodes();

    for (final item in localFavorites.values) {
      final favoriteItem = {
        'guid': item['guid'],
        'title': item['title'],
        'author': item['author'],
        'image': item['image'],
        'datePublished': item['datePublished'],
        'description': item['description'],
        'feedUrl': item['feedUrl'],
        'duration': item['duration'],
        'enclosureType': item['enclosureType'],
        'enclosureLength': item['enclosureLength'],
        'enclosureUrl': item['enclosureUrl'],
        'podcast': item['podcast'],
        'size': item['size'],
        'podcastId': item['podcastId'],
        'downloadDate': item['downloadDate'],
        'fileName': item['fileName'],
      };

      if (favoriteItem['podcast'] != null) {
        favoriteItem['podcast'] = jsonEncode(favoriteItem['podcast']);
      }

      if (favoriteItem['downloadDate'] is DateTime) {
        favoriteItem['downloadDate'] =
            (favoriteItem['downloadDate'] as DateTime).millisecondsSinceEpoch;
      }

      if (favoriteItem['duration'] is Duration) {
        favoriteItem['duration'] =
            (favoriteItem['duration'] as Duration).inMilliseconds;
      }

      await database.insert('favorites', favoriteItem,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Export feed
    final localFeed = await hiveService.getFeed();

    for (final item in localFeed.values) {
      await database.insert('feed', item.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Export settings
    final userInterfaceSettings = await hiveService.getUserInterfaceSettings();
    final playbackSettings = await hiveService.getPlaybackSettings();
    final automaticSettings = await hiveService.getAutomaticSettings();
    final synchronizationSettings =
        await hiveService.getSynchronizationSettings();
    final importExport = await hiveService.getImportExportSettings();
    final notifications = await hiveService.getNotificationsSettings();

    await database.insert(
        'settings',
        {
          'user_interface': jsonEncode(userInterfaceSettings),
          'playback': jsonEncode(playbackSettings),
          'automatic': jsonEncode(automaticSettings),
          'synchronization': jsonEncode(synchronizationSettings),
          'import_export': jsonEncode(importExport),
          'notifications': jsonEncode(notifications),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    debugPrint('Database exported to $path');
  }

  Future<void> importFromDb(File file) async {
    final database = await openDatabase(
      file.path,
      version: 1,
    );

    // Import subscriptions
    final List<Map<String, dynamic>> subscriptionsMaps =
        await database.query('subscriptions');

    for (var subMap in subscriptionsMaps) {
      final mutableSubMap = Map<String, dynamic>.from(subMap);
      final subscription = SubscriptionModel.fromJson(mutableSubMap);

      await hiveService.subscribe(subscription);
      await ref.read(audioProvider).addPodcastEpisodes(subscription);
    }

    // Import queue
    final List<Map<String, dynamic>> queueMaps = await database.query('queue');
    for (var queueMap in queueMaps) {
      final item = Map<String, dynamic>.from(queueMap);
      if (item['podcast'] != null) {
        item['podcast'] = PodcastModel.fromJson(jsonDecode(item['podcast']));
      }
      if (item['playerPosition'] != null) {
        item['playerPosition'] = Duration(milliseconds: item['playerPosition']);
      }
      await hiveService.addToQueue(item);
    }

    // Import history
    final List<Map<String, dynamic>> historyMaps =
        await database.query('history');
    for (var historyMap in historyMaps) {
      final mutableHistoryMap = Map<String, dynamic>.from(historyMap);
      final history = HistoryModel.fromJson(mutableHistoryMap);
      await hiveService.addToHistory(history);
    }

    // Import downloads
    final List<Map<String, dynamic>> downloadsMaps =
        await database.query('downloads');
    for (var downloadMap in downloadsMaps) {
      final mutableDownloadMap = Map<String, dynamic>.from(downloadMap);

      mutableDownloadMap['duration'] =
          Duration(milliseconds: mutableDownloadMap['duration'] as int);

      mutableDownloadMap['downloadDate'] = DateTime.fromMillisecondsSinceEpoch(
          mutableDownloadMap['downloadDate'] as int);

      final download = DownloadModel.fromJson(mutableDownloadMap);
      await hiveService.addToDownloads(download);
    }

    // Import favorites
    final List<Map<String, dynamic>> favoritesMaps =
        await database.query('favorites');

    for (var favoriteMap in favoritesMaps) {
      final item = Map<String, dynamic>.from(favoriteMap);

      if (item['podcast'] != null) {
        final podcast =
            PodcastModel.fromJson(jsonDecode(item['podcast'] as String));

        item['podcast'] = podcast;

        hiveService.addEpisodeToFavorite(item, podcast);
      }
    }

    // Import feed
    final List<Map<String, dynamic>> feedMaps = await database.query('feed');
    for (var feedMap in feedMaps) {
      final mutableFeedMap = Map<String, dynamic>.from(feedMap);
      final feed = FeedModel.fromJson(mutableFeedMap);
      await hiveService.addToFeed(feed);
    }

    // Import settings
    final List<Map<String, dynamic>> settingsMaps =
        await database.query('settings');
    if (settingsMaps.isNotEmpty) {
      final settings = settingsMaps.first;

      final userInterfaceSettings =
          jsonDecode(settings['user_interface'] as String);
      final playbackSettings = jsonDecode(settings['playback'] as String);
      final automaticSettings = jsonDecode(settings['automatic'] as String);
      final synchronizationSettings =
          jsonDecode(settings['synchronization'] as String);
      final importExportSettings =
          jsonDecode(settings['import_export'] as String);
      final notificationsSettings =
          jsonDecode(settings['notifications'] as String);

      hiveService.saveUserInterfaceSettings(userInterfaceSettings);
      hiveService.savePlaybackSettings(playbackSettings);
      hiveService.saveAutomaticSettings(automaticSettings);
      hiveService.saveSynchronizationSettings(synchronizationSettings);
      hiveService.saveImportExportSettings(importExportSettings);
      hiveService.saveNotificationsSettings(notificationsSettings);

      // Apply settings to current config variables
      fontSizeConfig = userInterfaceSettings['fontSizeFactor'].toString();
      languageConfig = userInterfaceSettings['language'];
      localeConfig = userInterfaceSettings['locale'];

      fastForwardIntervalConfig = playbackSettings['fastForwardInterval'];
      rewindIntervalConfig = playbackSettings['rewindInterval'];
      playbackSpeedConfig = playbackSettings['playbackSpeed'];
      enqueuePositionConfig = playbackSettings['enqueuePosition'];
      enqueueDownloadedConfig = playbackSettings['enqueueDownloaded'];
      autoplayNextInQueueConfig = playbackSettings['continuePlayback'];
      smartMarkAsCompletionConfig = playbackSettings['smartMarkAsCompleted'];
      keepSkippedEpisodesConfig = playbackSettings['keepSkippedEpisodes'];

      refreshPodcastsConfig = automaticSettings['refreshPodcasts'];
      downloadNewEpisodesConfig = automaticSettings['downloadNewEpisodes'];
      downloadQueuedEpisodesConfig =
          automaticSettings['downloadQueuedEpisodes'];
      downloadEpisodeLimitConfig = automaticSettings['downloadEpisodeLimit'];
      deletePlayedEpisodesConfig = automaticSettings['deletePlayedEpisodes'];
      keepFavouriteEpisodesConfig = automaticSettings['keepFavouriteEpisodes'];

      syncFavouritesConfig = synchronizationSettings['syncFavourites'];
      syncQueueConfig = synchronizationSettings['syncQueue'];
      syncHistoryConfig = synchronizationSettings['syncHistory'];
      syncPlaybackPositionConfig =
          synchronizationSettings['syncPlaybackPosition'];
      syncSettingsConfig = synchronizationSettings['syncSettings'];

      automaticExportDatabaseConfig = importExportSettings['autoBackup'];

      receiveNotificationsForNewEpisodesConfig =
          notificationsSettings['receiveNotificationsForNewEpisodes'];
      receiveNotificationsWhenDownloadConfig =
          notificationsSettings['receiveNotificationsWhenDownloading'];
      receiveNotificationsWhenPlayConfig =
          notificationsSettings['receiveNotificationsWhenPlaying'];
    }
  }

  void updateFontSize(String size) {
    fontSizeConfig = size;
    hiveService.saveUserInterfaceSettings({
      'fontSizeFactor': fontSizeConfig,
      'language': languageConfig,
      'locale': localeConfig,
    });

    Brightness platformBrightness =
        View.of(context).platformDispatcher.platformBrightness;

    switch (themeModeConfig) {
      case 'System':
        if (platformBrightness == Brightness.dark) {
          switch (fontSizeConfig) {
            case 'small':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_small');
              break;
            case 'medium':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_medium');
              break;
            case 'large':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_large');
              break;
            case 'extraLarge':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_extra_large');
              break;
            default:
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_medium');
          }
        } else if (platformBrightness == Brightness.light) {
          switch (fontSizeConfig) {
            case 'small':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_small');
              break;
            case 'medium':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_medium');
              break;
            case 'large':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_large');
              break;
            case 'extraLarge':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_extra_large');
              break;
            default:
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_medium');
          }
        }
        break;
      case 'Light':
        switch (fontSizeConfig) {
          case 'small':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_light_small');
            break;
          case 'medium':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_light_medium');
            break;
          case 'large':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_light_large');
            break;
          case 'extraLarge':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_light_extra_large');
            break;
          default:
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_light_medium');
        }
        break;
      case 'Dark':
        switch (fontSizeConfig) {
          case 'small':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_dark_small');
            break;
          case 'medium':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_dark_medium');
            break;
          case 'large':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_dark_large');
            break;
          case 'extraLarge':
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_dark_extra_large');
            break;
          default:
            ThemeProvider.controllerOf(context)
                .setTheme('blue_accent_dark_medium');
        }
        break;
      default:
        if (platformBrightness == Brightness.dark) {
          switch (fontSizeConfig) {
            case 'small':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_small');
              break;
            case 'medium':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_medium');
              break;
            case 'large':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_large');
              break;
            case 'extraLarge':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_extra_large');
              break;
            default:
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_dark_medium');
          }
        } else if (platformBrightness == Brightness.light) {
          switch (fontSizeConfig) {
            case 'small':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_small');
              break;
            case 'medium':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_medium');
              break;
            case 'large':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_large');
              break;
            case 'extraLarge':
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_extra_large');
              break;
            default:
              ThemeProvider.controllerOf(context)
                  .setTheme('blue_accent_light_medium');
          }
        }
    }
    notifyListeners();
  }

  void downloadEnqueue(BuildContext context) async {
    Map queue = await hiveService.getQueue();

    if (queue.isEmpty) {
      return;
    }

    for (var item in queue.values) {
      item = Map<String, dynamic>.from(item);

      final isDownloaded =
          await ref.read(audioProvider).isAudioFileDownloaded(item!['guid']);

      if (!isDownloaded && context.mounted) {
        ref.read(audioProvider).downloadEpisode(
              item,
              item!['podcast'],
              context,
            );
      }
    }
  }

  void automaticDownloadQueuedEpisodes() async {
    if (downloadQueuedEpisodesConfig) {
      Map queue = await hiveService.getQueue();

      if (queue.isEmpty) {
        return;
      }

      for (var item in queue.values) {
        var itemMap = Map<String, dynamic>.from(item as Map);

        final isDownloaded = await ref
            .read(audioProvider)
            .isAudioFileDownloaded(itemMap['guid']);

        if (!isDownloaded) {
          ref.read(audioProvider).downloadEpisode(
                itemMap,
                PodcastModel.fromJson(
                    Map<String, dynamic>.from(itemMap['podcast'])),
                null,
              );
        }
      }
    }
  }

  Future<void> synchronize(BuildContext context) async {
    if (syncFavouritesConfig) {
      final user = supabaseService.client.auth.currentUser;

      if (user == null) {
        return;
      }

      // Get local subscriptions
      final localSubscriptions = await hiveService.getSubscriptions();

      // Get remote subscriptions
      final remoteSubscriptionsResponse = await supabaseService.client
          .from('subscriptions')
          .select()
          .eq('user_id', user.id);

      final remoteSubscriptions = remoteSubscriptionsResponse;

      // Sync local to remote
      for (final localSub in localSubscriptions.values) {
        remoteSubscriptions.firstWhere(
          (element) => element['podcast_id'] == localSub.id,
          orElse: () => {},
        );

        // Subscription doesn't exist remotely, so add it
        await supabaseService.client.from('subscriptions').upsert(
          {
            'user_id': user.id,
            'podcast_id': localSub.id,
            'podcast_url': localSub.feedUrl,
            'podcast_title': localSub.title,
            'podcast_author': localSub.author ?? 'Unknown',
            'podcast_image': localSub.imageUrl,
            'podcast_artwork': localSub.artwork,
            'podcast_description': localSub.description,
            'podcast_episode_count': localSub.episodeCount,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id',
        );
      }

      // Sync remote to local
      for (final remoteItem in remoteSubscriptions) {
        final podcastID = remoteItem['podcast_id'];

        if (podcastID == null) {
          continue;
        }

        final localSubscriptionItem = localSubscriptions[podcastID];

        if (localSubscriptionItem == null) {
          try {
            SubscriptionModel subscription = SubscriptionModel(
              id: remoteItem['podcast_id'],
              feedUrl: remoteItem['podcast_url'],
              title: remoteItem['podcast_title'],
              author: remoteItem['podcast_author'],
              imageUrl: remoteItem['podcast_image'],
              artwork: remoteItem['podcast_artwork'],
              description: remoteItem['podcast_description'],
              episodeCount: remoteItem['podcast_episode_count'],
              updatedAt: DateTime.parse(remoteItem['updated_at']),
            );

            await hiveService.subscribe(subscription);
            await ref.read(audioProvider).addPodcastEpisodes(subscription);
          } catch (e) {
            debugPrint('Error parsing remote subscription item: $e');
          }
        }
      }

      ref.invalidate(getFeedsProvider);
    }

    if (syncQueueConfig || syncPlaybackPositionConfig) {
      final user = supabaseService.client.auth.currentUser;

      if (user == null) {
        return;
      }

      // Fetch both local and remote queues
      final localQueue = await hiveService.getQueue();

      final remoteQueueResult = await supabaseService.client
          .from('queue')
          .select('guid')
          .eq('user_id', user.id);

      // Sync local to remote, with updated positions
      final localQueueList = List.from(localQueue.values);

      for (int i = 0; i < localQueueList.length; i++) {
        final item = Map<String, dynamic>.from(localQueueList[i]);

        await supabaseService.client.from('queue').upsert(
          {
            'user_id': user.id,
            'guid': item['guid'],
            'title': item['title'],
            'author': item['author'] ?? 'Unknown',
            'image': item['feedImage'] ?? item['image'],
            'date_published': item['datePublished'],
            'description': item['description'],
            'feed_url': item['feedUrl'],
            'duration': item['duration'],
            'download_size': item['downloadSize'],
            'enclosure_type': item['enclosureType'],
            'enclosure_length': item['enclosureLength'],
            'enclosure_url': item['enclosureUrl'],
            'podcast': item['podcast'],
            'pos': i,
            'podcast_current_position_in_milliseconds':
                item['podcastCurrentPositionInMilliseconds'],
            'current_playback_position_string':
                item['currentPlaybackPositionString'],
            'current_playback_remaining_time_string':
                item['currentPlaybackRemainingTimeString'],
            'player_position':
                (item['playerPosition'] as Duration).inMilliseconds,
          },
          onConflict: 'user_id, guid',
        );
      }

      // Sync remote to local
      hiveService.clearQueue();

      for (final remoteItem in remoteQueueResult) {
        final guid = remoteItem['guid'];

        if (guid == null) {
          continue;
        }

        final localQueueItem = localQueue[guid];

        if (localQueueItem == null) {
          try {
            final remoteFullItem = await supabaseService.client
                .from('queue')
                .select()
                .eq('user_id', user.id)
                .eq('guid', guid)
                .single();

            await hiveService.addToQueue({
              'guid': remoteFullItem['guid'],
              'title': remoteFullItem['title'],
              'author': remoteFullItem['author'],
              'image': remoteFullItem['image'],
              'datePublished': remoteFullItem['date_published'],
              'description': remoteFullItem['description'],
              'feedUrl': remoteFullItem['feed_url'],
              'duration': remoteFullItem['duration'],
              'downloadSize': remoteFullItem['download_size'],
              'enclosureType': remoteFullItem['enclosure_type'],
              'enclosureLength': remoteFullItem['enclosure_length'],
              'enclosureUrl': remoteFullItem['enclosure_url'],
              'podcast': PodcastModel.fromJson(
                  Map<String, dynamic>.from(remoteFullItem['podcast'])),
              'pos': remoteFullItem['pos'],
              'podcastCurrentPositionInMilliseconds':
                  (remoteFullItem['podcast_current_position_in_milliseconds']
                          as int)
                      .toDouble(),
              'currentPlaybackPositionString':
                  remoteFullItem['current_playback_position_string'],
              'currentPlaybackRemainingTimeString':
                  remoteFullItem['current_playback_remaining_time_string'],
              'playerPosition': Duration(
                  milliseconds: remoteFullItem['player_position'] ?? 0),
            });
          } catch (e) {
            debugPrint('Error parsing remote queue item: $e');
          }
        }
      }

      ref.invalidate(getQueueProvider);
    }

    if (syncHistoryConfig) {
      final user = supabaseService.client.auth.currentUser;

      if (user != null) {
        // Sync local to remote
        Map<String, HistoryModel> history = await hiveService.getHistory();

        for (HistoryModel episode in history.values) {
          await supabaseService.client.from('history').upsert(
            {
              'user_id': user.id,
              'guid': episode.guid,
              'image': episode.image,
              'title': episode.title,
              'author': episode.author,
              'date_published': episode.datePublished,
              'description': episode.description,
              'feed_url': episode.feedUrl,
              'duration': episode.duration,
              'size': episode.size,
              'podcast_id': episode.podcastId,
              'enclosure_length': episode.enclosureLength,
              'enclosure_url': episode.enclosureUrl,
              'play_date': episode.playDate,
            },
          );
        }

        // Sync remote to local
        final remoteHistoryResponse = await supabaseService.client
            .from('history')
            .select()
            .eq('user_id', user.id);

        final remoteHistory = remoteHistoryResponse;

        for (final remoteItem in remoteHistory) {
          final guid = remoteItem['guid'];

          if (guid == null) {
            continue;
          }

          final localHistoryItem = history[guid];

          if (localHistoryItem == null) {
            try {
              await hiveService.addToHistory(
                HistoryModel(
                  guid: guid,
                  image: remoteItem['image'],
                  title: remoteItem['title'],
                  author: remoteItem['author'],
                  datePublished: remoteItem['date_published'],
                  description: remoteItem['description'],
                  feedUrl: remoteItem['feed_url'],
                  duration: remoteItem['duration'],
                  size: remoteItem['size'],
                  podcastId: remoteItem['podcast_id'],
                  enclosureLength: remoteItem['enclosure_length'],
                  enclosureUrl: remoteItem['enclosure_url'],
                  playDate: remoteItem['play_date'],
                ),
              );
            } catch (e) {
              debugPrint('Error parsing remote history item: $e');
            }
          }
        }
      }
    }

    if (syncSettingsConfig) {
      final user = supabaseService.client.auth.currentUser;

      if (user == null) {
        return;
      }

      var i = await supabaseService.client
          .from('settings')
          .select()
          .eq('user_id', user.id);

      if (i.isEmpty) {
        // Sync local to remote
        final userInterfaceSettings =
            await hiveService.getUserInterfaceSettings();

        final playbackSettings = await hiveService.getPlaybackSettings();

        final automaticSettings = await hiveService.getAutomaticSettings();

        final synchronizationSettings =
            await hiveService.getSynchronizationSettings();

        final importExport = await hiveService.getImportExportSettings();

        final notifications = await hiveService.getNotificationsSettings();

        await supabaseService.client.from('settings').upsert(
          {
            'user_id': user.id,
            'user_interface': userInterfaceSettings,
            'playback': playbackSettings,
            'automatic': automaticSettings,
            'synchronization': synchronizationSettings,
            'import_export': importExport,
            'notifications': notifications,
          },
          onConflict: 'user_id',
        );
      }

      // Sync remote to local
      final remoteSettingsResponse = await supabaseService.client
          .from('settings')
          .select()
          .eq('user_id', user.id);

      final remoteSettings = remoteSettingsResponse[0];

      final remoteUserInterface = remoteSettings['user_interface'];
      final remotePlayback = remoteSettings['playback'];
      final remoteAutomatic = remoteSettings['automatic'];
      final remoteSynchronization = remoteSettings['synchronization'];
      final remoteImportExport = remoteSettings['import_export'];
      final remoteNotifications = remoteSettings['notifications'];

      if (remoteSettingsResponse.isEmpty) {
        hiveService.saveUserInterfaceSettings({
          'fontSizeFactor': remoteUserInterface['fontSizeFactor'],
          'language': remoteUserInterface['language'],
          'locale': remoteUserInterface['locale'],
          'voice': remoteUserInterface['voice'],
          'speechRate': remoteUserInterface['speechRate'],
          'pitch': remoteUserInterface['pitch'],
        });
      }

      Brightness platformBrightness;

      if (context.mounted) {
        platformBrightness =
            View.of(context).platformDispatcher.platformBrightness;

        switch (themeModeConfig) {
          case 'System':
            if (platformBrightness == Brightness.dark) {
              switch (fontSizeConfig) {
                case 'small':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_small');
                  break;
                case 'medium':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_medium');
                  break;
                case 'large':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_large');
                  break;
                case 'extraLarge':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_extra_large');
                  break;
                default:
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_medium');
              }
            } else if (platformBrightness == Brightness.light) {
              switch (fontSizeConfig) {
                case 'small':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_small');
                  break;
                case 'medium':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_medium');
                  break;
                case 'large':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_large');
                  break;
                case 'extraLarge':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_extra_large');
                  break;
                default:
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_medium');
              }
            }

            break;
          case 'Light':
            switch (fontSizeConfig) {
              case 'small':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_light_small');
                break;
              case 'medium':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_light_medium');
                break;
              case 'large':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_light_large');
                break;
              case 'extraLarge':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_light_extra_large');
                break;
              default:
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_light_medium');
            }

            break;
          case 'Dark':
            switch (fontSizeConfig) {
              case 'small':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_dark_small');
                break;
              case 'medium':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_dark_medium');
                break;
              case 'large':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_dark_large');
                break;
              case 'extraLarge':
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_dark_extra_large');
                break;
              default:
                ThemeProvider.controllerOf(context)
                    .setTheme('blue_accent_dark_medium');
            }

            break;
          default:
            if (platformBrightness == Brightness.dark) {
              switch (fontSizeConfig) {
                case 'small':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_small');
                  break;
                case 'medium':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_.dark_medium');
                  break;
                case 'large':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_large');
                  break;
                case 'extraLarge':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_extra_large');
                  break;
                default:
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_dark_medium');
              }
            } else if (platformBrightness == Brightness.light) {
              switch (fontSizeConfig) {
                case 'small':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_small');
                  break;
                case 'medium':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_medium');
                  break;
                case 'large':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_large');
                  break;
                case 'extraLarge':
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_extra_large');
                  break;
                default:
                  ThemeProvider.controllerOf(context)
                      .setTheme('blue_accent_light_medium');
              }
            }
        }
      }

      hiveService.savePlaybackSettings({
        'fastForwardRewindInterval':
            remotePlayback['fastForwardRewindInterval'],
        'rewindInterval': remotePlayback['rewindInterval'],
        'playbackSpeed': remotePlayback['playbackSpeed'],
        'enqueuePosition': remotePlayback['enqueuePosition'],
        'enqueueDownloaded': remotePlayback['enqueueDownloaded'],
        'continuePlayback': remotePlayback['continuePlayback'],
        'smartMarkAsCompleted': remotePlayback['smartMarkAsCompleted'],
        'keepSkippedEpisodes': remotePlayback['keepSkippedEpisodes'],
      });

      fastForwardIntervalConfig = remotePlayback['fastForwardInterval'];
      rewindIntervalConfig = remotePlayback['rewindInterval'];
      playbackSpeedConfig = remotePlayback['playbackSpeed'];
      enqueuePositionConfig = remotePlayback['enqueuePosition'];
      enqueueDownloadedConfig = remotePlayback['enqueueDownloaded'];
      autoplayNextInQueueConfig = remotePlayback['continuePlayback'];
      smartMarkAsCompletionConfig = remotePlayback['smartMarkAsCompleted'];
      keepSkippedEpisodesConfig = remotePlayback['keepSkippedEpisodes'];

      hiveService.saveAutomaticSettings({
        'refreshPodcasts': remoteAutomatic['refreshPodcasts'],
        'downloadNewEpisodes': remoteAutomatic['downloadNewEpisodes'],
        'downloadQueuedEpisodes': remoteAutomatic['downloadQueuedEpisodes'],
        'downloadEpisodeLimit': remoteAutomatic['downloadEpisodeLimit'],
        'deletePlayedEpisodes': remoteAutomatic['deletePlayedEpisodes'],
        'keepFavouriteEpisodes': remoteAutomatic['keepFavouriteEpisodes'],
      });

      refreshPodcastsConfig = remoteAutomatic['refreshPodcasts'];
      downloadNewEpisodesConfig = remoteAutomatic['downloadNewEpisodes'];
      downloadQueuedEpisodesConfig = remoteAutomatic['downloadQueuedEpisodes'];
      downloadEpisodeLimitConfig = remoteAutomatic['downloadEpisodeLimit'];
      deletePlayedEpisodesConfig = remoteAutomatic['deletePlayedEpisodes'];
      keepFavouriteEpisodesConfig = remoteAutomatic['keepFavouriteEpisodes'];

      hiveService.saveSynchronizationSettings({
        'syncFavourites': remoteSynchronization['syncFavourites'],
        'syncQueue': remoteSynchronization['syncQueue'],
        'syncHistory': remoteSynchronization['syncHistory'],
        'syncPlaybackPosition': remoteSynchronization['syncPlaybackPosition'],
        'syncSettings': remoteSynchronization['syncSettings'],
      });

      syncFavouritesConfig = remoteSynchronization['syncFavourites'];
      syncQueueConfig = remoteSynchronization['syncQueue'];
      syncHistoryConfig = remoteSynchronization['syncHistory'];
      syncPlaybackPositionConfig =
          remoteSynchronization['syncPlaybackPosition'];
      syncSettingsConfig = remoteSynchronization['syncSettings'];

      hiveService.saveImportExportSettings({
        'autoBackup': remoteImportExport['autoBackup'],
      });

      automaticExportDatabaseConfig = remoteImportExport['autoBackup'];

      hiveService.saveNotificationsSettings({
        'newEpisodes': remoteNotifications['newEpisodes'],
        'downloadedEpisodes': remoteNotifications['downloadedEpisodes'],
        'playbackStatus': remoteNotifications['playbackStatus'],
      });

      receiveNotificationsForNewEpisodesConfig =
          remoteNotifications['receiveNotificationsForNewEpisodes'];

      receiveNotificationsWhenDownloadConfig =
          remoteNotifications['receiveNotificationsWhenDownloading'];

      receiveNotificationsWhenPlayConfig =
          remoteNotifications['receiveNotificationsWhenPlaying'];
    }
  }
}
