import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/history_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> initial(
    BuildContext context,
  ) async {
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    this.context = context;

    hiveService = ref.read(hiveServiceProvider);
    await hiveService.initial();

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

  Future<Map> fetchInboxEpisodes() async {
    return hiveService.fetchInboxEpisodes();
  }

  Future<Map?> getInboxEpisodes() async {
    return await hiveService.getInboxEpisodes();
  }

  Future<String> getQueueCount() async {
    return await hiveService.queueCount();
  }

  Future<String> getDownloadsCount() async {
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

  void updateFontSize(String size) {}

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
}
