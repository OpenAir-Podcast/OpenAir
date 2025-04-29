import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/player/main_player.dart';

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPlayer(),
                    ),
                  );
                },
                leading: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(
                        ref.watch(openAirProvider).currentPodcast!['image'],
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
                    ref.watch(openAirProvider).currentEpisode!['title'],
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
                    ref.watch(openAirProvider).audioState == 'Play'
                        ? ref
                            .read(openAirProvider.notifier)
                            .playerPauseButtonClicked()
                        : ref
                            .read(openAirProvider.notifier)
                            .playerPlayButtonClicked(
                              ref.watch(openAirProvider).currentEpisode!,
                            );
                  },
                  icon: ref.watch(openAirProvider).audioState == 'Play'
                      ? const Icon(Icons.pause_rounded)
                      : const Icon(Icons.play_arrow_rounded),
                ),
              ),
              LinearProgressIndicator(
                value: ref
                    .read(openAirProvider.notifier)
                    .podcastCurrentPositionInMilliseconds,
              ),
            ],
          ),
        );
      },
    );
  }
}
