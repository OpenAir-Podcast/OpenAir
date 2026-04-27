import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';

final subscriptionControllerProvider = Provider<SubscriptionController>(
  (ref) => SubscriptionController(ref),
);

class SubscriptionController {
  final Ref ref;

  SubscriptionController(this.ref);

  HiveService get _hiveService => ref.read(hiveServiceProvider);
  PodcastIndexProvider get _podcastIndexService =>
      ref.read(podcastIndexProvider);

  Future<Map<String, SubscriptionModel>> fetchAllSubscriptions() async {
    return await _hiveService.getSubscriptions();
  }

  Future<SubscriptionModel?> fetchSubscription(String title) async {
    return await _hiveService.getSubscription(title);
  }

  Future<bool> checkSubscriptionStatus(String podcastTitle) async {
    final result = await _hiveService.getSubscription(podcastTitle);
    return result != null;
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    await _hiveService.subscribe(subscription);
    ref.invalidate(subscriptionsProvider);
    ref.invalidate(getSubscribedEpisodesProvider);
  }

  Future<void> removeSubscription(String title) async {
    await _hiveService.unsubscribe(title);
    ref.invalidate(subscriptionsProvider);
    ref.invalidate(getSubscribedEpisodesProvider);
  }

  Future<void> clearAllSubscriptions() async {
    await _hiveService.deleteSubscriptions();
    ref.invalidate(subscriptionsProvider);
  }

  Future<void> refreshSubscriptions() async {
    await _hiveService.updateSubscriptions();
  }

  Future<void> loadInbox() async {
    await _hiveService.populateInbox();
  }

  Future<String> getEpisodeCount(String title) async {
    final currentSubEpCount =
        await _hiveService.podcastSubscribedEpisodeCount(title);
    try {
      final podcastEpisodeCount =
          await _podcastIndexService.getPodcastEpisodeCountByTitle(title);
      return (podcastEpisodeCount - currentSubEpCount).toString();
    } on DioException catch (e) {
      debugPrint(
          'DioError getting episode count for podcast $title: ${e.message}');
      return '...';
    } catch (e) {
      debugPrint('Error getting episode count for podcast $title: $e');
      return '...';
    }
  }

  Future<String> getTotalNewEpisodesCount() async {
    return await _hiveService.podcastAccumulatedSubscribedEpisodes();
  }

  Future<int> getInboxCount() async {
    return await _hiveService.getNewInboxCount();
  }

  Future<void> importFromOpml(File file) async {
    await _hiveService.importOpml(file);
  }

  Future<void> exportToOpml(String path) async {
    await _hiveService.exportOpml(path);
  }

  Future<void> importFromBackup(File file) async {
    await _hiveService.importSubscriptions(file);
  }
}
