import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_downloaded_episodes.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/episode_card_grid.dart';
import 'package:openair/views/widgets/unified_episode_card.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState createState() => _DownloadsState();
}

class _DownloadsState extends ConsumerState<DownloadsPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<DownloadModel>> episodesValue =
        ref.watch(getDownloadsProvider);

    return episodesValue.when(
      data: (List<DownloadModel> data) {
        if (data.isEmpty) {
          return const NoDownloadedEpisodes();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('downloads')),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  onPressed: () => ref.invalidate(getDownloadsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
          ),
          body: _buildDownloadsList(context, data),
          bottomNavigationBar: _buildBottomBar(context, ref),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(Translations.of(context).text('downloads'))),
        body: _ErrorView(error: error.toString()),
      ),
    );
  }

  Widget _buildDownloadsList(BuildContext context, List<DownloadModel> data) {
    final isWide = !Platform.isAndroid && !Platform.isIOS ||
        wideScreenMinWidth < MediaQuery.sizeOf(context).width;

    if (isWide) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisExtent: 312.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        cacheExtent: cacheExtent,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final author = data[index].author.isNotEmpty == true
              ? data[index].author
              : Translations.of(context).text('unknown');

          return EpisodeCardGrid(
            episodeItem: data[index].toJson(),
            title: data[index].title,
            author: author,
            imageUrl: data[index].image,
            podcast: PodcastModel.fromJson(data[index].toJson()),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      cacheExtent: cacheExtent,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final author = data[index].author.isNotEmpty == true
            ? data[index].author
            : Translations.of(context).text('unknown');

        return UnifiedEpisodeCard(
          episodeItem: data[index].toJson(),
          podcast: PodcastModel.fromJson(data[index].toJson()),
          title: data[index].title,
          author: author,
          showAuthor: true,
        );
      },
    );
  }

  Widget? _buildBottomBar(BuildContext context, WidgetRef ref) {
    final isPodcastSelected = ref.watch(
      audioProvider.select((p) => p.isPodcastSelected),
    );

    if (!isPodcastSelected) return null;

    return SizedBox(
      height: bannerAudioPlayerHeight,
      child: const BannerAudioPlayer(),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            Translations.of(context).text('oopsTryAgainLater'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(getDownloadsProvider),
            child: Text(Translations.of(context).text('retry')),
          ),
        ],
      ),
    );
  }
}
