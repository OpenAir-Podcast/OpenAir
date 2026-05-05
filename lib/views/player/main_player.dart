import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'dart:ui';

import 'package:openair/views/main_pages/episodes_page.dart';

class MainPlayer extends ConsumerStatefulWidget {
  const MainPlayer({super.key});

  @override
  MainPlayerState createState() => MainPlayerState();
}

class MainPlayerState extends ConsumerState<MainPlayer> {
  final double imageSize = 250.0;

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final currentEpisode = audioState.currentEpisode;
    final subsAsync = ref.watch(subscriptionsProvider);

    if (currentEpisode == null || currentEpisode.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String getPodcastTitle(Map<String, dynamic> episode,
        AsyncValue<Map<String, SubscriptionModel>> subs) {
      if (episode['podcastTitle'] != null) return episode['podcastTitle'];
      return subs.when(
        data: (subsMap) {
          final podcastId = episode['podcastId'];
          if (podcastId != null) {
            for (final entry in subsMap.entries) {
              if (entry.value.id.toString() == podcastId.toString()) {
                return entry.value.title;
              }
            }
          }
          return episode['author']?.toString() ??
              Translations.of(context).text('unknown');
        },
        loading: () => episode['author']?.toString() ?? '',
        error: (_, __) =>
            episode['author']?.toString() ??
            Translations.of(context).text('unknown'),
      );
    }

    final podcastTitle = getPodcastTitle(currentEpisode, subsAsync);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Blur background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),
            SafeArea(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Artwork with hero and image
                      Hero(
                        tag: 'player_art',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: CachedNetworkImage(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.width * 0.8,
                              imageUrl: currentEpisode['feedImage'] ??
                                  currentEpisode['image'] ??
                                  '',
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceContainer,
                                child: const Icon(Icons.podcasts, size: 100),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        currentEpisode['title'] ?? '',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Author with navigation
                      GestureDetector(
                        onTap: () {
                          if (audioState.currentPodcast != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EpisodesPage(
                                    podcast: audioState.currentPodcast!),
                              ),
                            );
                          }
                        },
                        child: Text(
                          podcastTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Seek Bar
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                                elevation: 0,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              thumbColor: theme.colorScheme.primary,
                            ),
                            child: Slider(
                              min: 0.0,
                              max: 1.0,
                              value: audioState
                                  .podcastCurrentPositionInMilliseconds,
                              onChanged: (value) => audioState.seekTo(value),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  audioState.currentPlaybackPositionString,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  audioState.currentPlaybackDurationString ??
                                      '00:00:00',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Main Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded,
                                size: 36),
                            onPressed: () =>
                                audioState.playPreviousEpisode(context),
                          ),
                          _buildControlButton(context, Icons.replay_10_rounded,
                              () => audioState.rewind()),
                          // Play/Pause button
                          GestureDetector(
                            onTap: () {
                              audioState.audioState == 'Play'
                                  ? audioState.playerPauseButtonClicked()
                                  : audioState.playerResumeButtonClicked();
                            },
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                audioState.audioState == 'Play'
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 48,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          _buildControlButton(context, Icons.forward_10_rounded,
                              () => audioState.fastForward()),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, size: 36),
                            onPressed: () =>
                                audioState.playNextEpisode(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Bottom Tools
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () => audioState.cyclePlaybackSpeed(),
                            child: Text(
                              playbackSpeedConfig,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.timer_outlined),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border_rounded),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.playlist_play_rounded,
                                size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 32),
      onPressed: onTap,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
