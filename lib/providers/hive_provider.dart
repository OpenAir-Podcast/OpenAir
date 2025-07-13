import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'package:openair/models/completed_episode_model.dart';
import 'package:openair/models/episode_model.dart';
import 'package:openair/models/feed_model.dart';
import 'package:openair/models/podcast_model.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/models/download_model.dart';
import 'package:openair/models/history_model.dart';
import 'package:openair/models/settings_model.dart';
import 'package:openair/models/fetch_data_model.dart';
import 'package:openair/models/subscription_model.dart';

import 'package:openair/services/podcast_index_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = ChangeNotifierProvider<HiveService>(
  (ref) {
    return HiveService(ref);
  },
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
final sortedQueueListProvider = StreamProvider.autoDispose<List<QueueModel>>(
  (ref) {
    ref.watch(hiveServiceProvider);
    return ref.read(hiveServiceProvider).getSortedQueue().asStream();
  },
);

final sortedDownloadsProvider = StreamProvider.autoDispose<List<DownloadModel>>(
  (ref) {
    ref.watch(hiveServiceProvider);
    return ref.read(hiveServiceProvider).getSortedDownloads().asStream();
  },
);

class HiveService extends ChangeNotifier {
  late final BoxCollection collection;
  late final Future<CollectionBox<SubscriptionModel>> subscriptionBox;
  late final Future<CollectionBox<EpisodeModel>> episodeBox;
  late final Future<CollectionBox<FeedModel>> feedBox;
  late final Future<CollectionBox<QueueModel>> queueBox;
  late final Future<CollectionBox<DownloadModel>> downloadBox;
  late final Future<CollectionBox<HistoryModel>> historyBox;
  late final Future<CollectionBox<CompletedEpisodeModel>> completedEpisodeBox;
  late final Future<CollectionBox<SettingsModel>> settingsBox;

  late final Future<CollectionBox<PodcastModel>> topFeaturedBox;
  late final Future<CollectionBox<PodcastModel>> educationFeaturedBox;
  late final Future<CollectionBox<PodcastModel>> healthFeaturedBox;
  late final Future<CollectionBox<PodcastModel>> technologyFeaturedBox;
  late final Future<CollectionBox<PodcastModel>> sportsFeaturedBox;

  late final Future<CollectionBox<FetchDataModel>> trendingBox;

  late final Future<CollectionBox<Map<String, PodcastModel>>> categoryBox;

  bool _isInitialized = false;

  late final Directory openAirDir;

  HiveService(this.ref);
  final Ref<HiveService> ref;

  Future<void> init() async {
    if (_isInitialized) return;

    // Register all adapters
    Hive.registerAdapter(PodcastModelAdapter());
    Hive.registerAdapter(EpisodeModelAdapter());
    Hive.registerAdapter(FeedModelAdapter());
    Hive.registerAdapter(QueueModelAdapter());
    Hive.registerAdapter(DownloadModelAdapter());
    Hive.registerAdapter(HistoryModelAdapter());
    Hive.registerAdapter(CompletedEpisodeModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
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
        'education_featured',
        'health_featured',
        'technology_featured',
        'sports_featured',
        'trending',
        'category',
      },
      path: kIsWeb ? null : openAirDir.path,
    );

    subscriptionBox = collection.openBox<SubscriptionModel>('subscriptions');
    episodeBox = collection.openBox<EpisodeModel>('episodes');
    feedBox = collection.openBox<FeedModel>('feed');
    queueBox = collection.openBox<QueueModel>('queue');
    downloadBox = collection.openBox<DownloadModel>('download');
    historyBox = collection.openBox<HistoryModel>('history');
    completedEpisodeBox =
        collection.openBox<CompletedEpisodeModel>('completed_episodes');
    settingsBox = collection.openBox<SettingsModel>('settings');

    topFeaturedBox = collection.openBox<PodcastModel>('top_featured');
    educationFeaturedBox =
        collection.openBox<PodcastModel>('education_featured');
    healthFeaturedBox = collection.openBox<PodcastModel>('health_featured');
    technologyFeaturedBox =
        collection.openBox<PodcastModel>('technology_featured');
    sportsFeaturedBox = collection.openBox<PodcastModel>('sports_featured');

