import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:openair/config/config.dart';

import 'package:openair/hive_models/completed_episode_model.dart';
import 'package:openair/hive_models/feed_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/history_model.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';

import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/nav_pages/downloads_page.dart';
import 'package:openair/views/mobile/nav_pages/queue_page.dart';
import 'package:openair/views/mobile/settings_pages/notifications_page.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scheduled_timer/scheduled_timer.dart';
import 'package:xml/xml.dart';

final hiveServiceProvider = Provider<HiveService>(
  (ref) => HiveService(ref),
);

// StreamProvider for Subscriptions
final subscriptionsProvider =
    StreamProvider.autoDispose<Map<String, SubscriptionModel>>((ref) async* {
  final hiveService = ref.watch(hiveServiceProvider);
  final box = await hiveService.subscriptionBox;

  // Emit the initial state
  yield await box.getAllValues();
});

// FutureProvider for sorted Queue List
final getQueueProvider = StreamProvider.autoDispose(
  (ref) async* {
    final hiveService = ref.watch(hiveServiceProvider);
    yield* hiveService.getQueue().asStream();
  },
);

final sortedDownloadsProvider = StreamProvider.autoDispose<List<DownloadModel>>(
  (ref) async* {
    final hiveService = ref.watch(hiveServiceProvider);
    yield* hiveService.getSortedDownloads().asStream();
  },
);

class HiveService {
  late final BoxCollection collection;
  late final Future<CollectionBox<SubscriptionModel>> subscriptionBox;
  late final Future<CollectionBox<Map>> episodeBox;
  late final Future<CollectionBox<FeedModel>> feedBox;
  late final Future<CollectionBox<Map>> queueBox;
  late final Future<CollectionBox<DownloadModel>> downloadBox;
  late final Future<CollectionBox<HistoryModel>> historyBox;
  late final Future<CollectionBox<CompletedEpisodeModel>> completedEpisodeBox;
  late final Future<CollectionBox<Map>> settingsBox;
  late final Future<CollectionBox> persistence;

  late final Future<CollectionBox<FetchDataModel>> trendingBox;

  late final Future<CollectionBox<FetchDataModel>> topFeaturedBox;

  late final Future<CollectionBox<FetchDataModel>> categoryBox;

  late final Future<CollectionBox<Map>> favoritesBox;

  late final Directory openAirDir;

  HiveService(this.ref);
  final Ref ref;

  late ScheduledTimer refreshTimer;
  late ScheduledTimer autoExportDBTimer;

  late BuildContext context;

  final List<Map> episodesList = [];
  final List<DownloadModel> queueList = [];

  Future<void> initial(BuildContext context) async {
    // Register all adapters
    Hive.registerAdapter(PodcastModelAdapter());
    Hive.registerAdapter(FeedModelAdapter());
    Hive.registerAdapter(DownloadModelAdapter());
    Hive.registerAdapter(HistoryModelAdapter());
    Hive.registerAdapter(CompletedEpisodeModelAdapter());
    Hive.registerAdapter(SubscriptionModelAdapter());

    Hive.registerAdapter(FetchDataModelAdapter());

    // Get the application documents directory
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();

      // Create the openair directory if it doesn't exist
      openAirDir = Directory(join(appDocumentDir.path, 'OpenAir'));

      if (!await openAirDir.exists()) {
        await openAirDir.create(recursive: true);
      }
    }

    // Create a box collection
    collection = await BoxCollection.open(
      '',
      {
        'subscriptions',
        'episodes',
        'feed',
        'queue',
        'download',
        'history',
        'completed_episodes',
        'settings',
        'persistence',
        'newEpisodesCount',
        'top_featured',
        'trending',
        'category',
        'favorites',
      },
      path: kIsWeb ? null : openAirDir.path,
    );

    subscriptionBox = collection.openBox<SubscriptionModel>('subscriptions');
    episodeBox = collection.openBox<Map>('episodes');
    feedBox = collection.openBox<FeedModel>('feed');
    queueBox = collection.openBox<Map>('queue');
    downloadBox = collection.openBox<DownloadModel>('download');
    historyBox = collection.openBox<HistoryModel>('history');

