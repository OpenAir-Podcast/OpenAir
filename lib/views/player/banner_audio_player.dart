import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_provider.dart';

class BannerAudioPlayer extends ConsumerStatefulWidget {
  const BannerAudioPlayer({
    super.key,
  });

  @override
  BannerAudioPlayerState createState() => BannerAudioPlayerState();
}

class BannerAudioPlayerState extends ConsumerState<BannerAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          color: Colors.teal,
          child: Column(
            children: [
              ListTile(
                minTileHeight: 70.0,
                onTap: () {
                  ref.read(podcastProvider.notifier).bannerControllerClicked();
                },
                // TODO: Figure out how to show the artwork
                leading: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(
                        ref.watch(podcastProvider).currentPodcast!.artwork,
                      ),
                      fit: BoxFit.cover, // Adjust fit as needed
                    ),
                  ),
                  width: 62.0,
                  height: 62.0,
                ),
                title: SizedBox(
                  height: 42.0,
                  child: Text(
                    ref.watch(podcastProvider).currentEpisode!.title!,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    ref.watch(podcastProvider).audioState == 'Play'
                        ? ref
                            .read(podcastProvider.notifier)
                            .playerPauseButtonClicked()
                        : ref
                            .read(podcastProvider.notifier)
                            .playerPlayButtonClicked(
                              ref.watch(podcastProvider).currentEpisode!,
                            );
                  },
                  icon: ref.watch(podcastProvider).audioState == 'Play'
                      ? const Icon(Icons.pause_rounded)
                      : const Icon(Icons.play_arrow_rounded),
                ),
              ),
              LinearProgressIndicator(
                value: ref
                    .read(podcastProvider.notifier)
                    .podcastCurrentPositionInMilliseconds,
              ),
            ],
          ),
        );
      },
    );
  }
}
