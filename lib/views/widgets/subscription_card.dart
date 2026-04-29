import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/views/main_pages/subscriptions_episodes_page.dart';

class SubscriptionCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionsWithCounts = ref.watch(subscriptionsWithCountsProvider);

    return subscriptionsWithCounts.when(
      data: (data) {
        final title = subs[index].title;
        final countData = data[title] ?? {};
        final newEpisodes = countData['newEpisodes'] as int? ?? 0;

        return GestureDetector(
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
              // Podcast artwork
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          memCacheHeight: 200,
                          memCacheWidth: 200,
                          imageUrl: subs[index].artwork,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: theme.cardColor,
                            child: Icon(
                              Icons.podcasts,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // New episode badge
                  if (newEpisodes > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          newEpisodes > 99 ? '99+' : '$newEpisodes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Podcast title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    subs[index].title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return Column(
          children: [
            Icon(Icons.error_outline, color: Colors.grey),
            const SizedBox(height: 4),
            Text('Error', style: TextStyle(fontSize: 12)),
          ],
        );
      },
      loading: () => Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 80,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
