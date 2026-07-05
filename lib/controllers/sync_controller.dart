import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/feed_model.dart';
import 'package:openair/model/hive_models/history_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

final syncControllerProvider = Provider<SyncController>(
  (ref) => SyncController(ref),
);

class SyncController extends ChangeNotifier {
  final Ref ref;

  SyncController(this.ref);

  bool hasConnection = false;

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
          playDate INTEGER,
          position INTEGER
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
    for (final episode in downloads) {
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
    try {
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
          await hiveService.addEpisodeToFavorite(item, podcast);
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
    } catch (e) {
      debugPrint('Database import failed: $e');
      rethrow;
    } finally {
      await database.close();
    }
  }

  Future<void> synchronize(BuildContext context) async {
    final hiveService = ref.read(hiveServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;

    int syncCount = 0;

    // 1. Sync Subscriptions
    if (syncFavouritesConfig) {
      try {
        final localSubscriptions = await hiveService.getSubscriptions();
        final remoteSnapshot = await db
            .collection('users')
            .doc(user.uid)
            .collection('subscriptions')
            .get();
        final remoteResponse = remoteSnapshot.docs.map((d) => d.data()).toList();

        for (final localSub in localSubscriptions.values) {
          await db
              .collection('users')
              .doc(user.uid)
              .collection('subscriptions')
              .doc(localSub.id.toString())
              .set({
            'podcast_id': localSub.id.toString(),
            'podcast_url': localSub.feedUrl,
            'podcast_title': localSub.title,
            'podcast_author': localSub.author ?? 'Unknown',
            'podcast_image': localSub.imageUrl,
            'podcast_artwork': localSub.artwork,
            'podcast_description': localSub.description,
            'podcast_episode_count': localSub.episodeCount,
            'updated_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }

        for (final remoteItem in remoteResponse) {
          final podcastID = remoteItem['podcast_id'] as String?;
          final podcastIdInt = int.tryParse(podcastID ?? '');
          if (podcastIdInt == null) continue;

          if (!localSubscriptions.containsKey(podcastIdInt.toString())) {
            try {
              final subscription = SubscriptionModel(
                id: podcastIdInt,
                feedUrl: remoteItem['podcast_url'] as String? ?? '',
                title: remoteItem['podcast_title'] as String? ?? '',
                author: remoteItem['podcast_author'] as String?,
                imageUrl: remoteItem['podcast_image'] as String? ?? '',
                artwork: remoteItem['podcast_artwork'] as String? ?? '',
                description: remoteItem['podcast_description'] as String? ?? '',
                episodeCount: remoteItem['podcast_episode_count'] as int? ?? 0,
                updatedAt: remoteItem['updated_at'] != null
                    ? DateTime.parse(remoteItem['updated_at'] as String)
                    : DateTime.now(),
              );
              await hiveService.subscribe(subscription);
            } catch (e) {
              debugPrint('Error parsing remote subscription: $e');
            }
          }
        }

        await hiveService.populateInbox();
        syncCount++;
        debugPrint('Subscriptions synced');
      } catch (e) {
        debugPrint('Error syncing subscriptions: $e');
      }
    }

    // 2. Sync History
    if (syncHistoryConfig) {
      try {
        final history = await hiveService.getHistory();
        final remoteSnapshot = await db
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .get();
        final remoteResponse = remoteSnapshot.docs.map((d) => d.data()).toList();

        for (final episode in history.values) {
          await db
              .collection('users')
              .doc(user.uid)
              .collection('history')
              .doc(episode.guid)
              .set({
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
          }, SetOptions(merge: true));
        }

        for (final remoteItem in remoteResponse) {
          final guid = remoteItem['guid'] as String?;
          if (guid == null) continue;
          if (!history.containsKey(guid)) {
            try {
              int parseInt(dynamic v) {
                if (v == null) return 0;
                if (v is int) return v;
                if (v is double) return v.toInt();
                return int.tryParse(v.toString()) ?? 0;
              }

              final historyItem = HistoryModel(
                guid: guid,
                image: remoteItem['image']?.toString() ?? '',
                title: remoteItem['title']?.toString() ?? '',
                author: remoteItem['author']?.toString(),
                datePublished: parseInt(remoteItem['date_published']),
                description: remoteItem['description']?.toString() ?? '',
                feedUrl: remoteItem['feed_url']?.toString() ?? '',
                duration: parseInt(remoteItem['duration']),
                size: remoteItem['size']?.toString() ?? '',
                podcastId: remoteItem['podcast_id']?.toString() ?? '',
                enclosureLength: parseInt(remoteItem['enclosure_length']),
                enclosureUrl: remoteItem['enclosure_url']?.toString() ?? '',
                playDate: parseInt(remoteItem['play_date']),
              );
              await hiveService.addToHistory(historyItem);
            } catch (e) {
              debugPrint('Error parsing remote history: $e');
            }
          }
        }
        syncCount++;
        debugPrint('History synced');
      } catch (e) {
        debugPrint('Error syncing history: $e');
      }
    }

    // 3. Sync Queue
    if (syncQueueConfig) {
      try {
        final localQueue = await hiveService.getQueue();
        final remoteSnapshot = await db
            .collection('users')
            .doc(user.uid)
            .collection('queue')
            .get();
        final remoteResponse = remoteSnapshot.docs.map((d) => d.data()).toList();

        for (final entry in localQueue.entries) {
          final item = Map<String, dynamic>.from(entry.value);
          final podcastJson = item['podcast'] is Map
              ? jsonEncode(item['podcast'])
              : item['podcast'];
          await db
              .collection('users')
              .doc(user.uid)
              .collection('queue')
              .doc(entry.key)
              .set({
            'guid': entry.key,
            'title': item['title'],
            'author': item['author'],
            'image': item['image'],
            'date_published': item['datePublished'],
            'description': item['description'],
            'feed_url': item['feedUrl'],
            'duration': item['duration'],
            'enclosure_type': item['enclosureType'],
            'enclosure_length': item['enclosureLength'],
            'enclosure_url': item['enclosureUrl'],
            'podcast': podcastJson,
            'pos': item['pos'],
            'updated_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }

        for (final remoteItem in remoteResponse) {
          final guid = remoteItem['guid'] as String?;
          if (guid == null || localQueue.containsKey(guid)) continue;

          final item = Map<String, dynamic>.from(remoteItem);
          if (item['podcast'] is String) {
            item['podcast'] = jsonDecode(item['podcast'] as String);
          }
          item['datePublished'] = item['date_published'];
          item['feedUrl'] = item['feed_url'];
          item['enclosureType'] = item['enclosure_type'];
          item['enclosureLength'] = item['enclosure_length'];
          item['enclosureUrl'] = item['enclosure_url'];
          await hiveService.addToQueue(item);
        }
        syncCount++;
        debugPrint('Queue synced');
      } catch (e) {
        debugPrint('Error syncing queue: $e');
      }
    }

    // 4. Sync Favorites (episode-level)
    if (syncFavouritesConfig) {
      try {
        final localFavorites = await hiveService.getFavoriteEpisodes();
        final remoteSnapshot = await db
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .get();
        final remoteResponse = remoteSnapshot.docs.map((d) => d.data()).toList();

        for (final entry in localFavorites.entries) {
          final item = Map<String, dynamic>.from(entry.value);
          final podcastJson = item['podcast'] is Map
              ? jsonEncode(item['podcast'])
              : item['podcast'];
          await db
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .doc(entry.key)
              .set({
            'guid': entry.key,
            'title': item['title'],
            'author': item['author'],
            'image': item['image'],
            'date_published': item['datePublished'],
            'description': item['description'],
            'feed_url': item['feedUrl'],
            'duration': item['duration'],
            'enclosure_type': item['enclosureType'],
            'enclosure_length': item['enclosureLength'],
            'enclosure_url': item['enclosureUrl'],
            'podcast': podcastJson,
            'updated_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }

        for (final remoteItem in remoteResponse) {
          final guid = remoteItem['guid'] as String?;
          if (guid == null || localFavorites.containsKey(guid)) continue;

          final item = Map<String, dynamic>.from(remoteItem);
          PodcastModel podcast;
          if (item['podcast'] is String) {
            podcast = PodcastModel.fromJson(jsonDecode(item['podcast'] as String));
          } else if (item['podcast'] is Map) {
            podcast = PodcastModel.fromJson(item['podcast'] as Map<String, dynamic>);
          } else {
            podcast = PodcastModel.fromJson(item);
          }
          await hiveService.addEpisodeToFavorite(item, podcast);
        }
        syncCount++;
        debugPrint('Favorites synced');
      } catch (e) {
        debugPrint('Error syncing favorites: $e');
      }
    }

    // 5. Sync Playback Positions
    if (syncPlaybackPositionConfig) {
      try {
        final episodeBox =
            await hiveService.collection.openBox<Map>('episodes');
        final localEpisodes = await episodeBox.getAllValues();
        final remoteSnapshot = await db
            .collection('users')
            .doc(user.uid)
            .collection('episode_positions')
            .get();
        final remoteResponse = remoteSnapshot.docs.map((d) => d.data()).toList();

        final remotePositions = <String, Map>{};
        for (final item in remoteResponse) {
          final guid = item['guid'] as String?;
          if (guid != null) remotePositions[guid] = item;
        }

        for (final entry in localEpisodes.entries) {
          final position = entry.value['position'];
          if (position == null) continue;

          final remoteItem = remotePositions[entry.key];
          final localUpdated = entry.value['position_updated_at'];
          final remoteUpdated = remoteItem?['updated_at'];

          bool shouldUpload = true;
          if (localUpdated != null && remoteUpdated != null) {
            shouldUpload = DateTime.parse(localUpdated as String)
                .isAfter(DateTime.parse(remoteUpdated as String));
          }

          if (shouldUpload) {
            await db
                .collection('users')
                .doc(user.uid)
                .collection('episode_positions')
                .doc(entry.key)
                .set({
              'guid': entry.key,
              'position_seconds': position,
              'updated_at': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          } else if (remoteItem != null) {
            final remotePosition = remoteItem['position_seconds'];
            if (remotePosition != null &&
                (position is int && (remotePosition as int) > position)) {
              await hiveService.updateEpisodePosition(
                entry.key,
                Duration(seconds: remotePosition),
              );
            }
          }
        }

        for (final remoteItem in remoteResponse) {
          final guid = remoteItem['guid'] as String?;
          if (guid == null || localEpisodes.containsKey(guid)) continue;
          final remotePosition = remoteItem['position_seconds'];
          if (remotePosition != null) {
            await hiveService.updateEpisodePosition(
              guid,
              Duration(seconds: remotePosition as int),
            );
          }
        }
        syncCount++;
        debugPrint('Playback positions synced');
      } catch (e) {
        debugPrint('Error syncing playback positions: $e');
      }
    }

    // 6. Sync Settings
    if (syncSettingsConfig) {
      try {
        final categories = {
          'userInterface': await hiveService.getUserInterfaceSettings(),
          'playback': await hiveService.getPlaybackSettings(),
          'automatic': await hiveService.getAutomaticSettings(),
          'synchronization': await hiveService.getSynchronizationSettings(),
          'importExport': await hiveService.getImportExportSettings(),
          'notifications': await hiveService.getNotificationsSettings(),
          'podcastLanguages': await hiveService.getPodcastLanguageSettings(),
        };

        final remoteSnapshot = await db
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .get();
        final remoteResponse = remoteSnapshot.docs.map((d) => d.data()).toList();

        final remoteSettings = <String, Map>{};
        for (final item in remoteResponse) {
          final category = item['category'] as String?;
          if (category != null) remoteSettings[category] = item;
        }

        for (final entry in categories.entries) {
          await db
              .collection('users')
              .doc(user.uid)
              .collection('settings')
              .doc(entry.key)
              .set({
            'category': entry.key,
            'data': jsonEncode(entry.value),
            'updated_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }

        for (final remoteItem in remoteResponse) {
          final category = remoteItem['category'] as String?;
          if (category == null || categories.containsKey(category)) continue;
          final data = remoteItem['data'] as String?;
          if (data == null) continue;

          final decoded = jsonDecode(data);
          switch (category) {
            case 'userInterface':
              hiveService.saveUserInterfaceSettings(decoded);
              break;
            case 'playback':
              hiveService.savePlaybackSettings(decoded);
              break;
            case 'automatic':
              hiveService.saveAutomaticSettings(decoded);
              break;
            case 'synchronization':
              hiveService.saveSynchronizationSettings(decoded);
              break;
            case 'importExport':
              hiveService.saveImportExportSettings(decoded);
              break;
            case 'notifications':
              hiveService.saveNotificationsSettings(decoded);
              break;
            case 'podcastLanguages':
              hiveService.savePodcastLanguageSettings(decoded);
              break;
          }
        }
        syncCount++;
        debugPrint('Settings synced');
      } catch (e) {
        debugPrint('Error syncing settings: $e');
      }
    }

    await hiveService.populateInbox();

    debugPrint('Synchronization complete — $syncCount categories synced');
  }
}
