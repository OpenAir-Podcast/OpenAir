import 'dart:async';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:openair/model/hive_models/completed_episode_model.dart';
import 'package:openair/model/hive_models/feed_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/history_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';

class SubscriptionRepository {
  final CollectionBox<SubscriptionModel> _subscriptionBox;
  final CollectionBox<Map> _episodeBox;
  final CollectionBox<FeedModel> _feedBox;

  SubscriptionRepository({
    required CollectionBox<SubscriptionModel> subscriptionBox,
    required CollectionBox<Map> episodeBox,
    required CollectionBox<FeedModel> feedBox,
  })  : _subscriptionBox = subscriptionBox,
        _episodeBox = episodeBox,
        _feedBox = feedBox;

  Future<void> subscribe(SubscriptionModel subscription) async {
    await _subscriptionBox.put(subscription.title, subscription);
  }

  Future<void> unsubscribe(String title) async {
    await _subscriptionBox.delete(title);
  }

  Future<Map<String, SubscriptionModel>> getAll() async {
    return await _subscriptionBox.getAllValues();
  }

  Future<SubscriptionModel?> get(String title) async {
    return await _subscriptionBox.get(title);
  }

  Future<void> deleteAll() async {
    await _subscriptionBox.clear();
    await _feedBox.clear();
    await _episodeBox.clear();
  }

  Future<void> insertEpisode(Map episode, String guid) async {
    await _episodeBox.put(guid, episode);
  }

  Future<void> removePodcastEpisodes(PodcastModel podcast) async {
    final allEpisodes = await _episodeBox.getAllValues();
    for (final episode in allEpisodes.entries) {
      if (episode.value['author'] == podcast.author) {
        await _episodeBox.delete(episode.key);
      }
    }
  }

  Future<List<Map>> getEpisodes() async {
    final allEpisodes = await _episodeBox.getAllValues();
    final List<Map> episodesList = [];

    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }
    episodesList
        .sort((a, b) => b['datePublished'].compareTo(a['datePublished']));
    return episodesList;
  }

  Future<Map?> getEpisode(String guid) async {
    return await _episodeBox.get(guid);
  }
}

class QueueRepository {
  final CollectionBox<Map> _queueBox;

  QueueRepository({required CollectionBox<Map> queueBox})
      : _queueBox = queueBox;

  Future<void> add(Map queue) async {
    await _queueBox.put(queue['guid'], queue);
  }

  Future<void> remove(String guid) async {
    await _queueBox.delete(guid);
  }

  Future<Map> getAll() async {
    return await _queueBox.getAllValues();
  }

  Future<Map?> getByGuid(String guid) async {
    return await _queueBox.get(guid);
  }

  Future<void> clear() async {
    await _queueBox.clear();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final queueMap = await _queueBox.getAllValues();
    if (queueMap.isEmpty) return;

    final List<MapEntry<String, Map>> queueList = queueMap.entries.toList()
      ..sort(
          (a, b) => (a.value['pos'] as int).compareTo(b.value['pos'] as int));

    if (oldIndex < newIndex) newIndex -= 1;

    if (oldIndex < 0 ||
        oldIndex >= queueList.length ||
        newIndex < 0 ||
        newIndex >= queueList.length ||
        oldIndex == newIndex) {
      return;
    }

    final item = queueList.removeAt(oldIndex);
    queueList.insert(newIndex, item);

    final Map<String, Map> updatedItems = {};
    for (int i = 0; i < queueList.length; i++) {
      final entry = queueList[i];
      final updatedValue = Map<String, dynamic>.from(entry.value)..['pos'] = i;
      updatedItems[entry.key] = updatedValue;
    }

    await _queueBox.clear();
    for (final entry in updatedItems.entries) {
      await _queueBox.put(entry.key, entry.value);
    }
  }
}

class DownloadRepository {
  final CollectionBox<DownloadModel> _downloadBox;
  final List<DownloadModel> _downloadedList = [];

  DownloadRepository({
    required CollectionBox<DownloadModel> downloadBox,
    required Directory openAirDir,
  }) : _downloadBox = downloadBox;

  Future<void> add(DownloadModel download) async {
    await _downloadBox.put(download.guid, download);
  }

  Future<Map<String, DownloadModel>> getAll() async {
    return await _downloadBox.getAllValues();
  }

  Future<List<DownloadModel>> getSorted() async {
    final allEpisodes = await _downloadBox.getAllValues();
    final List<DownloadModel> queueList = [];
    for (final entry in allEpisodes.entries) {
      queueList.add(entry.value);
    }
    queueList.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));
    return queueList;
  }

  Future<void> delete(String guid) async {
    await _downloadBox.delete(guid);
  }

  Future<void> clear() async {
    await _downloadBox.clear();
    _downloadedList.clear();
  }

  Future<int> count() async {
    final allEpisodes = await _downloadBox.getAllValues();
    return allEpisodes.length;
  }
}

class HistoryRepository {
  final CollectionBox<HistoryModel> _historyBox;

  HistoryRepository({required CollectionBox<HistoryModel> historyBox})
      : _historyBox = historyBox;

  Future<void> add(HistoryModel history) async {
    await _historyBox.put(history.guid, history);
  }

  Future<Map<String, HistoryModel>> getAll() async {
    return await _historyBox.getAllValues();
  }

  Future<List<HistoryModel>> getSorted() async {
    final allEpisodes = await _historyBox.getAllValues();
    final List<HistoryModel> episodesList = [];
    for (final entry in allEpisodes.entries) {
      episodesList.add(entry.value);
    }
    episodesList.sort((a, b) => b.playDate.compareTo(a.playDate));
    return episodesList;
  }

  Future<void> delete(String guid) async {
    await _historyBox.delete(guid);
  }

