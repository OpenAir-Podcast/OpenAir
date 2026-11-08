import 'package:flutter/material.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/services/bookmark_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkSheet extends ConsumerStatefulWidget {
  const BookmarkSheet({
    super.key,
    required this.episodeGuid,
    required this.episodeTitle,
  });

  final String episodeGuid;
  final String episodeTitle;

  @override
  ConsumerState<BookmarkSheet> createState() => _BookmarkSheetState();
}

class _BookmarkSheetState extends ConsumerState<BookmarkSheet> {
  final BookmarkService _service = BookmarkService();
  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.getBookmarks(widget.episodeGuid);
    if (!mounted) return;
    setState(() {
      _bookmarks = list;
      _loading = false;
    });
  }

  String _format(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bookmarks',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_bookmarks.isEmpty)
              const Text('No bookmarks yet.')
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final b = _bookmarks[index];
                    final posMs = b['positionMs'] as int;
                    return ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text(b['note']?.toString() ?? 'Bookmark'),
                      subtitle: Text(_format(posMs)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow_rounded),
                            onPressed: () {
                              audio.seekToPosition(Duration(milliseconds: posMs));
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_rounded),
                            onPressed: () {
                              final shareText =
                                  '${widget.episodeTitle} @ ${_format(posMs)}';
                              // Use url_launcher? Just copy to clipboard via ScaffoldMessenger
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Share: $shareText')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await _service.removeBookmark(b['key']);
                              _load();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}