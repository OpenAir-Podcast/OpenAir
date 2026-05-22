import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/fetch_data_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/main_pages/discovery_page.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/main_pages/fyyd_search_page.dart';
import 'package:openair/views/main_pages/podcast_index_search_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/widgets/loading_dialog.dart';
import 'package:openair/views/widgets/toggle_banner.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

final podcastDataFeaturedProvider = FutureProvider<List<dynamic>>((ref) async {
  final podcastIndexService = ref.read(fyydProvider);
  return await podcastIndexService.getFeaturedPodcasts();
});

class AddPodcastPage extends ConsumerStatefulWidget {
  const AddPodcastPage({super.key});

  @override
  ConsumerState createState() => _AddPodcastPageState();
}

class _AddPodcastPageState extends ConsumerState<AddPodcastPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchFyydPodcasts(String query) async {
    if (query.trim().isEmpty) return;

    final dialogContext = context;
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );

    try {
      final podcasts = await ref.read(fyydProvider).searchPodcasts(query);

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);

        if (podcasts.isEmpty) {
          if (!Platform.isAndroid && !Platform.isIOS) {
            ref.read(notificationServiceProvider).showNotification(
                  'OpenAir ${Translations.of(dialogContext).text('notification')}',
                  Translations.of(dialogContext).text('noPodcastsFound'),
                );
          } else {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                content: Text(
                    Translations.of(dialogContext).text('noPodcastsFound')),
              ),
            );
          }
        } else {
          Navigator.of(dialogContext).push(
            MaterialPageRoute(
              builder: (context) => FyydSearchPage(
                podcasts: podcasts,
                searchWord: query,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to find podcasts: $e');
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
    }
  }

  void _showRssDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rss_feed_rounded,
              color: Theme.of(dialogContext).colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          title: Text(
            Translations.of(dialogContext).text('addPodcastByRssUrl'),
          ),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.85,
            child: TextField(
              maxLength: 256,
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.link_rounded,
                  color: Theme.of(dialogContext).colorScheme.primary,
                ),
                labelText: Translations.of(dialogContext).text('rssUrl'),
                suffix: IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.clear_rounded),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(Translations.of(dialogContext).text('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final url = controller.text.trim();
                if (url.isEmpty || !dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  return;
                }
                Navigator.pop(dialogContext);

                final success = await ref
                    .read(audioProvider)
                    .addPodcastByRssUrl(url, context);

                if (!mounted) return;
                _showResultDialog(success);
              },
              child: Text(Translations.of(dialogContext).text('add')),
            ),
          ],
        );
      },
    );
  }

  void _showPodcastIndexDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              color: Theme.of(dialogContext).colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          title: Text(
            Translations.of(dialogContext).text('searchPodcastIndex'),
          ),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.85,
            child: TextField(
              maxLength: 256,
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.title_rounded,
                  color: Theme.of(dialogContext).colorScheme.primary,
                ),
                labelText: Translations.of(dialogContext).text('title'),
                suffix: IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.clear_rounded),
                ),
              ),
              onSubmitted: (value) => _searchPodcastIndex(value, dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(Translations.of(dialogContext).text('cancel')),
            ),
            FilledButton(
              onPressed: () =>
                  _searchPodcastIndex(controller.text.trim(), dialogContext),
              child: Text(Translations.of(dialogContext).text('search')),
            ),
          ],
        );
      },
    );
  }

  void _searchPodcastIndex(String query, BuildContext dialogContext) async {
    if (query.isEmpty) return;

    if (dialogContext.mounted) Navigator.pop(dialogContext);

    final pageContext = context;
    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (loadingContext) => const LoadingDialog(),
    );

    try {
      final podcast =
          await ref.read(podcastIndexProvider).searchPodcasts(query);
      final podcasts = FetchDataModel.fromJson(podcast);

      if (pageContext.mounted) {
        Navigator.pop(pageContext);
        Navigator.of(pageContext).push(
          MaterialPageRoute(
            builder: (context) => PodcastIndexSearchPage(
              podcasts: podcasts,
              searchWord: query,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to search Podcast Index: $e');
      if (pageContext.mounted) {
        Navigator.pop(pageContext);
      }
    }
  }

  void _showResultDialog(bool success) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: success
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: success
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
              size: 28,
            ),
          ),
          title: Text(
            success
                ? Translations.of(dialogContext).text('subscribed')
                : Translations.of(dialogContext).text('oopsAnErrorOccurred'),
          ),
          content: Text(
            success
                ? Translations.of(dialogContext)
                    .text('importedPodcastsFromOpml')
                : Translations.of(dialogContext).text('errorAddingPodcast'),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(Translations.of(dialogContext).text('ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importOpml() async {
    final success =
        await ref.read(audioProvider).importPodcastFromOpml(context);
    if (!mounted) return;
    _showResultDialog(success);
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('addPodcast'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                keyboardType: TextInputType.webSearch,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary,
                  ),
                  hintText: Translations.of(context).text('searchPodcastFyyd'),
                  suffixIcon: IconButton(
                    onPressed: _searchController.clear,
                    icon: const Icon(Icons.clear_rounded),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _searchFyydPodcasts,
              ),
              const SizedBox(height: 24),

              // Connection Status & Featured Podcasts
              Consumer(
                builder: (context, ref, _) {
                  final getConnectionStatusValue =
                      ref.watch(getConnectionStatusProvider);

                  return getConnectionStatusValue.when(
                    data: (isConnected) {
                      if (!isConnected) {
                        return const NoConnection();
                      }

                      final podcastDataAsyncValue =
                          ref.watch(podcastDataFeaturedProvider);

                      return podcastDataAsyncValue.when(
                        data: (snapshot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Translations.of(context).text('discoverMore'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 336,
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisExtent: 100,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: snapshot.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        final xmlString = await ref
                                            .read(fyydProvider)
                                            .getPodcastXml(
                                                snapshot[index]['xmlURL']);

                                        var rssFeed = RssFeed.parse(xmlString);

                                        final podcast = SubscriptionModel(
                                          id: snapshot[index]['id'],
                                          feedUrl: snapshot[index]['xmlURL'],
                                          title: rssFeed.title!,
                                          description: rssFeed.description!,
                                          author: rssFeed.author ?? 'unknown',
                                          imageUrl: snapshot[index]['imgURL'],
                                          episodeCount: rssFeed.items!.length,
                                          artwork: snapshot[index]['imgURL'],
                                          updatedAt: DateTime.now(),
                                        );

                                        ref.read(audioProvider).currentPodcast =
                                            PodcastModel.fromJson(
                                                podcast.toJson());

                                        if (context.mounted) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EpisodesPage(
                                                podcast: PodcastModel.fromJson(
                                                    podcast.toJson()),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: cardImageShadow.withValues(
                                                  alpha: 0.3),
                                              blurRadius: blurRadius,
                                            )
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            memCacheHeight:
                                                cardImageHeight.ceil(),
                                            memCacheWidth:
                                                cardImageWidth.ceil(),
                                            imageUrl: snapshot[index]['imgURL'],
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.brown,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.error_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      Translations.of(context)
                                          .text('discoveryPoweredByFyyd'),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiscoveryPage(
                                            podcastDataAsyncValue:
                                                podcastDataAsyncValue),
                                      ),
                                    ),
                                    icon: const Icon(Icons.double_arrow_rounded,
                                        size: 18),
                                    label: Text(
                                      Translations.of(context)
                                          .text('discoverMore'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                        loading: () => SizedBox(
                          height: 336,
                          child: GridView.builder(
                            itemCount: 12,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisExtent: 100,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: theme.cardColor,
                                highlightColor: highlightColor!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: highlightColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action Cards
              Text(
                Translations.of(context).text('addPodcast'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.rss_feed_rounded,
                title: Translations.of(context).text('addPodcastByRssUrl'),
                subtitle: Translations.of(context).text('rssFeed'),
                onTap: _showRssDialog,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.search_rounded,
                title: Translations.of(context).text('searchPodcastIndex'),
                subtitle: Translations.of(context).text('search'),
                onTap: _showPodcastIndexDialog,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.file_download_outlined,
                title: Translations.of(context).text('importPodcastListOpml'),
                subtitle: Translations.of(context).text('opml'),
                onTap: _importOpml,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ToggleBanner(),
    );
  }
}
