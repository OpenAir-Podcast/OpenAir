import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:openair/models/completed_episode_model.dart';
import 'package:openair/models/episode_model.dart';
import 'package:openair/models/feed_model.dart';
import 'package:openair/models/subscription_model.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/models/download_model.dart';
import 'package:openair/models/history_model.dart';
import 'package:openair/models/settings_model.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = ChangeNotifierProvider<HiveService>(
  (ref) {
    return HiveService(ref);
  },
);

// StreamProvider for Subscriptions
final subscriptionsProvider =
    StreamProvider.autoDispose<Map<String, Subscription>>((ref) async* {
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

class HiveService extends ChangeNotifier {
  late final BoxCollection collection;
  late final Future<CollectionBox<Subscription>> subscriptionBox;
  late final Future<CollectionBox<Episode>> episodeBox;
  late final Future<CollectionBox<Feed>> feedBox;
  late final Future<CollectionBox<QueueModel>> queueBox;
  late final Future<CollectionBox<Download>> downloadBox;
  late final Future<CollectionBox<History>> historyBox;
  late final Future<CollectionBox<CompletedEpisode>> completedEpisodeBox;
  late final Future<CollectionBox<Settings>> settingsBox;

  bool _isInitialized = false;

  late final Directory openAirDir;

  HiveService(this.ref);
  final Ref<HiveService> ref;

  Future<void> init() async {
    if (_isInitialized) return;

    // Register all adapters
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(EpisodeAdapter());
    Hive.registerAdapter(FeedAdapter());
    Hive.registerAdapter(QueueModelAdapter());
    Hive.registerAdapter(DownloadAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(CompletedEpisodeAdapter());
    Hive.registerAdapter(SettingsAdapter());

    // Get the application documents directory
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();

      // Create the openair directory if it doesn't exist
      openAirDir = Directory(join(appDocumentDir.path, 'OpenAir/.hive_config'));

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
      },
      path: openAirDir.path,
    );

    subscriptionBox = collection.openBox<Subscription>('subscriptions');
    episodeBox = collection.openBox<Episode>('episodes');
    feedBox = collection.openBox<Feed>('feed');
    queueBox = collection.openBox<QueueModel>('queue');
    downloadBox = collection.openBox<Download>('download');
    historyBox = collection.openBox<History>('history');
    completedEpisodeBox =
        collection.openBox<CompletedEpisode>('completed_episodes');
    settingsBox = collection.openBox<Settings>('settings');

    _isInitialized = true;
  }

  void close() async {
    // Ensure collection is initialized before closing
    if (_isInitialized) {
      collection.close();
    }
  }

  // Subscription Operations:
  Future<void> subscribe(Subscription subscription) async {
    final box = await subscriptionBox;
    await box.put('${subscription.id}', subscription);
    notifyListeners();
  }

  Future<void> unsubscribe(String id) async {
    final box = await subscriptionBox;
    await box.delete(id);
    notifyListeners();
  }

  Future<Map<String, Subscription>> getSubscriptions() async {
    final box = await subscriptionBox;
    return box.getAllValues();
  }

  Future<Subscription?> getSubscription(String id) async {
    final box = await subscriptionBox;
    return box.get(id);
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
    Episode episode,
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

    final Map<String, Episode> allEpisodes = await box.getAllValues();
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

  Future<List<Episode>> getEpisodes() async {
    final box = await episodeBox;
    final Map<String, Episode> allEpisodes = await box.getAllValues();
    final List<Episode> episodesList = [];

    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }
    // Sort the list by datePublished in descending order (newest first)
    episodesList.sort((a, b) => b.datePublished.compareTo(a.datePublished));

    return episodesList;
  }

  Future<Episode?> getEpisode(String guid) async {
    final box = await episodeBox;
    return box.get(guid);
  }

  Future<Iterable<MapEntry<String, Episode>>> getEpisodesForPodcast(
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
  Future<void> addToFeed(Feed feed) async {
    final box = await feedBox;
    await box.put(feed.guid, feed);
  }

  Future<void> deleteFromFeed({required String guid}) async {
    final box = await feedBox;
    await box.delete(guid);
  }

  Future<Map<String, Feed>> getFeed() async {
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
    // Make return type Future<void>
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
  Future<void> addToDownload(Download download) async {
    // Make return type Future<void>
    final box = await downloadBox;
    await box.put(download.guid, download);
  }

  Future<Map<String, Download>> getDownloads() async {
    final box = await downloadBox;
    return box.getAllValues();
  }

  Future<List<Download>> getSortedDownloads() async {
    final box = await downloadBox;
    final Map<String, Download> allEpisodes = await box.getAllValues();
    final List<Download> episodesList = [];

    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }
    // Sort the list by datePublished in descending order (newest first)
    episodesList.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));

    return episodesList;
  }

  Future<void> deleteDownload({required String guid}) async {
    // Make return type Future<void>
    final box = await downloadBox;
    await box.delete(guid);
  }

  Future<void> clearDownloads() async {
    // Make return type Future<void>
    final box = await downloadBox;
    await box.clear(); // Add await
  }

  // History Operations:
  Future<void> addToHistory(History history) async {
    // Make return type Future<void>
    final box = await historyBox;
    await box.put(history.guid, history);
  }

  Future<Map<String, History>> getHistory() async {
    final box = await historyBox;
    return box.getAllValues();
  }

  Future<void> deleteHistory({required String guid}) async {
    // Make return type Future<void>
    final box = await historyBox;
    await box.delete(guid);
  }

  Future<void> clearHistory() async {
    // Make return type Future<void>
    final box = await historyBox;
    await box.clear(); // Add await
  }

  // Completed Episodes Operations:
  Future<void> addToCompletedEpisode(CompletedEpisode completedEpisode) async {
    // Make return type Future<void>
    final box = await completedEpisodeBox;
    await box.put(completedEpisode.guid, completedEpisode);
  }

  Future<Map<String, CompletedEpisode>> getCompletedEpisodes() async {
    final box = await completedEpisodeBox;
    return box.getAllValues();
  }

  Future<void> deleteCompletedEpisode({required String guid}) async {
    // Make return type Future<void>
    final box = await completedEpisodeBox;
    await box.delete(guid);
  }

  Future<void> clearCompletedEpisodes() async {
    // Make return type Future<void>
    final box = await completedEpisodeBox;
    await box.clear(); // Add await
  }

  // Settings Operations:
  Future<void> saveSettings(Settings settings) async {
    // Make return type Future<void>
    final box = await settingsBox;
    await box.put('settings', settings);
  }

  Future<Settings?> getSettings() async {
    final box = await settingsBox;
    return box.get('settings');
  }

  Future<void> deleteSettings() async {
    // Make return type Future<void>
    final box = await settingsBox;
    await box.delete('settings'); // Add await
  }

  Future<int> podcastSubscribedEpisodeCount(int podcastId) async {
    final box = await subscriptionBox;
    final Subscription? allEpisodes = await box.get(podcastId.toString());

    return allEpisodes!.episodeCount;
  }

  Future<String> podcastAccumulatedSubscribedEpisodes() async {
    final box = await subscriptionBox;
    final Map<String, Subscription> allSubscriptions = await box.getAllValues();

    if (allSubscriptions.isEmpty) {
      return "0";
    }

    int totalNewEpisodes = 0;

    for (final MapEntry<String, Subscription> entry
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
    final Map<String, Episode> allEpisodes = await box.getAllValues();

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
    final Map<String, Download> allEpisodes = await box.getAllValues();

    int result = allEpisodes.length;
    return result.toString();
  }

  Future<int> getAccumulatedEpisodes() async {
    final box = await subscriptionBox;
    final Map<String, Subscription> allEpisodes = await box.getAllValues();

    int episodeCount = 0;

    for (final entry in allEpisodes.entries) {
      episodeCount += entry.value.episodeCount;
    }

    return episodeCount;
  }
}