    completedEpisodeBox =
        collection.openBox<CompletedEpisodeModel>('completed_episodes');

    settingsBox = collection.openBox<Map>('settings');

    persistence = collection.openBox<Map>('persistence');

    // Trending page
    trendingBox = collection.openBox<FetchDataModel>('trending');

    // Featured page
    topFeaturedBox = collection.openBox<FetchDataModel>('top_featured');

    // Category page
    categoryBox = collection.openBox<FetchDataModel>('category');

    favoritesBox = collection.openBox<Map>('favorites');

    Map<String, dynamic> playbackSettings = await getPlaybackSettings();

    themeModeConfig = await getUserInterfaceSettings()
        .then((value) => value['themeMode'] ?? 'System');

    fontSizeConfig = await getUserInterfaceSettings()
        .then((value) => value['fontSizeFactor'].toString());

    languageConfig = await getUserInterfaceSettings()
        .then((value) => value['language'] ?? 'English');

    localeConfig = await getUserInterfaceSettings()
        .then((value) => value['locale'] ?? 'en_US');

    rewindIntervalConfig =
        playbackSettings['rewindInterval'].toString().split(' ').first;

    fastForwardIntervalConfig =
        playbackSettings['fastForwardInterval'].toString().split(' ').first;

    playbackSpeedConfig = playbackSettings['playbackSpeed'];

    enqueuePositionConfig = playbackSettings['enqueuePosition'];
    enqueueDownloadedConfig = playbackSettings['enqueueDownloaded'];
    autoplayNextInQueueConfig = playbackSettings['continuePlayback'];

    switch (playbackSettings['smartMarkAsCompleted']) {
      case 'Disabled':
        smartMarkAsCompletionConfig = 'Disabled';
        break;
      case '15 seconds':
        smartMarkAsCompletionConfig = '15';
        break;
      case '30 seconds':
        smartMarkAsCompletionConfig = '30';
        break;
      case '60 seconds':
        smartMarkAsCompletionConfig = '60';
        break;
      case '180 seconds':
        smartMarkAsCompletionConfig = '180';
        break;
      case '120 seconds':
        smartMarkAsCompletionConfig = '120';
        break;
      default:
    }

    keepSkippedEpisodesConfig = playbackSettings['keepSkippedEpisodes'];

    // Automatic
    Map<String, dynamic> automaticSettings = await getAutomaticSettings();

    // refresh settings
    // Never, Every hour, Every 2 hours, Every 4 hours, Every 8 hours,
    // Every 12 hours, Every day, Every 3 days
    refreshPodcastsConfig = automaticSettings['refreshPodcasts'];
    downloadNewEpisodesConfig = automaticSettings['downloadNewEpisodes'];
    downloadQueuedEpisodesConfig = automaticSettings['downloadQueuedEpisodes'];

    // 5, 10, 25, 50, 75, 100, 500, unlimited
    downloadEpisodeLimitConfig = automaticSettings['downloadEpisodeLimit'];

    deletePlayedEpisodesConfig = automaticSettings['deletePlayedEpisodes'];
    keepFavouriteEpisodesConfig = automaticSettings['keepFavouriteEpisodes'];

    automaticExportDatabaseConfig =
        (await getImportExportSettings())?['autoBackup'] ?? true;

    receiveNotificationsWhenPlayConfig = (await getNotificationsSettings())?[
            'receiveNotificationsWhenPlaying'] ??
        true;

    receiveNotificationsWhenDownloadConfig =
        (await getNotificationsSettings())?[
                'receiveNotificationsWhenDownloading'] ??
            true;

    receiveNotificationsForNewEpisodesConfig =
        (await getNotificationsSettings())?[
                'receiveNotificationsForNewEpisodes'] ??
            true;

    Duration duration;

