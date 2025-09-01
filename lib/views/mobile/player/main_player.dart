import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/mobile/main_pages/episode_detail.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';

class MainPlayer extends ConsumerStatefulWidget {
  const MainPlayer({super.key});

  @override
  MainPlayerState createState() => MainPlayerState();
}

class MainPlayerState extends ConsumerState<MainPlayer> {
  final double imageSize = 250.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      width: imageSize,
                      height: imageSize,
                      child: CachedNetworkImage(
                        memCacheHeight: imageSize.ceil(),
                        memCacheWidth: imageSize.ceil(),
                        imageUrl: ref
                            .watch(audioProvider)
                            .currentEpisode!['feedImage'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  // Podcast Title
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EpisodeDetail(
                          episodeItem: ref.watch(audioProvider).currentEpisode!,
                        ),
                      ),
                    ),
                    child: Text(
                      ref.watch(audioProvider).currentEpisode!['title'],
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Podcast Author
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EpisodesPage(
                              podcast:
                                  ref.watch(audioProvider).currentPodcast!),
                        ),
                      );
                    },
                    child: Text(
                      ref.watch(audioProvider).currentEpisode!['author'] ??
                          'Unknown',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  // Seek bar
                  Slider(
                    min: 0.0,
                    max: 1.0,
                    value: ref
                        .watch(audioProvider)
                        .podcastCurrentPositionInMilliseconds,
                    onChanged: (value) {
                      ref.read(audioProvider).mainPlayerSliderClicked(
                          value); // Use read for actions
                    },
                  ),
                  // Seek positions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ref
                              .watch(audioProvider)
                              .currentPlaybackPositionString,
                        ),
                        //
                        // Spacer
                        //
                        Text(
                          '-${ref.watch(audioProvider).currentPlaybackRemainingTimeString}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Playback controls
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rewind button
                  IconButton(
                    onPressed: ref
                        .read(audioProvider)
                        .rewindButtonClicked, // Use read for actions
                    icon: SizedBox(
                      width: 52.0,
                      height: 52.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.fast_rewind_rounded),
                          Positioned(
                            top: 30.0,
                            left: 18.0,
                            right: 0.0,
                            child: Text(
                              '-${rewindInterval}s',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Play/pause button
                  IconButton(
                    onPressed: () async {
                      ref.read(audioProvider).audioState ==
                              'Play' // Use read for state check in action
                          ? ref
                              .read(audioProvider) // Use read for actions
                              .playerPauseButtonClicked()
                          : ref.read(audioProvider).playerPlayButtonClicked(
                                // Use read for actions
                                ref.read(audioProvider).currentEpisode!,
                              );
                    }, // Add play/pause functionality
                    icon: ref.watch(audioProvider).audioState == 'Play'
                        ? const Icon(Icons.pause_rounded)
                        : const Icon(Icons.play_arrow_rounded),
                    iconSize: 48.0,
                  ),
                  // Fast forward button
                  IconButton(
                    onPressed: ref
                        .read(audioProvider)
                        .fastForwardButtonClicked, // Use read for actions
                    icon: SizedBox(
                      width: 52.0,
                      height: 52.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.fast_forward_rounded),
                          Positioned(
                            top: 30.0,
                            left: 18.0,
                            right: 0.0,
                            child: Text(
                              '+${fastForwardInterval}s',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slider for progress bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Playback speed
                  TextButton(
                    onPressed: () => ref
                        .read(audioProvider.notifier)
                        .audioSpeedButtonClicked(),
                    child: Text(
                      playbackSpeed,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => {}, // Add timer functionality
                    icon: const Icon(Icons.timer_outlined),
                  ),
                  IconButton(
                    onPressed: () => {}, // Add favourite functionality
                    icon: const Icon(Icons.favorite_border_rounded),
                  ),
                  IconButton(
                    onPressed: () => {}, // Add more functionality
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
