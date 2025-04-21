import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/models/feed_model.dart';
import 'package:openair/providers/podcast_provider.dart';

import '../apis/api_service_provider.dart';

final getTrendingProvider = FutureProvider(
  (ref) async {
    Map<String, dynamic> feed =
        await ref.watch(apiServiceProvider).getTrendingPodcasts();

    if (ref.read(podcastProvider).feedPodcasts.isEmpty) {
      for (Map<String, dynamic> podcast in feed['feeds']) {
        final FeedModel feedModel = FeedModel.fromJson(podcast);

        if (!ref.watch(podcastProvider).feedPodcasts.contains(feedModel)) {
          ref.watch(podcastProvider).feedPodcasts.add(feedModel);
        }
      }
    }

    return ref.watch(podcastProvider).feedPodcasts;
  },
);

final refreshTrendingProvider = FutureProvider(
  (ref) async {
    Map<String, dynamic> feed =
        await ref.watch(apiServiceProvider).getTrendingPodcasts();

    if (ref.read(podcastProvider).feedPodcasts.isEmpty) {
      for (Map<String, dynamic> podcast in feed['feeds']) {
        final FeedModel feedModel = FeedModel.fromJson(podcast);

        if (!ref.watch(podcastProvider).feedPodcasts.contains(feedModel)) {
          ref.watch(podcastProvider).feedPodcasts.add(feedModel);
        }
      }
    }

    return ref.watch(podcastProvider).feedPodcasts;
  },
);