    switch (refreshPodcastsConfig) {
      case 'Every hour':
        duration = const Duration(hours: 1);
        break;
      case 'Every 2 hours':
        duration = const Duration(hours: 2);
        break;
      case 'Every 4 hours':
        duration = const Duration(hours: 4);
        break;
      case 'Every 8 hours':
        duration = const Duration(hours: 8);
        break;
      case 'Every 12 hours':
        duration = const Duration(hours: 12);
        break;
      case 'Every day':
        duration = const Duration(days: 1);
        break;
      case 'Every 3 days':
        duration = const Duration(days: 3);
        break;
      case 'Never':
      default:
        duration = Duration.zero;
    }

    this.context = context;

    refreshTimer = ScheduledTimer(
      id: 'refresh_timer',
      onExecute: () {
        if (refreshPodcastsConfig != 'Never') {
          updateSubscriptions();
          refreshTimer.schedule(DateTime.now().add(duration));
        } else {
          refreshTimer.clearSchedule();
        }
      },
      defaultScheduledTime: DateTime.now(),
      onMissedSchedule: () => refreshTimer.execute(),
    );

    if (refreshPodcastsConfig != 'Never') {
      refreshTimer.schedule(DateTime.now().add(duration));
    }

    // Auto Export DB every day at 2 AM
    autoExportDBTimer = ScheduledTimer(
      id: 'auto_export_db_timer',
      onExecute: () async {
        if (automaticExportDatabaseConfig) {
          final now = DateTime.now();
          final formattedDate =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

          final exportPath =
              join(openAirDir.path, 'openair_backup_$formattedDate.db');

          // await exportOpml(exportPath);
          ref.read(openAirProvider).exportToDb(exportPath);

          debugPrint('Database exported to $exportPath');

          autoExportDBTimer.schedule(
            DateTime(now.year, now.month, now.day + 1, 2, 0),
          );
        } else {
          autoExportDBTimer.clearSchedule();
        }
      },
      defaultScheduledTime: DateTime.now(),
      onMissedSchedule: () => autoExportDBTimer.execute(),
    );

