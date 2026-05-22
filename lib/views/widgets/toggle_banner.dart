import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/player/banner_audio_player.dart';

class ToggleBanner extends ConsumerStatefulWidget {
  const ToggleBanner({super.key});

  @override
  ConsumerState<ToggleBanner> createState() => _ToggleBannerState();
}

class _ToggleBannerState extends ConsumerState<ToggleBanner> {
  @override
  Widget build(BuildContext context) {
    final isPodcastPlaying =
        ref.watch(audioProvider.select((p) => p.isPodcastSelected));

    final isBannerDismissed = ref.watch(
      audioProvider.select((p) => p.isBannerDismissed),
    );

    return SizedBox(
      height: isPodcastPlaying && !isBannerDismissed
          ? bannerAudioPlayerHeight
          : 0.0,
      child: isPodcastPlaying && !isBannerDismissed
          ? const BannerAudioPlayer()
          : const SizedBox.shrink(),
    );
  }
}
