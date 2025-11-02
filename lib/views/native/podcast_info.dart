import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:url_launcher/url_launcher.dart';

final podcastDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, title) async {
  final podcastIndexService = ref.watch(podcastIndexProvider);
  return await podcastIndexService.getPodcastDetailsByTitle(title);
});

class PodcastInfoPage extends ConsumerWidget {
  const PodcastInfoPage({super.key, required this.podcastInfo});

  final Map podcastInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(podcastInfo['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    width: 150,
                    height: 150,
                    memCacheHeight: 300,
                    imageUrl: podcastInfo['image'],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: cardImageShadow,
                      child: const Icon(
                        Icons.error,
                        size: 56.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcastInfo['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          podcastInfo['author'],
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${podcastInfo['episodeCount']} episodes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                podcastInfo['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Link: '),
                  TextButton(
                    onPressed: () async {
                      await launchUrl(
                        Uri.parse(podcastInfo['link']),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Text(
                      podcastInfo['link'] ?? podcastInfo['url'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Language: ${podcastInfo['language']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Medium: ${podcastInfo['medium']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Categories: ${podcastInfo['categories'].values.join(', ')}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Last Update: ${DateTime.fromMillisecondsSinceEpoch(podcastInfo['lastUpdateTime'] * 1000)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
