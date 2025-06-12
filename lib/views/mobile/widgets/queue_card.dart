import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';

class QueueCard extends ConsumerStatefulWidget {
  const QueueCard({super.key, required this.snapshot});
  final AsyncSnapshot<List<QueueModel>> snapshot;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QueueCardState();
}

class _QueueCardState extends ConsumerState<QueueCard> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final item = widget.snapshot.data!.elementAt(index);
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
                            widget.snapshot.data!.firstWhere(
                              (element) {
                                return element.guid == item.guid;
                              },
                            ).datePublished,
                          ),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                    ),
                    const Text(' | '),
                    Text(
                      widget.snapshot.data!.firstWhere(
                        (element) {
                          return element.guid == item.guid;
                        },
                      ).downloadSize,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
                Text(
                  widget.snapshot.data!.firstWhere(
                    (element) {
                      return element.guid == item.guid;
                    },
                  ).title,
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
                    value: widget.snapshot.data!.firstWhere(
                      (element) {
                        return element.guid == item.guid;
                      },
                    ).podcastCurrentPositionInMilliseconds,
                  ),
                ),
                // Seek positions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.snapshot.data!.firstWhere(
                          (element) {
                            return element.guid == item.guid;
                          },
                        ).currentPlaybackPositionString,
                      ),
                      Text(
                        '-${widget.snapshot.data!.firstWhere(
                          (element) {
                            return element.guid == item.guid;
                          },
                        ).currentPlaybackRemainingTimeString}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.play_circle_outline_rounded,
                size: 50.0,
              ),
              onPressed: () {
                ref.read(openAirProvider.notifier).removeFromQueue(item.guid);
              },
            ),
          ),
        );
      },
      itemCount: widget.snapshot.data!.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(hiveServiceProvider).reorderQueue(oldIndex, newIndex);
        ref.watch(hiveServiceProvider).reorderQueue(oldIndex, newIndex);
      },
    );
  }
}
