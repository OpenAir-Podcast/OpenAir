import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          podcastInfo['title'],
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.3),
                      colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Podcast cover with shadow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'podcast_${podcastInfo['title']}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              width: 140,
                              height: 140,
                              memCacheHeight: 280,
                              imageUrl: podcastInfo['image'],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 140,
                                height: 140,
                                color: cardImageShadow,
                                child: const Icon(
                                  Icons.error,
                                  size: 48.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Row(
                        children: [
                          // Podcast info
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  podcastInfo['title'],
                                  textAlign: TextAlign.center,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      podcastInfo['author'] ??
                                          Translations.of(context)
                                              .text('unknown'),
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.headphones_outlined,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${podcastInfo['episodeCount']} episodes',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Description section
              if (podcastInfo['description']?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Translations.of(context).text('description'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    podcastInfo['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Details section
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Translations.of(context).text('details'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      Icons.link_outlined,
                      Translations.of(context).text('link'),
                      podcastInfo['link'] ?? podcastInfo['url'] ?? '',
                      theme,
                      isLink: true,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.language_outlined,
                      Translations.of(context).text('language'),
                      podcastInfo['language'] ?? 'Unknown',
                      theme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.category_outlined,
                      Translations.of(context).text('medium'),
                      podcastInfo['medium'] ?? 'Unknown',
                      theme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.label_outlined,
                      Translations.of(context).text('categories'),
                      (podcastInfo['categories'] as Map?)?.values.join(', ') ??
                          'None',
                      theme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.update_outlined,
                      Translations.of(context).text('lastUpdate'),
                      DateTime.fromMillisecondsSinceEpoch(
                              podcastInfo['lastUpdateTime'] * 1000)
                          .toString()
                          .split(' ')[0],
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isLink)
                  GestureDetector(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse(value),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
