import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/transcript_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/services/transcript_service.dart';

class TranscriptViewer extends ConsumerStatefulWidget {
  const TranscriptViewer({super.key, required this.transcriptUrl});

  final String transcriptUrl;

  @override
  ConsumerState<TranscriptViewer> createState() => _TranscriptViewerState();
}

class _TranscriptViewerState extends ConsumerState<TranscriptViewer> {
  final TranscriptService _service = TranscriptService();
  final ScrollController _scrollController = ScrollController();

  List<TranscriptCue> _cues = [];
  bool _loading = true;
  String? _error;
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cues = await _service.fetch(widget.transcriptUrl);
      if (!mounted) return;
      setState(() {
        _cues = cues;
        _loading = false;
        if (cues.isEmpty) _error = 'No transcript available';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioProvider);
    final position = audio.playerPosition;

    // Update current cue
    int newIndex = -1;
    for (int i = 0; i < _cues.length; i++) {
      if (position >= _cues[i].start && position < _cues[i].end) {
        newIndex = i;
        break;
      }
      if (position >= _cues[i].start) {
        newIndex = i;
      }
    }
    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      if (newIndex >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          final offset = (newIndex * 72.0).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _cues.length,
                  itemBuilder: (context, index) {
                    final cue = _cues[index];
                    final isCurrent = index == _currentIndex;
                    return ListTile(
                      title: Text(
                        cue.text,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                      subtitle: Text(
                        _format(cue.start),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        audio.seekToPosition(cue.start);
                      },
                    );
                  },
                ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}