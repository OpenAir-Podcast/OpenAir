import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
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
    final audioState = ref.watch(audioProvider);
    final currentEpisode = audioState.currentEpisode;
    final subsAsync = ref.watch(subscriptionsProvider);

    if (currentEpisode == null || currentEpisode.isEmpty) {
      return const SizedBox.shrink();
    }

    String podcastTitle = currentEpisode['podcastTitle']?.toString() ?? '';
    if (podcastTitle.isEmpty) {
      subsAsync.whenData((subs) {
        final podcastId = currentEpisode['podcastId'];
        if (podcastId != null) {
          for (final entry in subs.entries) {
            if (entry.value.id.toString() == podcastId.toString()) {
              podcastTitle = entry.value.title;
              break;
            }
          }
        }
      });
    }
    if (podcastTitle.isEmpty) {
      podcastTitle = currentEpisode['author']?.toString() ??
          Translations.of(context).text('unknown');
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPlayer(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 6.0),
                  child: Row(
                    children: [
                      // Thumbnail
                      Hero(
                        tag: 'player_art',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            width: 48,
                            height: 48,
                            imageUrl: currentEpisode['feedImage'] ??
                                currentEpisode['image'] ??
                                '',
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.onSurface,
                              child: const Icon(Icons.podcasts, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentEpisode['title'] ?? '',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              podcastTitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play/Pause Button
                      IconButton(
                        onPressed: () {
                          audioState.audioState == 'Play'
                              ? audioState.playerPauseButtonClicked()
                              : audioState.playerResumeButtonClicked();
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            audioState.audioState == 'Play'
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            key: ValueKey(audioState.audioState),
                            size: 28,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Slim Progress Bar at the bottom
                SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    value: audioState.podcastCurrentPositionInMilliseconds,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
