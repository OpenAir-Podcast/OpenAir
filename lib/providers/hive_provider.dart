import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'package:openair/hive_models/completed_episode_model.dart';
import 'package:openair/hive_models/episode_model.dart';
import 'package:openair/hive_models/feed_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/history_model.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/openair_provider.dart';

import 'package:openair/services/podcast_index_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// StreamProvider for Subscriptions
final subscriptionsProvider =
    StreamProvider.autoDispose<Map<String, SubscriptionModel>>((ref) async* {
  final hiveService = ref.watch(openAirProvider).hiveService;
  final box = await hiveService.subscriptionBox;

  // Emit the initial state
  yield await box.getAllValues();
});

// FutureProvider for sorted Queue List
final getQueueProvider = StreamProvider.autoDispose(
  (ref) {
    final hiveService = ref.watch(openAirProvider).hiveService;
    return hiveService.getQueue().asStream();
  },
);

final sortedDownloadsProvider = StreamProvider.autoDispose<List<DownloadModel>>(
  (ref) {
    final hiveService = ref.watch(openAirProvider).hiveService;
    return hiveService.getSortedDownloads().asStream();
  },
);

class HiveService {
  late final BoxCollection collection;
  late final Future<CollectionBox<SubscriptionModel>> subscriptionBox;
  late final Future<CollectionBox<EpisodeModel>> episodeBox;
  late final Future<CollectionBox<FeedModel>> feedBox;
  late final Future<CollectionBox<Map>> queueBox;
  late final Future<CollectionBox<DownloadModel>> downloadBox;
  late final Future<CollectionBox<HistoryModel>> historyBox;
  late final Future<CollectionBox<CompletedEpisodeModel>> completedEpisodeBox;
  late final Future<CollectionBox<Map>> settingsBox;

  late final Future<CollectionBox<FetchDataModel>> trendingBox;

  late final Future<CollectionBox<FetchDataModel>> topFeaturedBox;

  late final Future<CollectionBox<FetchDataModel>> categoryBox;

  late final Directory openAirDir;

  HiveService(this.ref);
  final Ref<OpenAirProvider> ref;

