import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/podcast_model.dart';
import 'package:openair/models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart'
    hide subscriptionsProvider;
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/main_pages/subscriptions_episodes_page.dart';
import 'package:openair/views/mobile/nav_pages/subscriptions_page.dart';

final getSubscriptionsCountProvider =
    FutureProvider.family.autoDispose<String, String>((ref, title) async {
  // Gets episodes count from last stored index of episodes
  int currentSubEpCount =
      await ref.read(hiveServiceProvider).podcastSubscribedEpisodeCount(title);

  // Gets episodes count from PodcastIndex
  int podcastEpisodeCount =
      await ref.read(podcastIndexProvider).getPodcastEpisodeCountByTitle(title);

  int result = podcastEpisodeCount - currentSubEpCount;
  return '$result';
});

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.subs,
    required this.ref,
    required this.index,
  });

  final List<SubscriptionModel> subs;
  final WidgetRef ref;
  final int index;

  @override
  Widget build(BuildContext context) {
    final subCountDataAsyncValue =
        ref.watch(getSubscriptionsCountProvider(subs[index].title));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        cardSidePadding,
        cardTopPadding,
        cardSidePadding,
        cardTopPadding,
      ),
      child: GestureDetector(
        onLongPress: () {
          // TODO Add a dropmenu here
        },
        onTap: () {
          ref.read(openAirProvider.notifier).currentPodcast =
              PodcastModel.fromJson(subs[index].toJson());

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubscriptionsEpisodesPage(
                podcast: PodcastModel.fromJson(subs[index].toJson()),
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
                    child: subCountDataAsyncValue.when(
                      data: (data) {
                        return Center(
                          child: Text(
                            data,
                            style: TextStyle(
                              color: subscriptionCountBoxTextColor,
                              fontSize: subscriptionCountBoxFontSize,
                              fontWeight: subscriptionCountBoxFontWeight,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                      error: (error, stackTrace) {
                        return Center(
                          child: IconButton(
                            onPressed: () {
                              ref.invalidate(subscriptionsProvider);

                              ref.invalidate(
                                getSubscriptionsCountProvider(
                                    subs[index].title),
                              );
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
                              fontWeight: subscriptionCountBoxFontWeight,
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
  }
}
