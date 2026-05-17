import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';

// Batch fetch all episode counts and new episodes in one provider
final subscriptionsWithCountsProvider =
    FutureProvider.autoDispose<Map<String, Map<String, dynamic>>>((ref) async {
  final openAir = ref.watch(openAirProvider);
  final subscriptions = await openAir.getSubscriptions();

  if (subscriptions.isEmpty) return <String, Map<String, dynamic>>{};

  final podcastIndex = ref.watch(podcastIndexProvider);
  final result = <String, Map<String, dynamic>>{};

  for (final entry in subscriptions.entries) {
    final sub = entry.value;
    try {
      final episodeCount =
          await podcastIndex.getPodcastEpisodeCountByTitle(sub.title);
      final storedCount = sub.episodeCount;
      result[sub.title] = {
        'newEpisodes': episodeCount - storedCount,
        'totalEpisodes': episodeCount,
      };
    } catch (e) {
      result[sub.title] = {
        'newEpisodes': 0,
        'totalEpisodes': 0,
      };
    }
  }

  return result;
});

// Provider to check if a podcast is subscribed
final isSubscribedProvider =
    FutureProvider.family<bool, String>((ref, title) async {
  final openAir = ref.watch(openAirProvider);
  return await openAir.isSubscribed(title);
});

// Provider to fetch episodes by podcast URL
final podcastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podcastUrl) async {
  final podcastIndexService = ref.watch(podcastIndexProvider);
  return await podcastIndexService.getEpisodesByFeedUrl(podcastUrl);
});
