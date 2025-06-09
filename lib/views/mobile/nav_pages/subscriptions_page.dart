import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/subscription.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/podcast_index_provider.dart';

import 'package:openair/views/mobile/main_pages/subscriptions_episodes_page.dart';

final FutureProvider<Map<String, Subscription>> subscriptionsProvider =
    FutureProvider((ref) async {
  final openAir = ref.watch(openAirProvider);
  return await openAir.getSubscriptions();
});

final getSubscriptionsCountProvider =
    FutureProvider.family<String, int>((ref, podcastId) async {
  // Gets episodes count from last stored index of episodes
  int currentSubEpCount = await ref
      .read(hiveServiceProvider)
      .podcastSubscribedEpisodeCount(podcastId);

  // Gets episodes count from PodcastIndex
  int podcastEpisodeCount = await ref
      .watch(podcastIndexProvider)
      .getPodcastEpisodeCountByPodcastId(podcastId);

  int result = podcastEpisodeCount - currentSubEpCount;

  return result.toString();
});

class SubscriptionsPage extends ConsumerStatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  ConsumerState<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends ConsumerState<SubscriptionsPage>
    with AutomaticKeepAliveClientMixin<SubscriptionsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AsyncValue<Map<String, Subscription>> getSubscriptionsValue =
        ref.watch(subscriptionsProvider);

    return getSubscriptionsValue.when(
      data: (Map<String, Subscription> data) {
        if (data.isEmpty) {
          return NoSubscriptions(title: 'Subscriptions');
        }

        final List<Subscription> subs = data.values.toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Subscriptions'),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO Add search functionality here
                  // This is to search for podcast that the user has already sub to.
                },
                icon: const Icon(Icons.search),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    // TODO Add some options here
                  },
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ),
            ],
          ),
          body: GridView.builder(
            itemCount: subs.length,
            cacheExtent: cacheExtent,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobileCrossAxisCount,
              mainAxisExtent: subscribedMobileMainAxisExtent,
            ),
            itemBuilder: (context, index) {
              final subCountDataAsyncValue =
                  ref.watch(getSubscriptionsCountProvider(subs[index].id));

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  cardSidePadding,
                  cardTopPadding,
                  cardSidePadding,
                  cardTopPadding,
                ),
                child: GestureDetector(
                  onTap: () {
                    final podcastData = subs[index].toJson();

                    ref.read(openAirProvider.notifier).currentPodcast =
                        podcastData;

                    // TODO Update subscription count in the database

                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => SubscriptionsEpisodesPage(
                          podcast: subs[index].toJson(),
                          id: subs[index].id,
                        ),
                      ),
                    )
                        .then(
                      (value) {
                        ref.invalidate(subscriptionsProvider);
                        ref.invalidate(
                            getSubscriptionsCountProvider(subs[index].id));
                      },
                    );
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: cardImageShadow,
                                  blurRadius: blurRadius,
                                )
                              ],
                            ),
                            height: cardImageHeight,
                            width: cardImageWidth,
                            child: CachedNetworkImage(
                              memCacheHeight: cardImageHeight.ceil(),
                              memCacheWidth: cardImageWidth.ceil(),
                              imageUrl: subs[index].imageUrl,
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: subscriptionCountBoxColor,
                              ),
                              height: subscriptionCountBoxSize,
                              width: subscriptionCountBoxSize,
                              child: subCountDataAsyncValue.when(
                                data: (data) {
                                  return Center(
                                    child: Text(
                                      data,
                                      style: TextStyle(
                                        color: subscriptionCountBoxTextColor,
                                        fontSize: subscriptionCountBoxFontSize,
                                        fontWeight:
                                            subscriptionCountBoxFontWeight,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                                error: (error, stackTrace) {
                                  return Center(
                                    child: IconButton(
                                      // FIXME does not work... need to reload page
                                      onPressed: () {
                                        ref.invalidate(subscriptionsProvider);

                                        ref.invalidate(
                                            getSubscriptionsCountProvider(
                                                subs[index].id));
                                      },
                                      icon: Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.white,
                                        size: subscriptionCountBoxSize - 12,
                                      ),
                                    ),
                                  );
                                },
                                loading: () {
                                  return Center(
                                    child: Text(
                                      '...',
                                      style: TextStyle(
                                        color: subscriptionCountBoxTextColor,
                                        fontSize: subscriptionCountBoxFontSize,
                                        fontWeight:
                                            subscriptionCountBoxFontWeight,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: cardLabelHeight,
                        width: cardLabelWidth,
                        decoration: BoxDecoration(
                          color: cardLabelBackground,
                          boxShadow: [
                            BoxShadow(
                              color: cardLabelShadow,
                              blurRadius: blurRadius,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(cardLabelPadding),
                          child: Text(
                            subs[index].title,
                            maxLines: cardLabelMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cardLabelTextColor,
                              fontSize: cardLabelFontSize,
                              fontWeight: cardLabelFontWeight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('Error loading subscriptions: $error\n$stackTrace');
        return Scaffold(
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 75.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Oops, an error occurred...',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 180.0,
                  height: 40.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      ref.invalidate(subscriptionsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