    trendingBox = collection.openBox('trending');

    categoryBox = collection.openBox('category');

    _isInitialized = true;
  }

  void close() async {
    // Ensure collection is initialized before closing
    if (_isInitialized) {
      collection.close();
    }
  }

  // Subscription Operations:
  Future<void> subscribe(SubscriptionModel subscription) async {
    final box = await subscriptionBox;
    await box.put(
      subscription.title,
      subscription,
    );

    notifyListeners();
  }

  Future<void> unsubscribe(String id) async {
    final box = await subscriptionBox;
    await box.delete(id);
    notifyListeners();
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
  Future<void> addToQueue(QueueModel queue, {bool notify = true}) async {
    final box = await queueBox;
    await box.put(queue.guid, queue);
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> removeFromQueue({required String guid}) async {
    final box = await queueBox;
    final queueList = await getSortedQueue();
    final newQueueList = queueList.where((item) => item.guid != guid).toList();
    await box.clear();

    for (var item in newQueueList) {
      await box.put(item.guid, item);
    }

    notifyListeners();
  }

  Future<List<QueueModel>> getSortedQueue() async {
    final box = await queueBox;
    final List<QueueModel> queueList = [];
    final Map<String, QueueModel> allKeys = await box.getAllValues();

    for (final entry in allKeys.entries) {
      queueList.add(entry.value);
    }

    // Sort the list by datePublished in descending order (newest first)
    try {
      queueList.sort((a, b) => a.pos.compareTo(b.pos));
    } catch (e, s) {
      debugPrint('HiveService: Error sorting queueList by pos: $e');
      debugPrint('HiveService: Stacktrace for sorting error: $s');
      // Depending on requirements, you might return the unsorted list or handle otherwise.
    }
    return queueList;
  }

  Future<QueueModel?> getQueueByGuid(String guid) async {
    final box = await queueBox;
    return box.get(guid);
  }

  Future<void> clearQueue() async {
    final box = await queueBox;
    await box.clear(); // Add await
  }

  // This should get the fetch the list then sort it in ASC order
  void reorderQueue(int oldIndex, int newIndex) async {
    final box = await queueBox;
    List<QueueModel> queue = await getSortedQueue();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final QueueModel item = queue.removeAt(oldIndex);
    queue.insert(newIndex, item);

    // Update the 'pos' field for all items in the reordered list
    for (int i = 0; i < queue.length; i++) {
      queue[i].pos = i + 1;
    }

    // Clear the box and re-add the reordered items
    await box.clear();

    for (var item in queue) {
      await box.put(item.guid, item);
    }

    notifyListeners();
  }

  // Download Operations:
  Future<void> addToDownloads(DownloadModel download) async {
    final box = await downloadBox;
    await box.put(download.guid, download);
    notifyListeners();
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
    notifyListeners();
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
  Future<void> saveSettings(SettingsModel settings) async {
    final box = await settingsBox;
    await box.put('settings', settings);
  }

  Future<SettingsModel?> getSettings() async {
    final box = await settingsBox;
    return box.get('settings');
  }

  Future<void> deleteSettings() async {
    final box = await settingsBox;
    await box.delete('settings'); // Add await
  }

  Future<int> podcastSubscribedEpisodeCount(int podcastId) async {
    final box = await subscriptionBox;
    final SubscriptionModel? allEpisodes = await box.get(podcastId.toString());

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
            .getPodcastEpisodeCountByPodcastId(subscription.id);

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
    final Map<String, QueueModel> allEpisodes = await box.getAllValues();

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

  Future<FetchDataModel?>? getTrendingPodcast() async {
    final box = await trendingBox;
    return await box.get('trending');
  }

  void putTrendingPodcast(Map<String, dynamic> data) async {
    final box = await trendingBox;
    await box.put('trending', FetchDataModel.fromJson(data));
  }
}
