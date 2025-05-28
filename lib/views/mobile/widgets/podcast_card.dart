import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';

class PodcastCard extends ConsumerWidget {
  final Map<String, dynamic> podcastItem;

  const PodcastCard({
    super.key,
    required this.podcastItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(openAirProvider.notifier).currentPodcast = podcastItem;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EpisodesPage(
              podcast: podcastItem,
              id: podcastItem['id'],
            ),
          ),
        );
      },
      child: Card(
        color: Colors.blueGrey[100],
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(podcastItem['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                width: 62.0,
                height: 62.0,
              ),
              Expanded(
                child: SizedBox(
                  width: 500.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 105.0,
                          child: Text(
                            podcastItem['title'],
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 120.0,
                          child: Text(
                            podcastItem['author'] ?? 'Unknown',
                            maxLines: 2,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: IconButton(
                  tooltip:
                      ref.read(openAirProvider).isSubscribed(podcastItem['id'])
                          ? 'Unsubscribe to podcast'
                          : 'Subscribe to podcast',
                  onPressed: () {
                    if (ref
                        .read(openAirProvider)
                        .isSubscribed(podcastItem['id'])) {
                      // Unsubscribe
                      ref
                          .read(openAirProvider.notifier)
                          .unsubscribe(podcastItem);
                    } else {
                      // Subscribe
                      ref.read(openAirProvider.notifier).subscribe(podcastItem);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ref
                                .read(openAirProvider)
                                .isSubscribed(podcastItem['id'])
                            ? 'Subscribed to ${podcastItem['title']}'
                            : 'Unsubscribed from ${podcastItem['title']}'),
                      ),
                    );

                    ChangeNotifier();
                  },
                  icon:
                      ref.watch(openAirProvider).isSubscribed(podcastItem['id'])
                          ? const Icon(Icons.check)
                          : const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
