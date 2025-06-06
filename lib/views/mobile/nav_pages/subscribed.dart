import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscription.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/subscription.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart'; // Corrected import path

final FutureProvider<Map<String, Subscription>> subscriptionsProvider =
    FutureProvider((ref) async {
  final openAir = ref.watch(openAirProvider);
  return await openAir.getSubscriptions();
});

class Subscribed extends ConsumerStatefulWidget {
  const Subscribed({super.key});

  @override
  ConsumerState<Subscribed> createState() => _SubscribedState();
}

class _SubscribedState extends ConsumerState<Subscribed>
    with AutomaticKeepAliveClientMixin<Subscribed> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AsyncValue<Map<String, Subscription>> getSubscriptionsValue =
        ref.watch(subscriptionsProvider);

    return Consumer(
      builder: (context, ref, child) => getSubscriptionsValue.when(
        data: (Map<String, Subscription> data) {
          if (data.isEmpty) {
            return NoSubscription();
          }

          final List<Subscription> subs = data.values.toList();

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('Subscribed'),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
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

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EpisodesPage(
                            podcast: subs[index].toJson(),
                            id: subs[index].id,
                          ),
                        ),
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
                                child: FutureBuilder(
                                  future: ref
                                      .watch(openAirProvider)
                                      .getSubscriptionsCount(subs[index].id),
                                  builder: (context, subCountSnapshot) {
                                    if (subCountSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: Text(
                                          '...',
                                          style: TextStyle(
                                            color:
                                                subscriptionCountBoxTextColor,
                                            fontSize:
                                                subscriptionCountBoxFontSize,
                                            fontWeight:
                                                subscriptionCountBoxFontWeight,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    }

                                    if (subCountSnapshot.data == null) {
                                      return Center(
                                        child: IconButton(
                                          onPressed: () => ref
                                              .invalidate(podcastIndexProvider),
                                          icon: Icon(
                                            Icons.error_outline_rounded,
                                            color: Colors.white,
                                            size: subscriptionCountBoxSize - 12,
                                          ),
                                        ),
                                      );
                                    }

                                    return Center(
                                      child: Text(
                                        subCountSnapshot.data!,
                                        style: TextStyle(
                                          color: subscriptionCountBoxTextColor,
                                          fontSize:
                                              subscriptionCountBoxFontSize,
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
                    style: TextStyle(fontSize: 16.0),
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
      ),
    );
  }
}