  Future<void> initial() async {
    // Register all adapters
    Hive.registerAdapter(PodcastModelAdapter());
    Hive.registerAdapter(EpisodeModelAdapter());
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
        'top_featured',
        'trending',
        'category',
      },
      path: kIsWeb ? null : openAirDir.path,
    );

    subscriptionBox = collection.openBox<SubscriptionModel>('subscriptions');
    episodeBox = collection.openBox<EpisodeModel>('episodes');
    feedBox = collection.openBox<FeedModel>('feed');
    queueBox = collection.openBox<Map>('queue');
    downloadBox = collection.openBox<DownloadModel>('download');
    historyBox = collection.openBox<HistoryModel>('history');

    completedEpisodeBox =
        collection.openBox<CompletedEpisodeModel>('completed_episodes');

    settingsBox = collection.openBox<Map>('settings');

    // Trending page
    trendingBox = collection.openBox<FetchDataModel>('trending');

    // Featured page
    topFeaturedBox = collection.openBox<FetchDataModel>('top_featured');

    // Category page
    categoryBox = collection.openBox<FetchDataModel>('category');
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
    await box.clear(); // Add await
  }

  Future<void> deleteSubscription(String id) async {
    final box = await subscriptionBox;
    await box.delete(id); // Add await
  }

  // Episodes Operations:
  Future<void> insertEpisode(
    EpisodeModel episode,
    String guid,
  ) async {
    final box = await episodeBox;
    await box.put(guid, episode);
  }

  Future<void> deleteEpisode({
    required String guid,
  }) async {
    final box = await episodeBox;
    box.delete(guid);
  }

  Future<void> deleteEpisodes(String podcastId) async {
    final box = await episodeBox;

    final Map<String, EpisodeModel> allEpisodes = await box.getAllValues();
    final List<String> keysToDelete = [];

    for (final entry in allEpisodes.entries) {
      if (entry.value.podcastId == podcastId) {
        keysToDelete.add(entry.key);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await box.deleteAll(keysToDelete);
    }
  }

  Future<List<EpisodeModel>> getEpisodes() async {
    final box = await episodeBox;
    final Map<String, EpisodeModel> allEpisodes = await box.getAllValues();
    final List<EpisodeModel> episodesList = [];

    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }
    // Sort the list by datePublished in descending order (newest first)
    episodesList.sort((a, b) => b.datePublished.compareTo(a.datePublished));

    return episodesList;
  }

  Future<EpisodeModel?> getEpisode(String guid) async {
    final box = await episodeBox;
    return box.get(guid);
  }

  Future<Iterable<MapEntry<String, EpisodeModel>>> getEpisodesForPodcast(
      String podcastId) async {
    final box = await episodeBox;
    final allEpisodes = await box.getAllValues();

    return allEpisodes.entries.where(
      (element) {
        return element.value.podcastId == podcastId;
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
    await box.clear(); // Add await
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
  }

  // This should get the fetch the list then sort it in ASC order
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final box = await queueBox;
    final queueMap = await box.getAllValues();

    if (queueMap.isEmpty) return;

    // Convert to list and sort by position
    final List<MapEntry<String, Map>> queueList = queueMap.entries.toList()
      ..sort(
          (a, b) => (a.value['pos'] as int).compareTo(b.value['pos'] as int));

    // Adjust newIndex as per Flutter's ReorderableListView behavior
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Validate indices
    if (oldIndex < 0 ||
        oldIndex >= queueList.length ||
        newIndex < 0 ||
        newIndex >= queueList.length) {
      return;
    }

    // Perform the reorder
    final item = queueList.removeAt(oldIndex);
    queueList.insert(newIndex, item);

    // Update positions
    await box.clear();

    for (int i = 0; i < queueList.length; i++) {
      final entry = queueList[i];
      final updatedValue = Map<String, dynamic>.from(entry.value)..['pos'] = i;
      debugPrint('Reordered item: ${entry.key} to position $i');
      await box.put(entry.key, updatedValue);
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
    final List<DownloadModel> episodesList = [];

    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }
    // Sort the list by datePublished in descending order (newest first)
    episodesList.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));

    return episodesList;
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
  }

  Future<void> clearDownloads() async {
    final box = await downloadBox;
    await box.clear();
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

  Future<Map<String, dynamic>?> getUserInterfaceSettings() async {
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

  Future<Map<String, dynamic>?> getPlaybackSettings() async {
    final box = await settingsBox;
    Map? playbackSettings = await box.get('playback');

    if (playbackSettings == null) {
      playbackSettings = {
        // Playback control
        'fastForwardInterval': '10 seconds', // Seconds
        'rewindInterval': '10 seconds', // Seconds
        'playbackSpeed': '1.0x', // Medium

        // Queue
        'enqueuePosition': 'Last',
        'enqueueDownloaded': false,
        'continuePlayback': true,
        'smartMarkAsCompleted': '30 seconds', // Seconds
        'keepSkippedEpisodes': false,
      };
      await box.put('playback', playbackSettings);
    }

    return playbackSettings.cast<String, dynamic>();
  }

  // Downloads
  void saveDownloadSettings(Map downloadSettings) async {
    final box = await settingsBox;
    await box.put('downloads', downloadSettings);
  }

  Future<Map<String, dynamic>?> getDownloadSettings() async {
    final box = await settingsBox;
    Map? downloadSettings = await box.get('downloads');

    if (downloadSettings == null) {
      downloadSettings = {
        'refreshPodcasts': 'Never',
        'downloadNewEpisodes': true,
        'downloadQueuedEpisodes': true,
        'downloadEpisodeLimit': '25',
        //
        'deletePlayedEpisodes': true,
        "keepFavourteEpisodes": true,
        //
        "removeEpisodesFromQueue": false,
      };

      await box.put('downloads', downloadSettings);
    }

    return downloadSettings.cast<String, dynamic>();
  }

  // Synchronization
  void saveSynchronizationSettings(Map synchronizationSettings) async {
    final box = await settingsBox;
    await box.put('synchronization', synchronizationSettings);
  }

  Future<Map<String, dynamic>?> getSynchronizationSettings() async {
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
        'autoBackupFrequency': 'Daily',
      };

      await box.put('importExport', importExportSettings);
    }

    return importExportSettings.cast<String, dynamic>();
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

    return totalNewEpisodes.toString();
  }

  Future<String> feedsCount() async {
    final box = await episodeBox;
    final Map<String, EpisodeModel> allEpisodes = await box.getAllValues();

    int result = allEpisodes.length;
    return result.toString();
  }

  Future<String> queueCount() async {
    final box = await queueBox;
    final Map allEpisodes = await box.getAllValues();

    int result = allEpisodes.length;
    return result.toString();
  }

  Future<String> downloadsCount() async {
    final box = await downloadBox;
    final Map<String, DownloadModel> allEpisodes = await box.getAllValues();

    int result = allEpisodes.length;
    return result.toString();
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
}
