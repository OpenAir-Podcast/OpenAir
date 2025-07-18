import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';

class PlayButtonWidget extends ConsumerStatefulWidget {
  const PlayButtonWidget({
    super.key,
    required this.episodeItem,
  });

  final Map<String, dynamic> episodeItem;

  @override
  PlayButtonWidgetState createState() => PlayButtonWidgetState();
}

class PlayButtonWidgetState extends ConsumerState<PlayButtonWidget> {
  PlayingStatus playStatus = PlayingStatus.detail;

  @override
  Widget build(BuildContext context) {
    const double paddingSpace = 8.0;

    if (widget.episodeItem['guid'] !=
        ref.watch(openAirProvider).currentEpisode!['guid']) {
      if (ref.watch(openAirProvider).isPlaying == PlayingStatus.playing) {
        playStatus = PlayingStatus.detail;
      }
    }
    // EpisodeItem is the same as currentEpisode
    else {
      if (ref.watch(openAirProvider).isPlaying == PlayingStatus.playing) {
        playStatus = PlayingStatus.playing;
      } else if (ref.watch(openAirProvider).isPlaying == PlayingStatus.paused) {
        playStatus = PlayingStatus.paused;
      } else if (ref.watch(openAirProvider).isPlaying == PlayingStatus.stop) {
        playStatus = PlayingStatus.detail;
      } else if (ref.watch(openAirProvider).isPlaying ==
          PlayingStatus.buffering) {
        playStatus = PlayingStatus.buffering;
      }
    }

    if (playStatus case PlayingStatus.detail) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingSpace,
            ),
            child: Icon(Icons.play_arrow_rounded),
          ),
          Text(
            ref
                .watch(openAirProvider)
                .getPodcastDuration(widget.episodeItem['enclosureLength']),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else if (playStatus case PlayingStatus.paused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingSpace,
            ),
            child: Icon(Icons.timelapse_rounded),
          ),
          Text(
            ref.watch(openAirProvider).currentPodcastTimeRemaining!,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else if (playStatus case PlayingStatus.buffering) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 35.0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: paddingSpace,
              ),
              child: LinearProgressIndicator(),
            ),
          ),
          Text('Buffering'),
        ],
      );
    }

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paddingSpace,
          ),
          child: Icon(Icons.stream_rounded),
        ),
        Text('Playing'),
      ],
    );
  }
}
