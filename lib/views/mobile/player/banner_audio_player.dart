import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/mobile/player/main_player.dart';

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
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).bottomAppBarTheme.color
          : Theme.of(context).colorScheme.primaryContainer,
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
              width: 62.0,
              height: 62.0,
              decoration: BoxDecoration(
                color: cardImageShadow,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: CachedNetworkImage(
                memCacheHeight: 62,
                memCacheWidth: 62,
                imageUrl:
                    ref.watch(audioProvider).currentEpisode!['feedImage'] ??
                        ref.watch(audioProvider).currentEpisode!['image'],
                fit: BoxFit.fill,
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  size: 48.0,
                ),
              ),
            ),
            title: SizedBox(
              height: 42.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.watch(audioProvider).currentEpisode!['title'],
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  Text(
                    ref.watch(audioProvider).currentEpisode!['author'] ??
                        'Unknown',
                    style: const TextStyle(
                      fontSize: 14.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                ref.read(audioProvider).audioState == 'Play'
                    ? ref.read(audioProvider).playerPauseButtonClicked()
                    : ref.read(audioProvider).playerPlayButtonClicked(
                        ref.read(audioProvider).currentEpisode!);
              },
              icon: ref.watch(audioProvider).audioState == 'Play'
                  ? const Icon(Icons.pause_rounded)
                  : const Icon(Icons.play_arrow_rounded),
            ),
          ),
          LinearProgressIndicator(
            value: ref.watch(audioProvider
                .select((p) => p.podcastCurrentPositionInMilliseconds)),
          ),
        ],
      ),
    );
  }
}
