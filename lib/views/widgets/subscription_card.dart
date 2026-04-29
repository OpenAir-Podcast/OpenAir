import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/views/main_pages/subscriptions_episodes_page.dart';

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
    // Get batched data from the optimized provider
    final subscriptionsWithCounts = ref.watch(subscriptionsWithCountsProvider);

    return subscriptionsWithCounts.when(
      data: (countsMap) {
        final title = subs[index].title;
        final countData = countsMap[title] ?? {};
        final newEpisodes = countData['newEpisodes'] as int? ?? 0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            cardSidePadding,
            cardTopPadding,
            cardSidePadding,
            cardTopPadding,
          ),
          child: GestureDetector(
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
                        imageUrl: subs[index].artwork,
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          size: 56.0,
                        ),
                      ),
                    ),
                    if (newEpisodes > 0)
                      Positioned(
                        right: 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: subscriptionCountBoxColor,
                          ),
                          height: subscriptionCountBoxSize,
                          width: subscriptionCountBoxSize,
                          child: Center(
                            child: Text(
                              '$newEpisodes',
                              style: TextStyle(
                                color: subscriptionCountBoxTextColor,
                                fontSize: subscriptionCountBoxFontSize,
                                fontWeight: subscriptionCountBoxFontWeight,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
      error: (error, stackTrace) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.grey),
              const SizedBox(height: 4),
              Text('Error', style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.fromLTRB(
          cardSidePadding,
          cardTopPadding,
          cardSidePadding,
          cardTopPadding,
        ),
        child: Column(
          children: [
            Container(
              height: cardImageHeight,
              width: cardImageWidth,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: cardLabelWidth,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}
