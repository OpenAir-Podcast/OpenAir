import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/feed_model.dart';
import 'package:openair/hive_models/history_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

final syncControllerProvider = Provider<SyncController>(
  (ref) => SyncController(ref),
);

class SyncController extends ChangeNotifier {
  final Ref ref;

  SyncController(this.ref);

  late bool hasConnection;

  Future<void> checkConnectionStatus() async {
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
    notifyListeners();
  }

  void triggerConnectionCheck() {
    checkConnectionStatus().then((_) {
      notifyListeners();
    });
  }

  Future<void> exportDatabase(String path) async {
    await deleteDatabase(path);

    final database =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
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
    });

    final hiveService = ref.read(hiveServiceProvider);

    final localSubscriptions = await hiveService.getSubscriptions();
    for (final sub in localSubscriptions.values) {
      await database.insert('subscriptions', sub.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

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

    final history = await hiveService.getHistory();
    for (final episode in history.values) {
      await database.insert('history', episode.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final downloads = await hiveService.getDownloads();
    for (final episode in downloads.values) {
      final downloadItem = episode.toJson();
      downloadItem['duration'] = episode.duration;
      downloadItem['downloadDate'] =
          episode.downloadDate.millisecondsSinceEpoch;
      await database.insert('downloads', downloadItem.cast<String, Object?>(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

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

    final localFeed = await hiveService.getFeed();
    for (final item in localFeed.values) {
      await database.insert('feed', item.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

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

  Future<void> importDatabase(File file) async {
    final database = await openDatabase(file.path, version: 1);
    final hiveService = ref.read(hiveServiceProvider);

    final subscriptionsMaps = await database.query('subscriptions');
    for (var subMap in subscriptionsMaps) {
      final mutableSubMap = Map<String, dynamic>.from(subMap);
      final subscription = SubscriptionModel.fromJson(mutableSubMap);
      await hiveService.subscribe(subscription);
    }

    final queueMaps = await database.query('queue');
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

    final historyMaps = await database.query('history');
    for (var historyMap in historyMaps) {
      final mutableHistoryMap = Map<String, dynamic>.from(historyMap);
      final history = HistoryModel.fromJson(mutableHistoryMap);
      await hiveService.addToHistory(history);
    }

    final downloadsMaps = await database.query('downloads');
    for (var downloadMap in downloadsMaps) {
      final mutableDownloadMap = Map<String, dynamic>.from(downloadMap);
      mutableDownloadMap['duration'] =
          Duration(milliseconds: mutableDownloadMap['duration'] as int);
      mutableDownloadMap['downloadDate'] = DateTime.fromMillisecondsSinceEpoch(
          mutableDownloadMap['downloadDate'] as int);
      await hiveService
          .addToDownloads(DownloadModel.fromJson(mutableDownloadMap));
    }

    final favoritesMaps = await database.query('favorites');
    for (var favoriteMap in favoritesMaps) {
      final item = Map<String, dynamic>.from(favoriteMap);
      if (item['podcast'] != null) {
        final podcast =
            PodcastModel.fromJson(jsonDecode(item['podcast'] as String));
        item['podcast'] = podcast;
        hiveService.addEpisodeToFavorite(item, podcast);
      }
    }

    final feedMaps = await database.query('feed');
    for (var feedMap in feedMaps) {
      await hiveService
          .addToFeed(FeedModel.fromJson(Map<String, dynamic>.from(feedMap)));
    }

    final settingsMaps = await database.query('settings');
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

    debugPrint('Database imported from ${file.path}');
  }

  Future<void> synchronize(BuildContext context) async {
    final hiveService = ref.read(hiveServiceProvider);
    final supabaseService = ref.read(supabaseServiceProvider);

    if (syncFavouritesConfig) {
      final user = supabaseService.client.auth.currentUser;
      if (user == null) return;

      final localSubscriptions = await hiveService.getSubscriptions();
      final remoteSubscriptionsResponse = await supabaseService.client
          .from('subscriptions')
          .select()
          .eq('user_id', user.id);

      final remoteSubscriptions = remoteSubscriptionsResponse;

      for (final localSub in localSubscriptions.values) {
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
          onConflict: 'podcast_id',
        );
      }

      for (final remoteItem in remoteSubscriptions) {
        final podcastID = remoteItem['podcast_id'];
        if (podcastID == null) continue;

        final localSubscriptionItem = localSubscriptions[podcastID];
        if (localSubscriptionItem == null) {
          try {
            final subscription = SubscriptionModel(
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
          } catch (e) {
            debugPrint('Error parsing remote subscription item: $e');
          }
        }
      }
      debugPrint('Subscriptions synchronized');
    }

    if (syncHistoryConfig) {
      final user = supabaseService.client.auth.currentUser;
      if (user != null) {
        final history = await hiveService.getHistory();
        for (final episode in history.values) {
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
        debugPrint('History synchronized');
      }
    }

    debugPrint('Synchronization complete');
  }
}
