import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:openair/models/completed_episode.dart';
import 'package:openair/models/episode.dart';
import 'package:openair/models/feed.dart';
import 'package:openair/models/subscription.dart';
import 'package:openair/models/queue.dart';
import 'package:openair/models/download.dart';
import 'package:openair/models/history.dart';
import 'package:openair/models/settings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = ChangeNotifierProvider<HiveService>(
  (ref) {
    return HiveService(ref);
  },
);

// StreamProvider for Subscriptions
final subscriptionsProvider =
    StreamProvider<Map<String, Subscription>>((ref) async* {
  final hiveService = ref.watch(hiveServiceProvider);
  final box = await hiveService.subscriptionBox;

  // Emit the initial state
  yield await box.getAllValues();
});

final episodesProvider = StreamProvider<Map<String, Episode>>((ref) async* {
  final hiveService = ref.watch(hiveServiceProvider);
  final box = await hiveService.episodeBox;

  // Emit the initial state
  yield await box.getAllValues();
});

class HiveService extends ChangeNotifier {
  late final BoxCollection collection;
  late final Future<CollectionBox<Subscription>> subscriptionBox;
  late final Future<CollectionBox<Episode>> episodeBox;
  late final Future<CollectionBox<Feed>> feedBox;
  late final Future<CollectionBox<Queue>> queueBox;
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
    Hive.registerAdapter(QueueAdapter());
    Hive.registerAdapter(DownloadAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(CompletedEpisodeAdapter());
    Hive.registerAdapter(SettingsAdapter());

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
      },
      path: openAirDir.path,
    );

    subscriptionBox = collection.openBox<Subscription>('subscriptions');
    episodeBox = collection.openBox<Episode>('episodes');
    feedBox = collection.openBox<Feed>('feed');
    queueBox = collection.openBox<Queue>('queue');
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
    // Make return type Future<void>
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

  Future<Map<String, Episode>> getEpisodes() async {
    final box = await episodeBox;
    return box.getAllValues();
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
    // Make return type Future<void>
    final box = await feedBox;
    await box.put(feed.guid, feed);
  }

  Future<void> deleteFromFeed({required String guid}) async {
    // Make return type Future<void>
    final box = await feedBox;
    await box.delete(guid);
  }

  Future<Map<String, Feed>> getFeed() async {
    final box = await feedBox;
    return box.getAllValues();
  }

  Future<void> deleteFeed() async {
    // Make return type Future<void>
    final box = await feedBox;
    await box.clear(); // Add await
  }

  // Queue Operations:
  Future<void> addToQueue(Queue queue) async {
    // Make return type Future<void>
    final box = await queueBox;
    await box.put(queue.guid, queue);
  }

  Future<void> removeFromQueue({required String guid}) async {
    // Make return type Future<void>
    final box = await queueBox;
    await box.delete(guid);
  }

  Future<Map<String, Queue>> getQueue() async {
    final box = await queueBox;
    return box.getAllValues();
  }

  Future<void> clearQueue() async {
    // Make return type Future<void>
    final box = await queueBox;
    await box.clear(); // Add await
  }

  // TODO: Implement a reorderQueue method that tightly couple the pos together
  // TODO: This should get the fetch the list then sort it in ASC order
  void reorderQueue() {}

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
  Future<void> addToCompletedEpisodes(CompletedEpisode completedEpisode) async {
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

  Future<int> podcastSubscribeEpisodes(int podcastId) async {
    final box = await subscriptionBox;
    final Subscription? allEpisodes = await box.get(podcastId.toString());

    return allEpisodes!.episodeCount;
  }
}
