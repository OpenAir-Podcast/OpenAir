import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                        imageUrl:
                            ref.watch(auidoProvider).currentPodcast!.imageUrl,
                      ),
                    ),
                  ),
                  // Podcast Title
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EpisodeDetail(
                          episodeItem: ref.watch(auidoProvider).currentEpisode!,
                        ),
                      ),
                    ),
                    child: Text(
                      ref.watch(auidoProvider).currentEpisode!['title'],
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
                                  ref.watch(auidoProvider).currentPodcast!),
                        ),
                      );
                    },
                    child: Text(
                      ref.watch(auidoProvider).currentEpisode!['author'] ??
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
                        .watch(auidoProvider)
                        .podcastCurrentPositionInMilliseconds,
                    onChanged: (value) {
                      ref.read(auidoProvider).mainPlayerSliderClicked(
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
                              .watch(auidoProvider)
                              .currentPlaybackPositionString,
                        ),
                        //
                        // Spacer
                        //
                        Text(
                          '-${ref.watch(auidoProvider).currentPlaybackRemainingTimeString}',
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
                        .read(auidoProvider)
                        .rewindButtonClicked, // Use read for actions
                    icon: const SizedBox(
                      width: 52.0,
                      height: 52.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.fast_rewind_rounded),
                          Positioned(
                            top: 30.0,
                            left: 25.0,
                            right: 0.0,
                            child: Icon(Icons.timer_10_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Play/pause button
                  IconButton(
                    onPressed: () async {
                      ref.read(auidoProvider).audioState ==
                              'Play' // Use read for state check in action
                          ? ref
                              .read(auidoProvider) // Use read for actions
                              .playerPauseButtonClicked()
                          : ref.read(auidoProvider).playerPlayButtonClicked(
                                // Use read for actions
                                ref.read(auidoProvider).currentEpisode!,
                              );
                    }, // Add play/pause functionality
                    icon: ref.watch(auidoProvider).audioState == 'Play'
                        ? const Icon(Icons.pause_rounded)
                        : const Icon(Icons.play_arrow_rounded),
                    iconSize: 48.0,
                  ),
                  // Fast forward button
                  IconButton(
                    onPressed: ref
                        .read(auidoProvider)
                        .fastForwardButtonClicked, // Use read for actions
                    icon: const SizedBox(
                      width: 52.0,
                      height: 52.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.fast_forward_rounded),
                          Positioned(
                            top: 30.0,
                            left: 25.0,
                            right: 0.0,
                            child: Icon(Icons.timer_10_rounded),
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
                        .read(auidoProvider.notifier)
                        .audioSpeedButtonClicked(),
                    child: Text(
                      ref.watch(auidoProvider).audioSpeedButtonLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => {}, // Add fast-forward functionality
                    icon: const Icon(Icons.timer_outlined),
                  ),
                  IconButton(
                    onPressed: () => {}, // Add fast-forward functionality
                    icon: const Icon(Icons.cast),
                  ),
                  IconButton(
                    onPressed: () => {}, // Add fast-forward functionality
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
