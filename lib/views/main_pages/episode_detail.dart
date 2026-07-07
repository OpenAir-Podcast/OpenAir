import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:openair/model/person_model.dart';
import 'package:openair/model/soundbite_model.dart';
import 'package:openair/views/widgets/podcast_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/widgets/play_button_widget.dart';
import 'package:openair/views/widgets/toggle_banner.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeDetail extends ConsumerStatefulWidget {
  const EpisodeDetail({
    super.key,
    this.episodeItem,
    this.podcast,
    this.author,
  });

  final Map<String, dynamic>? episodeItem;
  final PodcastModel? podcast;
  final String? author;

  @override
  EpisodeDetailState createState() => EpisodeDetailState();
}

class EpisodeDetailState extends ConsumerState<EpisodeDetail> {
  List<Person> _persons = [];
  List<Soundbite> _soundbites = [];

  @override
  void initState() {
    super.initState();
    _parseMetadata();
  }

  void _parseMetadata() {
    final item = widget.episodeItem;
    if (item != null) {
      final rawPersons = item['persons'];
      if (rawPersons is List) {
        _persons = rawPersons
            .map((e) => Person.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      final rawSoundbites = item['soundbites'];
      if (rawSoundbites is List) {
        _soundbites = rawSoundbites
            .map((e) => Soundbite.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map> queueListAsync = ref.watch(getQueueProvider);

    final AsyncValue<List<DownloadModel>> downloadedListAsync =
        ref.watch(getDownloadsProvider);

    final AsyncValue favoriteListAsync = ref.watch(getFavoriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.podcast!.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: 62.0,
                      height: 62.0,
                      decoration: BoxDecoration(
                        color: cardImageShadow,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: podcastImage(
                        widget.episodeItem!['feedImage'] ??
                            widget.episodeItem!['image'] ??
                            '',
                        width: 62,
                        height: 62,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Episode Title
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 140.0,
                          child: Text(
                            widget.episodeItem!['title'],
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        // Author
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 140.0,
                          child: Text(
                            widget.author ??
                                widget.podcast!.author ??
                                widget.episodeItem!['author'] ??
                                Translations.of(context).text('unknown'),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // Podcast Published Date
                        Text(
                          ref
                              .watch(audioProvider)
                              .getPodcastPublishedDateFromEpoch(
                                  widget.episodeItem!['datePublished']),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Play button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 1.0,
                          shape: const StadiumBorder(
                            side: BorderSide(
                              width: 1.0,
                            ),
                          ),
                        ),
                        onPressed: () {
                          ref.read(audioProvider).playerPlayButtonClicked(
                                widget.episodeItem!,
                                context,
                              );

                          ref.watch(audioProvider).currentEpisode!['author'] =
                              widget.podcast!.author;
                        },
                        child: PlayButtonWidget(
                          episodeItem: widget.episodeItem!,
                        ),
                      ),
                    ),
                    // Queue Button
                    queueListAsync.when(
                      data: (data) {
                        final isQueued =
                            data.containsKey(widget.episodeItem!['guid']);

                        return IconButton(
                          tooltip: Translations.of(context).text('addToQueue'),
                          onPressed: () {
                            isQueued
                                ? ref.read(audioProvider).removeFromQueue(
                                    widget.episodeItem!['guid'])
                                : ref.read(audioProvider).addToQueue(
                                      widget.episodeItem!,
                                      widget.podcast,
                                      context,
                                    );

                            if (!Platform.isAndroid && !Platform.isIOS) {
                              ref
                                  .read(notificationServiceProvider)
                                  .showNotification(
                                    'OpenAir ${Translations.of(context).text('notification')}',
                                    isQueued
                                        ? '${Translations.of(context).text('removedFromQueue')}: ${widget.episodeItem!['title']}'
                                        : '${Translations.of(context).text('addedToQueue')}: ${widget.episodeItem!['title']}',
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isQueued
                                        ? '${Translations.of(context).text('removedFromQueue')}: ${widget.episodeItem!['title']}'
                                        : '${Translations.of(context).text('addedToQueue')}: ${widget.episodeItem!['title']}',
                                  ),
                                ),
                              );
                            }

                            if (enqueueDownloadedConfig) {
                              ref
                                  .watch(openAirProvider)
                                  .downloadEnqueue(context);
                            }

                            ref.invalidate(getQueueProvider);
                          },
                          icon: isQueued
                              ? const Icon(Icons.playlist_add_check_rounded)
                              : const Icon(Icons.playlist_add_rounded),
                        );
                      },
                      error: (error, stackTrace) {
                        debugPrint('Error in queueListAsync: $error');
                        return IconButton(
                          tooltip: Translations.of(context).text('addToQueue'),
                          onPressed: () {},
                          icon: const Icon(Icons.error_outline_rounded),
                        );
                      },
                      loading: () {
                        // Handle loading by showing previous state's icon, disabled
                        final previousList = queueListAsync.value;
                        final isQueuedPreviously = previousList
                                ?.containsKey(widget.episodeItem!['guid']) ??
                            false;

                        return IconButton(
                          tooltip: Translations.of(context).text('addToQueue'),
                          onPressed: null, // Disable button while loading
                          icon: isQueuedPreviously
                              ? const Icon(Icons.playlist_add_check_rounded)
                              : const Icon(Icons.playlist_add_rounded),
                        );
                      },
                    ),
                    // Download Button
                    if (!kIsWeb)
                      downloadedListAsync.when(
                        data: (downloads) {
                          final isDownloaded = downloads.any(
                              (d) => d.guid == widget.episodeItem!['guid']);

                          final isDownloading = ref.watch(audioProvider.select(
                              (p) => p.downloadingPodcasts
                                  .contains(widget.episodeItem!['guid'])));

                          IconData iconData;
                          String tooltip;
                          VoidCallback? onPressed;

                          if (isDownloading) {
                            iconData = Icons.downloading_rounded;
                            tooltip =
                                Translations.of(context).text('downloading');
                            onPressed = null;
                          } else if (isDownloaded) {
                            iconData = Icons.download_done_rounded;
                            tooltip =
                                Translations.of(context).text('deleteDownload');

                            onPressed = () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: Text(
                                      Translations.of(dialogContext)
                                          .text('confirmDeletion'),
                                    ),
                                    content: Text(
                                      '${Translations.of(dialogContext).text('areYouSureYouWantToRemoveDownload')} \'${widget.episodeItem!['title']}\'?',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          Translations.of(dialogContext)
                                              .text('cancel'),
                                        ),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          Translations.of(dialogContext)
                                              .text('remove'),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(dialogContext).pop();

                                          // Then perform the removal
                                          await ref
                                              .read(audioProvider.notifier)
                                              .removeDownload(
                                                  widget.episodeItem!);

                                          // Show feedback
                                          if (context.mounted) {
                                            if (!Platform.isAndroid &&
                                                !Platform.isIOS) {
                                              ref
                                                  .read(
                                                      notificationServiceProvider)
                                                  .showNotification(
                                                    'OpenAir ${Translations.of(context).text('notification')}',
                                                    '${Translations.of(context).text('removed')} \'${widget.episodeItem!['title']}\'',
                                                  );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${Translations.of(context).text('removed')} \'${widget.episodeItem!['title']}\'',
                                                  ),
                                                ),
                                              );
                                            }
                                          }

                                          ref.invalidate(getDownloadsProvider);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            };
                          }
                          // Episode not downloaded
                          else {
                            iconData = Icons.download_rounded;
                            tooltip =
                                Translations.of(context).text('deleteDownload');

                            onPressed = () {
                              ref.read(audioProvider.notifier).downloadEpisode(
                                    widget.episodeItem!,
                                    widget.podcast!,
                                    context,
                                  );

                              if (receiveNotificationsWhenDownloadConfig) {
                                if (!Platform.isAndroid && !Platform.isIOS) {
                                  ref
                                      .read(notificationServiceProvider)
                                      .showNotification(
                                          'OpenAir ${Translations.of(context).text('notification')}',
                                          '${Translations.of(context).text('downloading')} \'${widget.episodeItem!['title']}\'');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${Translations.of(context).text('downloading')} \'${widget.episodeItem!['title']}\''),
                                    ),
                                  );
                                }
                              }
                            };
                          }

                          return IconButton(
                            tooltip: tooltip,
                            onPressed: onPressed,
                            icon: Icon(iconData),
                          );
                        },
                        error: (e, s) => const IconButton(
                            icon: Icon(Icons.error), onPressed: null),
                        loading: () => const IconButton(
                            icon: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.0)),
                            onPressed: null),
                      ),
                    favoriteListAsync.when(
                      data: (data) {
                        bool isFavorite =
                            data.containsKey(widget.episodeItem!['guid']);

                        return IconButton(
                          tooltip: Translations.of(context).text('favourite'),
                          onPressed: () async {
                            setState(() {
                              if (isFavorite) {
                                ref
                                    .read(audioProvider)
                                    .removeEpisodeFromFavorite(
                                        widget.episodeItem!['guid']);

                                if (context.mounted) {
                                  if (!Platform.isAndroid && !Platform.isIOS) {
                                    ref
                                        .read(notificationServiceProvider)
                                        .showNotification(
                                            'OpenAir ${Translations.of(context).text('notification')}',
                                            '${Translations.of(context).text('removedFromFavorites')}: ${widget.episodeItem!['title']}');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${Translations.of(context).text('removedFromFavorites')}: ${widget.episodeItem!['title']}'),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                ref.read(audioProvider).addEpisodeToFavorite(
                                    widget.episodeItem!, widget.podcast!,
                                    author: widget.episodeItem!['author'] ??
                                        widget.podcast!.author);

                                if (context.mounted) {
                                  if (!Platform.isAndroid && !Platform.isIOS) {
                                    ref
                                        .read(notificationServiceProvider)
                                        .showNotification(
                                          'OpenAir ${Translations.of(context).text('notification')}',
                                          '${Translations.of(context).text('addedToFavorites')}: ${widget.episodeItem!['title']}',
                                        );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${Translations.of(context).text('addedToFavorites')}: ${widget.episodeItem!['title']}',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            });
                          },
                          icon: isFavorite
                              ? const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.redAccent,
                                )
                              : const Icon(Icons.favorite_border_rounded),
                        );
                      },
                      loading: () => IconButton(
                        tooltip: Translations.of(context).text('favourite'),
                        onPressed: null, // Disable button while loading
                        icon: const Icon(Icons
                            .favorite_border_rounded), // Or a loading indicator icon
                      ),
                      error: (error, stackTrace) {
                        debugPrint('Error checking favorite status: $error');
                        return IconButton(
                          tooltip: Translations.of(context).text('error'),
                          onPressed: null,
                          icon: const Icon(Icons.error_outline_rounded),
                        );
                      },
                    ),
                    // Share Button
                    IconButton(
                      tooltip: Translations.of(context).text('share'),
                      onPressed: () {
                        ref.read(openAirProvider).shareEpisode(
                              context,
                              widget.episodeItem!,
                              widget.episodeItem!['title'],
                            );
                      },
                      icon: const Icon(Icons.share_rounded),
                    ),
                    // Transcript Button
                    if (widget.episodeItem?['transcriptUrl'] != null &&
                        (widget.episodeItem!['transcriptUrl'] as String).isNotEmpty)
                      IconButton(
                        tooltip: 'Transcript',
                        onPressed: () async {
                          final url = widget.episodeItem!['transcriptUrl'] as String;
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.description_outlined),
                      ),
                    // Funding Button
                    if (widget.episodeItem?['fundingUrl'] != null &&
                        (widget.episodeItem!['fundingUrl'] as String).isNotEmpty)
                      IconButton(
                        tooltip: 'Support',
                        onPressed: () async {
                          final url = widget.episodeItem!['fundingUrl'] as String;
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.favorite_border_rounded),
                      ),
                  ],
                ),
              ),
              // People section
              if (_persons.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.people_outlined,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'People',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _persons.map((person) {
                      return ListTile(
                        dense: true,
                        leading: person.img != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: person.img!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => CircleAvatar(
                                    child: Icon(Icons.person_outlined, size: 20),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                child: Icon(Icons.person_outlined, size: 20),
                              ),
                        title: Text(person.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: person.role != null
                            ? Text(person.role!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey))
                            : null,
                        onTap: person.href != null
                            ? () async {
                                if (await canLaunchUrl(
                                    Uri.parse(person.href!))) {
                                  await launchUrl(Uri.parse(person.href!),
                                      mode:
                                          LaunchMode.externalApplication);
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ],
              // Soundbites section
              if (_soundbites.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.timeline_outlined,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Highlights',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _soundbites.map((sb) {
                      final formattedStart = _formatDuration(sb.startTime);
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          child: Icon(Icons.play_arrow_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20),
                        ),
                        title: Text(sb.title ?? 'Highlight',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(formattedStart,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey)),
                        onTap: () {
                          final audio = ref.read(audioProvider);
                          audio.seekToPosition(
                              Duration(seconds: sb.startTime));
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
              // Episode Description
              SingleChildScrollView(
                child: Html(
                  data: widget.episodeItem!['description'],
                  onLinkTap: (url, attributes, element) async {
                    await launchUrl(Uri.parse(url!));
                  },
                  style: {
                    "body": Style(
                      maxLines: 4,
                      textOverflow: TextOverflow.ellipsis,
                      margin: Margins.zero,
                      fontSize: FontSize(
                        Theme.of(context).textTheme.bodyMedium?.fontSize ??
                            14.0,
                      ),
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ToggleBanner(),
    );
  }
}
