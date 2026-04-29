import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:openair/config/config.dart';
import 'package:openair/controllers/subscription_controller.dart';
import 'package:openair/controllers/sync_controller.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/history_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:path_provider/path_provider.dart';

final openAirProvider = ChangeNotifierProvider<OpenAirProvider>(
  (ref) => OpenAirProvider(ref),
);

class OpenAirProvider extends ChangeNotifier {
  late BuildContext context;

  final String storagePath = 'openair/downloads';

  Directory? directory;

  int navIndex = 1;

  late bool hasConnection;

  final Ref ref;

  OpenAirProvider(this.ref);

  HiveService get hiveService => ref.read(hiveServiceProvider);
  SyncController get syncController => ref.read(syncControllerProvider);
  AudioController get audioController => ref.read(audioProvider);
  SubscriptionController get subscriptionController =>
      ref.read(subscriptionControllerProvider);

  Future<void> initial(BuildContext context) async {
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    this.context = context;

    final hiveService = ref.read(hiveServiceProvider);
    if (context.mounted) await hiveService.initial(context);

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

  void automaticDownloadQueuedEpisodes() {
    if (downloadQueuedEpisodesConfig) {
      // Implementation delegated to audio controller
    }
  }

  Future<void> exportToDb(String path) async {
    await syncController.exportDatabase(path);
  }

  Future<void> importFromDb(File file) async {
    await syncController.importDatabase(file);
  }

  // Backward compatibility methods delegating to controllers

  Future<bool> isSubscribed(String podcastTitle) async {
    return await subscriptionController.checkSubscriptionStatus(podcastTitle);
  }

  Future<Map<String, SubscriptionModel>> getSubscriptions() async {
    final subs = await subscriptionController.fetchAllSubscriptions();
    return subs;
  }

  Future<String> getSubscriptionsCount(String title) async {
    return await subscriptionController.getEpisodeCount(title);
  }

  Future<String> getAccumulatedSubscriptionCount() async {
    return await subscriptionController.getTotalNewEpisodesCount();
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

  Future<bool> isEpisodeNew(String guid) async {
    final result = await hiveService.getEpisode(guid);
    return result == null;
  }

  Future<List<Map>> getSubscribedEpisodes() async {
    return await hiveService.getEpisodes();
  }

  Future<List<DownloadModel>> getSortedDownloadedEpisodes() async {
    return await hiveService.getSortedDownloads();
  }

  Future<List<HistoryModel>> getSortedHistory() async {
    return await hiveService.getSortedHistory();
  }

  void share() {
    debugPrint('share button clicked');
  }

  Future<void> exportPodcastToOpml() async {}

  void downloadEnqueue(BuildContext context) async {
    // Implementation delegated to audio controller
  }

  Future<void> synchronize(BuildContext context) async {
    await syncController.synchronize(context);
  }
}