    if (automaticExportDatabaseConfig) {
      autoExportDBTimer.schedule(
        DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day + 1, 2, 0),
      );
    }

    // Synchronization
    Map<String, dynamic>? synchronizationSettings =
        await getSynchronizationSettings();

    syncFavouritesConfig = synchronizationSettings['syncFavourites'];
    syncQueueConfig = synchronizationSettings['syncQueue'];
    syncHistoryConfig = synchronizationSettings['syncHistory'];
    syncPlaybackPositionConfig =
        synchronizationSettings['syncPlaybackPosition'];
    syncSettingsConfig = synchronizationSettings['syncSettings'];
  }

  // Subscription Operations:
  Future<void> subscribe(SubscriptionModel subscription) async {
    final box = await subscriptionBox;
    await box.put(
      subscription.title,
      subscription,
    );
  }

  Future<void> unsubscribe(String title) async {
    final box = await subscriptionBox;
    await box.delete(title);
  }

  Future<Map<String, SubscriptionModel>> getSubscriptions() async {
    final box = await subscriptionBox;
    return box.getAllValues();
  }

  Future<SubscriptionModel?> getSubscription(String title) async {
    final box = await subscriptionBox;
    return box.get(title);
  }

  Future<void> deleteSubscriptions() async {
    final box = await subscriptionBox;
    await box.clear();

    final feedBox = await this.feedBox;
    await feedBox.clear();

    final epiBox = await episodeBox;
    epiBox.clear();

    episodesList.clear();
  }

  Future<void> deleteSubscription(String id) async {
    final box = await subscriptionBox;
    await box.delete(id); // Add await
  }

  Future<void> updateSubscriptions() async {
    final subscriptions = await getSubscriptions();
    final episodeBox = await this.episodeBox;

    for (final subscription in subscriptions.values) {
      try {
        final response = await ref
            .read(podcastIndexProvider)
            .getEpisodesByFeedUrl(subscription.feedUrl);

        if (response.isNotEmpty) {
          final newEpisodes = response['items'];
          final currentEpisodeCount = subscription.episodeCount;

          if (newEpisodes.length > currentEpisodeCount) {
            for (final episode in newEpisodes) {
              final guid = episode['guid'];

              if (await episodeBox.get(guid) == null) {
                await episodeBox.put(guid, episode);

                if (downloadNewEpisodesConfig) {
                  final podcast = PodcastModel(
                    id: subscription.id,
                    title: subscription.title,
                    author: subscription.author,
                    feedUrl: subscription.feedUrl,
                    imageUrl: subscription.imageUrl,
                    description: subscription.description,
                    artwork: subscription.artwork,
                  );

                  // No context is available here.
                  ref
                      .read(audioProvider)
                      .downloadEpisode(episode, podcast, null);
                }
              }
            }

            subscription.episodeCount = newEpisodes.length;
            await subscribe(subscription);
          }
        }
      } catch (e) {
        debugPrint('Error updating subscription ${subscription.title}: $e');
      }
    }

    if (context.mounted) await populateInbox();
  }

  Future<void> populateInbox() async {
    final subscriptions = await getSubscriptions();
    final episodeBox = await this.episodeBox;
    final feedBox = await this.feedBox;

    for (final subscription in subscriptions.values) {
      try {
        final response = await ref
            .read(podcastIndexProvider)
            .getEpisodesByFeedUrl(subscription.feedUrl);

        if (response.isNotEmpty) {
          final newEpisodes = response['items'];

          for (final episode in newEpisodes) {
            final guid = episode['guid'];
            if (await episodeBox.get(guid) == null) {
              await episodeBox.put(guid, episode);
              await feedBox.put(guid, FeedModel(guid: guid));

              if (receiveNotificationsForNewEpisodesConfig && context.mounted) {
                if (!Platform.isAndroid && !Platform.isIOS) {
                  ref.read(notificationServiceProvider).showNotification(
                        Translations.of(context).text('newEpisodeAvailable'),
                        episode['title'],
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${Translations.of(context).text('newEpisodeAvailable')} - ${episode['title']}'),
                    ),
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error populating inbox for ${subscription.title}: $e');
      }
    }
  }

  // Episodes Operations:
  Future<void> insertEpisode(
    Map episode,
    String guid,
  ) async {
    final box = await episodeBox;
    await box.put(guid, episode);
  }

  Future<void> deleteEpisode(String guid) async {
    final box = await episodeBox;
    box.delete(guid);
  }

  Future<void> deleteEpisodes() async {
    final box = await episodeBox;
    await box.clear();
  }

  Future<List<Map>> getEpisodes() async {
    final box = await episodeBox;
    final Map<String, Map> allEpisodes = await box.getAllValues();

    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }
    // Sort the list by datePublished in descending order (newest first)
    episodesList
        .sort((a, b) => b['datePublished'].compareTo(a['datePublished']));

    return episodesList;
  }

  Future<Map?> getEpisode(String guid) async {
    final box = await episodeBox;
    return box.get(guid);
  }

  Future<Iterable<MapEntry<String, Map>>> getEpisodesForPodcast(
      String podcastId) async {
    final box = await episodeBox;
    final allEpisodes = await box.getAllValues();

    return allEpisodes.entries.where(
      (element) {
        return element.value['podcastId'] == podcastId;
      },
    );
  }

  // Feed Operations:
  Future<void> addToFeed(FeedModel feed) async {
    final box = await feedBox;
    await box.put(feed.guid, feed);
  }

  Future<void> deleteFromFeed({required String guid}) async {
    final box = await feedBox;
    await box.delete(guid);
  }

  Future<Map<String, FeedModel>> getFeed() async {
    final box = await feedBox;
    return box.getAllValues();
  }

  Future<void> deleteFeed() async {
    final box = await feedBox;
    await box.clear();
  }

  // Queue Operations:
  Future<void> addToQueue(Map queue) async {
    final box = await queueBox;
    await box.put(queue['guid'], queue);
  }

  Future<void> removeFromQueue({required String guid}) async {
    final box = await queueBox;
    await box.delete(guid);
  }

  Future<Map> getQueue() async {
    final box = await queueBox;
    return await box.getAllValues();
  }

  Future<Map?> getQueueByGuid(String guid) async {
    final box = await queueBox;
    return box.get(guid);
  }

  Future<void> clearQueue() async {
    final box = await queueBox;
    await box.clear();

    ref.invalidate(sortedProvider);
  }

  Future<void> addEpisodeToQueue(Map episode, Map podcast) async {
    final box = await queueBox;
    final currentQueue = await box.getAllValues();

    int position = 0;

    if (currentQueue.isNotEmpty) {
      // Find the maximum position in the current queue
      position = currentQueue.values
          .map<int>((e) => e['pos'] as int)
          .reduce((a, b) => a > b ? a : b);
      position += 1; // New episode goes to the end of the queue
    }

    episode['podcast'] = podcast;
    episode['pos'] = position;

    await box.put(episode['guid'], episode);
  }

// Improved reorderQueue method for HiveService
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final box = await queueBox;
    final queueMap = await box.getAllValues();

    if (queueMap.isEmpty) return;

    // Convert to list and sort by position
    final List<MapEntry<String, Map>> queueList = queueMap.entries.toList()
      ..sort(
          (a, b) => (a.value['pos'] as int).compareTo(b.value['pos'] as int));

    // Adjust newIndex as per Flutter's ReorderableListView behaviour
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Validate indices
    if (oldIndex < 0 ||
        oldIndex >= queueList.length ||
        newIndex < 0 ||
        newIndex >= queueList.length ||
        oldIndex == newIndex) {
      return; // No change needed
    }

    // Perform the reorder
    final item = queueList.removeAt(oldIndex);
    queueList.insert(newIndex, item);

    // Update positions in a transaction-like manner
    final Map<String, Map> updatedItems = {};

    for (int i = 0; i < queueList.length; i++) {
      final entry = queueList[i];
      final updatedValue = Map<String, dynamic>.from(entry.value)..['pos'] = i;
      updatedItems[entry.key] = updatedValue;
    }

    // Clear and repopulate the box
    await box.clear();

    for (final entry in updatedItems.entries) {
      await box.put(entry.key, entry.value);
    }
  }

  // Download Operations:
  Future<void> addToDownloads(DownloadModel download) async {
    final box = await downloadBox;
    await box.put(download.guid, download);
  }

  Future<Map<String, DownloadModel>> getDownloads() async {
    final box = await downloadBox;
    return box.getAllValues();
  }

  Future<List<DownloadModel>> getSortedDownloads() async {
    final box = await downloadBox;
    final Map<String, DownloadModel> allEpisodes = await box.getAllValues();

    for (final entry in allEpisodes.entries) {
      queueList.add(entry.value);
    }
    // Sort the list by datePublished in descending order (newest first)
    queueList.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));

    return queueList;
  }

  Future<List<HistoryModel>> getSortedHistory() async {
    final box = await historyBox;
    final Map<String, HistoryModel> allEpisodes = await box.getAllValues();
    final List<HistoryModel> episodesList = [];

    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }

    episodesList.sort((a, b) => b.playDate.compareTo(a.playDate));
    return episodesList;
  }

  Future<void> deleteDownload(String guid) async {
    final box = await downloadBox;
    await box.delete(guid);
    ref.invalidate(getDownloadsProvider);
  }

  Future<void> clearDownloads() async {
    final box = await downloadBox;
    await box.clear();
    queueList.clear();
    ref.invalidate(getDownloadsProvider);
  }

  // History Operations:
  Future<void> addToHistory(HistoryModel history) async {
    final box = await historyBox;
    await box.put(history.guid, history);
  }

  Future<Map<String, HistoryModel>> getHistory() async {
    final box = await historyBox;
    return box.getAllValues();
  }

  Future<void> deleteHistory({required String guid}) async {
    final box = await historyBox;
    await box.delete(guid);
  }

  Future<void> clearHistory() async {
    final box = await historyBox;
    await box.clear();
  }

  // Completed Episodes Operations:
  Future<void> addToCompletedEpisode(
      CompletedEpisodeModel completedEpisode) async {
    final box = await completedEpisodeBox;
    await box.put(completedEpisode.guid, completedEpisode);
    deletePlayedEpisode(completedEpisode.guid);
  }

  Future<void> deletePlayedEpisode(String guid) async {
    if (deletePlayedEpisodesConfig) {
      final favorites = await getFavoriteEpisodes();

      if (keepFavouriteEpisodesConfig && favorites.containsKey(guid)) {
        return; // Do not delete favorite episodes
      }

      final dBox = await downloadBox;
      final download = await dBox.get(guid);

      if (download != null) {
        final file = File(join(openAirDir.path, download.fileName));

        if (await file.exists()) {
          await file.delete();
        }

        await deleteDownload(guid);
      }
    }
  }

  Future<Map<String, CompletedEpisodeModel>> getCompletedEpisodes() async {
    final box = await completedEpisodeBox;
    return box.getAllValues();
  }

  Future<void> deleteCompletedEpisode({required String guid}) async {
    final box = await completedEpisodeBox;
    await box.delete(guid);
  }

  Future<void> clearCompletedEpisodes() async {
    final box = await completedEpisodeBox;
    await box.clear(); // Add await
  }

  // Settings Operations:
  void saveUserInterfaceSettings(Map userInterfaceSettings) async {
    final box = await settingsBox;
    await box.put('userInterface', userInterfaceSettings);
  }

  Future<Map<String, dynamic>> getUserInterfaceSettings() async {
    final box = await settingsBox;
    Map? userInterfaceSettings = await box.get('userInterface');

    if (userInterfaceSettings == null) {
      userInterfaceSettings = {
        'fontSizeFactor': 1.0,
        'language': 'English',
        'locale': 'en_US',
        'voice': 'System',
        'speechRate': 'Medium',
        'pitch': 'Medium',
      };
      await box.put('userInterface', userInterfaceSettings);
    }

    // Cast to Map<String, dynamic> before returning
    return userInterfaceSettings.cast<String, dynamic>();
  }

  // Playback
  void savePlaybackSettings(Map playbackSettings) async {
    final box = await settingsBox;
    await box.put('playback', playbackSettings);
  }

  Future<Map<String, dynamic>> getPlaybackSettings() async {
    final box = await settingsBox;
    Map? playbackSettings = await box.get('playback');

    if (playbackSettings == null) {
      playbackSettings = {
        // Playback control
        'fastForwardInterval': '10 seconds',
        'rewindInterval': '10 seconds',
        'playbackSpeed': '1.0x', // Medium

        // Queue
        'enqueuePosition': 'Last',
        'enqueueDownloaded': false,
        'continuePlayback': true,
        'smartMarkAsCompleted': '30 seconds',
        'keepSkippedEpisodes': false,
      };
      await box.put('playback', playbackSettings);
    }

    return playbackSettings.cast<String, dynamic>();
  }

  // Automatic
  void saveAutomaticSettings(Map downloadSettings) async {
    final box = await settingsBox;
    await box.put('automatic', downloadSettings);
  }

  Future<Map<String, dynamic>> getAutomaticSettings() async {
    final box = await settingsBox;
    Map? downloadSettings = await box.get('automatic');

    if (downloadSettings == null) {
      downloadSettings = {
        'refreshPodcasts': 'Never',
        'downloadNewEpisodes': true,
        'downloadQueuedEpisodes': true,
        'downloadEpisodeLimit': '25',
        //
        'deletePlayedEpisodes': true,
        "keepFavouriteEpisodes": true,
        //
        "removeEpisodesFromQueue": false,
      };

      await box.put('automatic', downloadSettings);
    }

    return downloadSettings.cast<String, dynamic>();
  }

  // Synchronization
  void saveSynchronizationSettings(Map synchronizationSettings) async {
    final box = await settingsBox;
    await box.put('synchronization', synchronizationSettings);
  }

  Future<Map<String, dynamic>> getSynchronizationSettings() async {
    final box = await settingsBox;
    Map? synchronizationSettings = await box.get('synchronization');

    if (synchronizationSettings == null) {
      synchronizationSettings = {
        'syncFavourites': true,
        'syncQueue': true,
        'syncHistory': true,
        'syncPlaybackPosition': true,
        'syncSettings': true,
      };

      await box.put('synchronization', synchronizationSettings);
    }

    return synchronizationSettings.cast<String, dynamic>();
  }

  // ImportExport
  void saveImportExportSettings(Map importExportSettings) async {
    final box = await settingsBox;
    await box.put('importExport', importExportSettings);
  }

  Future<Map<String, dynamic>?> getImportExportSettings() async {
    final box = await settingsBox;
    Map? importExportSettings = await box.get('importExport');

    if (importExportSettings == null) {
      importExportSettings = {
        'autoBackup': true,
      };

      await box.put('importExport', importExportSettings);
    }

    return importExportSettings.cast<String, dynamic>();
  }

  Future<void> importSubscriptions(File file) async {
    final box = await subscriptionBox;
    final importedCollection =
        await BoxCollection.open(file.path, {'subscriptions'});
    final importedSubscriptionBox =
        await importedCollection.openBox<SubscriptionModel>('subscriptions');
    final importedSubscriptions = await importedSubscriptionBox.getAllValues();
    for (var subscription in importedSubscriptions.entries) {
      await box.put(subscription.key, subscription.value);
    }
  }

  Future<void> importOpml(File file) async {
    final document = XmlDocument.parse(file.readAsStringSync());
    final outlines = document.findAllElements('outline');
    for (final outline in outlines) {
      final feedUrl = outline.getAttribute('xmlUrl');
      if (feedUrl != null) {
        await ref.read(audioProvider).addPodcastByRssUrl(feedUrl);
      }
    }
  }

  Future<void> exportOpml(String path) async {
    final subscriptions = await getSubscriptions();
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="no"');
    builder.element('opml', attributes: {'version': '2.0'}, nest: () {
      builder.element('head', nest: () {
        builder.element('title', nest: 'OpenAir Subscriptions');
      });
      builder.element('body', nest: () {
        for (final subscription in subscriptions.values) {
          builder.element('outline', attributes: {
            'type': 'rss',
            'text': subscription.title,
            'xmlUrl': subscription.feedUrl,
          });
        }
      });
    });
    final document = builder.buildDocument();
    final file = File(path);
    await file.writeAsString(document.toXmlString(pretty: true));
  }

  // Notifications
  void saveNotificationsSettings(Map notificationsSettings) async {
    final box = await settingsBox;
    await box.put('notifications', notificationsSettings);
  }

  Future<Map<String, dynamic>?> getNotificationsSettings() async {
    final box = await settingsBox;
    Map? notificationsSettings = await box.get('notifications');

    if (notificationsSettings == null) {
      notificationsSettings = {
        'receiveNotificationsForNewEpisodes': true,
        'receiveNotificationsWhenPlaying': true,
        'receiveNotificationsWhenDownloading': true,
      };

      await box.put('notifications', notificationsSettings);
    }

    return notificationsSettings.cast<String, dynamic>();
  }

  // Counts
  Future<int> podcastSubscribedEpisodeCount(String title) async {
    final box = await subscriptionBox;
    final SubscriptionModel? allEpisodes = await box.get(title);

    return allEpisodes!.episodeCount;
  }

  Future<String> podcastAccumulatedSubscribedEpisodes() async {
    final persistenceBox = await persistence;
    final box = await subscriptionBox;

    final Map<String, SubscriptionModel> allSubscriptions =
        await box.getAllValues();

    if (allSubscriptions.isEmpty) {
      return "0";
    }

    int totalNewEpisodes = 0;

    for (final MapEntry<String, SubscriptionModel> entry
        in allSubscriptions.entries) {
      final subscription = entry.value;
      int storedCount = subscription.episodeCount;

      try {
        int liveCountForThisFeed = await ref
            .read(podcastIndexProvider)
            .getPodcastEpisodeCountByTitle(subscription.title);

        int newEpisodesForThisFeed = liveCountForThisFeed - storedCount;
        if (newEpisodesForThisFeed > 0) {
          totalNewEpisodes += newEpisodesForThisFeed;
        }
      } on DioException catch (e) {
        debugPrint(
            'DioError fetching live episode count for subscription ${subscription.id} (${subscription.title}). This subscription will contribute 0 to the new episodes count.');
        if (e.response != null) {
          debugPrint('Response: ${e.response?.data}');
          debugPrint('Status code: ${e.response?.statusCode}');
        } else {
          debugPrint('Error sending request: ${e.message}');
        }
      } catch (e, s) {
        debugPrint(
            'Error fetching live episode count for subscription ${subscription.id} (${subscription.title}). Error: $e. Stacktrace: $s. This subscription will contribute 0 to the new episodes count.');
      }
    }

    await persistenceBox
        .put('subscriptions_count', {'total': totalNewEpisodes});
    return totalNewEpisodes.toString();
  }

  Future<int> getNewEpisodesCount() async {
    final box = await persistence;
    final Map? countData = await box.get('subscriptions_count');

    if (countData != null && countData.containsKey('total')) {
      return countData['total'] as int;
    }

    return -1;
  }

  Future<String> feedsCount() async {
    final box = await episodeBox;
    final Map<String, Map> allEpisodes = await box.getAllValues();

    int result = allEpisodes.length;
    return result.toString();
  }

  Future<int> getNewInboxCount() async {
    final box = await feedBox;
    final Map<String, FeedModel> allFeeds = await box.getAllValues();

    return allFeeds.length;
  }

  Future<String> queueCount() async {
    final box = await queueBox;
    final Map allEpisodes = await box.getAllValues();

    int result = allEpisodes.length;
    return result.toString();
  }

  Future<int> downloadsCount() async {
    final box = await downloadBox;
    final Map<String, DownloadModel> allEpisodes = await box.getAllValues();

    int result = allEpisodes.length;
    return result;
  }

  Future<int> getAccumulatedEpisodes() async {
    final box = await subscriptionBox;
    final Map<String, SubscriptionModel> allEpisodes = await box.getAllValues();

    int episodeCount = 0;

    for (final entry in allEpisodes.entries) {
      episodeCount += entry.value.episodeCount;
    }

    return episodeCount;
  }

  Future<FetchDataModel?> getTrendingPodcast() async {
    final box = await trendingBox;
    return await box.get('trending');
  }

  void putTrendingPodcast(Map<String, dynamic> data) async {
    final box = await trendingBox;
    await box.put('trending', FetchDataModel.fromJson(data));
  }

  Future<FetchDataModel?> getTopFeaturedPodcast() async {
    final box = await topFeaturedBox;
    return await box.get('top_featured');
  }

  void putTopFeaturedPodcast(Map<String, dynamic> data) async {
    final box = await topFeaturedBox;
    await box.put('top_featured', FetchDataModel.fromJson(data));
  }

  Future<FetchDataModel?> getCategoryPodcast(String category) async {
    final box = await categoryBox;
    return await box.get(category);
  }

  void putCategoryPodcast(String category, Map<String, dynamic> data) async {
    final box = await categoryBox;
    await box.put(category, FetchDataModel.fromJson(data));
  }

  void addEpisodeToFavorite(
      Map<String, dynamic> episode, PodcastModel podcast) async {
    final box = await favoritesBox;
    episode['podcast'] = podcast;
    await box.put(episode['guid'], episode);
  }

  void removeEpisodeFromFavorite(String guid) async {
    final box = await favoritesBox;
    await box.delete(guid);
  }

  Future<Map> getFavoriteEpisodes() async {
    final box = await favoritesBox;
    return await box.getAllValues();
  }

  updateEpisodePosition(String guid, Duration position) async {
    final box = await episodeBox;
    final episode = await box.get(guid);

    if (episode != null) {
      episode['position'] = position.inSeconds;
      await box.put(guid, episode);
    }
  }

  markEpisodeAsCompleted(String guid) async {
    final box = await episodeBox;
    final episode = await box.get(guid);

    if (episode != null) {
      episode['completed'] = true;
      await box.put(guid, episode);
      final completedEpisode = CompletedEpisodeModel(guid: guid);
      await addToCompletedEpisode(completedEpisode);
    }
  }
}
