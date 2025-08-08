import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/main_pages/subscriptions_episodes_page.dart';

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
        ref.read(openAirProvider).config.cardSidePadding,
        ref.read(openAirProvider).config.cardTopPadding,
        ref.read(openAirProvider).config.cardSidePadding,
        ref.read(openAirProvider).config.cardTopPadding,
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
                        color: ref.read(openAirProvider).config.cardImageShadow,
                        blurRadius: ref.read(openAirProvider).config.blurRadius,
                      )
                    ],
                  ),
                  height: ref.read(openAirProvider).config.cardImageHeight,
                  width: ref.read(openAirProvider).config.cardImageWidth,
                  child: CachedNetworkImage(
                    memCacheHeight:
                        ref.read(openAirProvider).config.cardImageHeight.ceil(),
                    memCacheWidth:
                        ref.read(openAirProvider).config.cardImageWidth.ceil(),
                    imageUrl: subs[index].imageUrl,
                  ),
                ),
                Positioned(
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ref
                          .read(openAirProvider)
                          .config
                          .subscriptionCountBoxColor,
                    ),
                    height: ref
                        .read(openAirProvider)
                        .config
                        .subscriptionCountBoxSize,
                    width: ref
                        .read(openAirProvider)
                        .config
                        .subscriptionCountBoxSize,
                    child: subCountDataAsyncValue.when(
                      data: (data) {
                        return Center(
                          child: Text(
                            data,
                            style: TextStyle(
                              color: ref
                                  .read(openAirProvider)
                                  .config
                                  .subscriptionCountBoxTextColor,
                              fontSize: ref
                                  .read(openAirProvider)
                                  .config
                                  .subscriptionCountBoxFontSize,
                              fontWeight: ref
                                  .read(openAirProvider)
                                  .config
                                  .subscriptionCountBoxFontWeight,
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
                              size: ref
                                      .read(openAirProvider)
                                      .config
                                      .subscriptionCountBoxSize -
                                  12,
                            ),
                          ),
                        );
                      },
                      loading: () {
                        return Center(
                          child: Text(
                            '...',
                            style: TextStyle(
                              color: ref
                                  .read(openAirProvider)
                                  .config
                                  .subscriptionCountBoxTextColor,
                              fontSize: ref
                                  .read(openAirProvider)
                                  .config
                                  .subscriptionCountBoxFontSize,
                              fontWeight: ref
                                  .read(openAirProvider)
                                  .config
                                  .subscriptionCountBoxFontWeight,
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
              height: ref.read(openAirProvider).config.cardLabelHeight,
              width: ref.read(openAirProvider).config.cardLabelWidth,
              decoration: BoxDecoration(
                color: ref.read(openAirProvider).config.cardLabelBackground,
                boxShadow: [
                  BoxShadow(
                    color: ref.read(openAirProvider).config.cardLabelShadow,
                    blurRadius: ref.read(openAirProvider).config.blurRadius,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ref.read(openAirProvider).config.cardLabelPadding),
                child: Text(
                  subs[index].title,
                  maxLines: ref.read(openAirProvider).config.cardLabelMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ref.read(openAirProvider).config.cardLabelTextColor,
                    fontSize:
                        ref.read(openAirProvider).config.cardLabelFontSize,
                    fontWeight:
                        ref.read(openAirProvider).config.cardLabelFontWeight,
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
