import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_provider.dart';
import 'package:podcastindex_dart/src/entity/episode.dart';

class PlayButtonWidget extends ConsumerStatefulWidget {
  PlayButtonWidget({
    super.key,
    required this.episodeItem,
  });

  final Episode episodeItem;

  PlayingStatus playStatus = PlayingStatus.detail;

  @override
  PlayButtonWidgetState createState() => PlayButtonWidgetState();
}

class PlayButtonWidgetState extends ConsumerState<PlayButtonWidget> {
  @override
  Widget build(BuildContext context) {
    const double paddingSpace = 8.0;

    if (widget.episodeItem != ref.watch(podcastProvider).currentEpisode) {
      if (ref.watch(podcastProvider).isPlaying == PlayingStatus.playing) {
        widget.playStatus = PlayingStatus.detail;
      } else if (ref.watch(podcastProvider).isPlaying ==
              PlayingStatus.buffering &&
          ref.watch(podcastProvider).nextEpisode == widget.episodeItem) {
        widget.playStatus = PlayingStatus.buffering;
      } else if (ref.watch(podcastProvider).isPlaying ==
              PlayingStatus.buffering &&
          ref.watch(podcastProvider).currentEpisode == null &&
          ref.watch(podcastProvider).nextEpisode == null) {
        widget.playStatus = PlayingStatus.buffering;
      }
    }
    // EpisodeItem is the same as currentEpisode
    else {
      if (ref.watch(podcastProvider).isPlaying == PlayingStatus.playing) {
        widget.playStatus = PlayingStatus.playing;
      }
      if (ref.watch(podcastProvider).isPlaying == PlayingStatus.paused) {
        widget.playStatus = PlayingStatus.paused;
      }
    }

    if (widget.playStatus case PlayingStatus.detail) {
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
                .watch(podcastProvider)
                .getPodcastDuration(widget.episodeItem.enclosureLength!),
          ),
        ],
      );
    } else if (widget.playStatus case PlayingStatus.paused) {
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
            ref.watch(podcastProvider).currentPodcastTimeRemaining!,
          ),
        ],
      );
    } else if (widget.playStatus case PlayingStatus.buffering) {
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
