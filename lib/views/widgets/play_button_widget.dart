import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/audio_provider.dart';

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
        ref.watch(audioProvider).currentEpisode!['guid']) {
      if (ref.watch(audioProvider).isPlaying == PlayingStatus.playing) {
        playStatus = PlayingStatus.detail;
      }
    } else {
      if (ref.watch(audioProvider).isPlaying == PlayingStatus.playing) {
        playStatus = PlayingStatus.playing;
      } else if (ref.watch(audioProvider).isPlaying == PlayingStatus.paused) {
        playStatus = PlayingStatus.paused;
      } else if (ref.watch(audioProvider).isPlaying == PlayingStatus.stop) {
        playStatus = PlayingStatus.detail;
      } else if (ref.watch(audioProvider).isPlaying ==
          PlayingStatus.buffering) {
        playStatus = PlayingStatus.buffering;
      }
    }

    dynamic episodeDuration;

    if (widget.episodeItem['duration'].runtimeType == String) {
      episodeDuration = int.parse(widget.episodeItem['duration']);
    } else if (widget.episodeItem['duration'].runtimeType == int) {
      episodeDuration = widget.episodeItem['duration'];
    }

    if (playStatus case PlayingStatus.detail) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow_rounded),
          Text(
            ref.watch(audioProvider).convertSecondsToDuration(
                  episodeDuration,
                  context,
                ),
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
            ref.watch(audioProvider).currentPodcastTimeRemaining!,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paddingSpace,
          ),
          child: Icon(Icons.stream_rounded),
        ),
        Text(Translations.of(context).text('playing')),
      ],
    );
  }
}