  Future<void> clear() async {
    await _historyBox.clear();
  }
}

class FeedRepository {
  final CollectionBox<FeedModel> _feedBox;

  FeedRepository({required CollectionBox<FeedModel> feedBox})
      : _feedBox = feedBox;

  Future<void> add(FeedModel feed) async {
    await _feedBox.put(feed.guid, feed);
  }

  Future<void> delete(String guid) async {
    await _feedBox.delete(guid);
  }

  Future<Map<String, FeedModel>> getAll() async {
    return await _feedBox.getAllValues();
  }

  Future<void> clear() async {
    await _feedBox.clear();
  }

  Future<int> count() async {
    final allFeeds = await _feedBox.getAllValues();
    return allFeeds.length;
  }
}

class CompletedEpisodeRepository {
  final CollectionBox<CompletedEpisodeModel> _completedEpisodeBox;

  CompletedEpisodeRepository({
    required CollectionBox<CompletedEpisodeModel> completedEpisodeBox,
  }) : _completedEpisodeBox = completedEpisodeBox;

  Future<void> add(CompletedEpisodeModel completedEpisode) async {
    await _completedEpisodeBox.put(completedEpisode.guid, completedEpisode);
  }

  Future<Map<String, CompletedEpisodeModel>> getAll() async {
    return await _completedEpisodeBox.getAllValues();
  }

  Future<void> delete(String guid) async {
    await _completedEpisodeBox.delete(guid);
  }

  Future<void> clear() async {
    await _completedEpisodeBox.clear();
  }
}

class FavoritesRepository {
  final CollectionBox<Map> _favoritesBox;

  FavoritesRepository({required CollectionBox<Map> favoritesBox})
      : _favoritesBox = favoritesBox;

  void add(Map<String, dynamic> episode, PodcastModel podcast) async {
    episode['podcast'] = podcast;
    await _favoritesBox.put(episode['guid'], episode);
  }

  void remove(String guid) async {
    await _favoritesBox.delete(guid);
  }

  Future<Map> getAll() async {
    return await _favoritesBox.getAllValues();
  }
}

class SettingsRepository {
  final CollectionBox<Map> _settingsBox;

  SettingsRepository({required CollectionBox<Map> settingsBox})
      : _settingsBox = settingsBox;

  Future<void> saveUserInterfaceSettings(Map userInterfaceSettings) async {
    await _settingsBox.put('userInterface', userInterfaceSettings);
  }

  Future<Map<String, dynamic>> getUserInterfaceSettings() async {
    Map? userInterfaceSettings = await _settingsBox.get('userInterface');
    if (userInterfaceSettings == null) {
      userInterfaceSettings = {
        'fontSizeFactor': 'medium',
        'language': 'English',
        'locale': 'en_US',
      };
      await _settingsBox.put('userInterface', userInterfaceSettings);
    }
    return userInterfaceSettings.cast<String, dynamic>();
  }

  Future<void> savePlaybackSettings(Map playbackSettings) async {
    await _settingsBox.put('playback', playbackSettings);
  }

  Future<Map<String, dynamic>> getPlaybackSettings() async {
    Map? playbackSettings = await _settingsBox.get('playback');
    if (playbackSettings == null) {
      playbackSettings = {
        'fastForwardInterval': '10 seconds',
        'rewindInterval': '10 seconds',
        'playbackSpeed': '1.0x',
        'enqueuePosition': 'Last',
        'enqueueDownloaded': false,
        'continuePlayback': true,
        'smartMarkAsCompleted': '30 seconds',
        'keepSkippedEpisodes': false,
      };
      await _settingsBox.put('playback', playbackSettings);
    }
    return playbackSettings.cast<String, dynamic>();
  }

  Future<void> saveAutomaticSettings(Map automaticSettings) async {
    await _settingsBox.put('automatic', automaticSettings);
  }

  Future<Map<String, dynamic>> getAutomaticSettings() async {
    Map? automaticSettings = await _settingsBox.get('automatic');
    if (automaticSettings == null) {
      automaticSettings = {
        'refreshPodcasts': 'Never',
        'downloadNewEpisodes': true,
        'downloadQueuedEpisodes': true,
        'downloadEpisodeLimit': '25',
        'deletePlayedEpisodes': true,
        'keepFavouriteEpisodes': true,
        'removeEpisodesFromQueue': false,
      };
      await _settingsBox.put('automatic', automaticSettings);
    }
    return automaticSettings.cast<String, dynamic>();
  }

  Future<void> saveSynchronizationSettings(Map synchronizationSettings) async {
    await _settingsBox.put('synchronization', synchronizationSettings);
  }

  Future<Map<String, dynamic>> getSynchronizationSettings() async {
    Map? synchronizationSettings = await _settingsBox.get('synchronization');
    if (synchronizationSettings == null) {
      synchronizationSettings = {
        'syncFavourites': true,
        'syncQueue': true,
        'syncHistory': true,
        'syncPlaybackPosition': true,
        'syncSettings': true,
      };
      await _settingsBox.put('synchronization', synchronizationSettings);
    }
    return synchronizationSettings.cast<String, dynamic>();
  }

  Future<void> saveImportExportSettings(Map importExportSettings) async {
    await _settingsBox.put('importExport', importExportSettings);
  }

  Future<Map<String, dynamic>?> getImportExportSettings() async {
    final result = await _settingsBox.get('importExport');
    return result?.cast<String, dynamic>();
  }

  Future<void> saveNotificationsSettings(Map notificationsSettings) async {
    await _settingsBox.put('notifications', notificationsSettings);
  }

  Future<Map<String, dynamic>?> getNotificationsSettings() async {
    final result = await _settingsBox.get('notifications');
    return result?.cast<String, dynamic>();
  }
}
