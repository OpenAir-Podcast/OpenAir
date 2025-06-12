import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';

class QueueCard extends ConsumerStatefulWidget {
  const QueueCard({super.key, required this.queueItems});
  final List<QueueModel> queueItems;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QueueCardState();
}

class _QueueCardState extends ConsumerState<QueueCard> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final item = widget.queueItems.elementAt(index);
        return Card(
          key: ValueKey(item.guid), // Use a unique and stable key
          child: ListTile(
            leading: ReorderableDragStartListener(
              index: index,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.drag_handle),
                  const SizedBox(width: 8),
                  Container(
                    width: 62.0,
                    height: 62.0,
                    decoration: BoxDecoration(
                      color: cardImageShadow,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: CachedNetworkImage(
                      memCacheHeight: 62,
                      memCacheWidth: 62,
                      imageUrl: item.image,
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        size: 56.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Column(
              children: [
                Row(
                  children: [
                    Text(
                      ref
                          .watch(openAirProvider)
                          .getPodcastPublishedDateFromEpoch(
                            item.datePublished,
                          ),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                    ),
                    const Text(' | '),
                    Text(
                      item.downloadSize,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            subtitle: Column(
              children: [
                // Seek bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    5.0,
                    10.0,
                    5.0,
                    10.0,
                  ),
                  child: LinearProgressIndicator(
                    value: item.podcastCurrentPositionInMilliseconds,
                  ),
                ),
                // Seek positions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.currentPlaybackPositionString,
                      ),
                      Text(
                        '-${item.currentPlaybackRemainingTimeString}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              iconSize: 40.0,
              icon: Icon(
                Icons.play_circle_outline_rounded,
                size: 40.0,
              ),
              onPressed: () {
                ref.read(openAirProvider.notifier).removeFromQueue(item.guid);
              },
            ),
          ),
        );
      },
      itemCount: widget.queueItems.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(hiveServiceProvider).reorderQueue(oldIndex, newIndex);
      },
    );
  }
}
