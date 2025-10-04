import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/main_pages/subscriptions_episodes_page.dart';

final getSubscriptionsCountProvider =
    FutureProvider.family.autoDispose<String, String>((ref, title) async {
  HiveService hiveService = ref.watch(openAirProvider).hiveService;

  // Gets episodes count from last stored index of episodes
  int currentSubEpCount =
      await hiveService.podcastSubscribedEpisodeCount(title);

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

          debugPrint('Long press');
        },
        onTap: () {
          ref.read(audioProvider.notifier).currentPodcast =
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
