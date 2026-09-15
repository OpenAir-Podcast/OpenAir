import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:rxdart/rxdart.dart';

OpenAirAudioHandler? _audioHandlerInstance;

OpenAirAudioHandler getAudioHandler() {
  if (_audioHandlerInstance == null) {
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: true,
      android: false,
      iOS: true,
      macOS: true,
    );
    _audioHandlerInstance = OpenAirAudioHandler();
  }
  return _audioHandlerInstance!;
}

class OpenAirAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer player = AudioPlayer();

  OpenAirAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToDurationChanges();
    _listenToCurrentPosition();
    _listenToPlayerStateChanges();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    player.playbackEventStream.listen((PlaybackEvent event) {
      try {
        final playing = player.playing;
        final processingState = player.processingState;
        playbackState.add(playbackState.value.copyWith(
          controls: [
            MediaControl.rewind,
            if (processingState != ProcessingState.completed && playing)
              MediaControl.pause
            else
              MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[processingState]!,
          playing:
              processingState == ProcessingState.completed ? false : playing,
          updatePosition: player.position,
          bufferedPosition: player.bufferedPosition,
          speed: player.speed,
          queueIndex: event.currentIndex,
        ));
      } catch (e) {
        debugPrint('AudioHandler: playback event error: $e');
      }
    });
  }

  void _listenToDurationChanges() {
    player.durationStream.listen((duration) {
      try {
        final newQueue = queue.value;
        if (newQueue.isNotEmpty) {
          final oldMediaItem = newQueue[0];
          final newMediaItem = oldMediaItem.copyWith(duration: duration);
          newQueue[0] = newMediaItem;
          queue.add(newQueue);
          mediaItem.add(newMediaItem);
        }
      } catch (e) {
        debugPrint('AudioHandler: duration change error: $e');
      }
    });
  }

  void _listenToCurrentPosition() {
    player.positionStream.listen((position) {
      try {
        playbackState.add(playbackState.value.copyWith(
          updatePosition: position,
        ));
      } catch (e) {
        debugPrint('AudioHandler: position event error: $e');
      }
    });
  }

  void _listenToPlayerStateChanges() {
    player.playerStateStream.listen((playerState) {
      try {
        if (playerState.processingState == ProcessingState.completed) {
          debugPrint('AudioHandler: Playback completed');

          playbackState.add(playbackState.value.copyWith(
            processingState: AudioProcessingState.completed,
            playing: false,
          ));
        }
      } catch (e) {
        debugPrint('AudioHandler: player state error: $e');
      }
    });
  }

  Future<void> setMediaItem({
    required String id,
    required String title,
    required String artist,
    String? album,
    String? artUri,
    Duration? duration,
  }) async {
    final mediaItem = MediaItem(
      id: id,
      title: title,
      artist: artist,
      album: album,
      artUri: artUri != null && artUri.isNotEmpty
          ? (artUri.startsWith('http://') || artUri.startsWith('https://')
              ? Uri.parse(artUri)
              : Uri.file(artUri))
          : null,
      duration: duration,
    );
    queue.add([mediaItem]);
    this.mediaItem.add(mediaItem);
  }

  Future<void> updateArtUri(String artUri) async {
    final newQueue = queue.value;
    if (newQueue.isNotEmpty) {
      final oldMediaItem = newQueue[0];
      final newMediaItem = oldMediaItem.copyWith(
        artUri: artUri.isNotEmpty
            ? (artUri.startsWith('http://') || artUri.startsWith('https://')
                ? Uri.parse(artUri)
                : Uri.file(artUri))
            : null,
      );
      newQueue[0] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    }
  }

  Future<void> playFromUrl(String url, {Duration? initialPosition}) async {
    try {
      await player.setUrl(url,
          initialPosition: initialPosition ?? Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint('Error playing from URL: $e');
    }
  }

  // Media library snapshot used by Android Auto / the media browser. The UI
  // keeps this up to date via [updateMediaLibrary] whenever subscriptions or
  // episodes change.
  List<MediaItem> _podcasts = [];
  final Map<String, List<MediaItem>> _episodesByPodcastId = {};
  final Map<String, MediaItem> _episodesById = {};
  final Map<String, String> _urlsByGuid = {};

  // Per-parent browse-tree change notification controllers.
  // The platform's onLoadChildren listens to these and calls
  // notifyChildrenChanged on the head unit when we emit.
  final Map<String, BehaviorSubject<Map<String, dynamic>>>
      _childrenChangeControllers = {};

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    return _childrenChangeControllers.putIfAbsent(
      parentMediaId,
      () => BehaviorSubject<Map<String, dynamic>>.seeded(<String, dynamic>{}),
    );
  }

  void _notifyChildrenChanged() {
    for (final parentMediaId in _childrenChangeControllers.keys) {
      final subject = _childrenChangeControllers[parentMediaId];
      if (subject != null && !subject.isClosed) {
        subject.add(<String, dynamic>{});
      }
    }
  }

  void updateMediaLibrary({
    required List<MediaItem> podcasts,
    required Map<String, List<MediaItem>> episodesByPodcast,
    required Map<String, String> urlsByGuid,
  }) {
    _podcasts = podcasts;
    _episodesByPodcastId
      ..clear()
      ..addAll(episodesByPodcast);
    _episodesById.clear();
    for (final episodes in _episodesByPodcastId.values) {
      for (final episode in episodes) {
        _episodesById[episode.id] = episode;
      }
    }
    _urlsByGuid
      ..clear()
      ..addAll(urlsByGuid);
    _notifyChildrenChanged();
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    try {
      if (parentMediaId.isEmpty || parentMediaId == 'root') {
        return _podcasts;
      }
      return _episodesByPodcastId[parentMediaId] ?? [];
    } catch (e) {
      debugPrint('AudioHandler: getChildren error for $parentMediaId: $e');
      return [];
    }
  }

  @override
  Future<List<MediaItem>> search(String query,
      [Map<String, dynamic>? extras]) async {
    try {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return [];

      final matches = _episodesById.values
          .where((item) =>
              item.title.toLowerCase().contains(q) ||
              (item.artist?.toLowerCase().contains(q) ?? false) ||
              (item.album?.toLowerCase().contains(q) ?? false))
          .toList()
        ..sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      return matches.take(50).toList();
    } catch (e) {
      debugPrint('AudioHandler: search error: $e');
      return [];
    }
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    try {
      final episodes = _episodesByPodcastId[mediaId];
      if (episodes != null && episodes.isNotEmpty) {
        await _playFromLibraryItem(episodes.first);
        return;
      }

      final episode = _episodesById[mediaId];
      if (episode != null) {
        await _playFromLibraryItem(episode);
      }
    } catch (e) {
      debugPrint('AudioHandler: playFromMediaId error for $mediaId: $e');
    }
  }

  @override
  Future<void> playFromSearch(String query,
      [Map<String, dynamic>? extras]) async {
    try {
      final results = await search(query, extras);
      if (results.isNotEmpty) {
        await _playFromLibraryItem(results.first);
      }
    } catch (e) {
      debugPrint('AudioHandler: playFromSearch error: $e');
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await _playFromLibraryItem(mediaItem);
  }

  Future<void> _playFromLibraryItem(MediaItem episode) async {
    try {
      // If the item is a podcast id itself, play its most recent episode.
      final podcastEpisodes = _episodesByPodcastId[episode.id];
      final target =
          (podcastEpisodes != null && podcastEpisodes.isNotEmpty)
              ? podcastEpisodes.first
              : episode;

      final url = _urlsByGuid[target.id];
      if (url == null || url.isEmpty) {
        debugPrint('AudioHandler: No URL known for ${target.id}');
        return;
      }
      await setMediaItem(
        id: target.id,
        title: target.title,
        artist: target.artist ?? '',
        album: target.album,
        artUri: target.artUri?.toString(),
        duration: target.duration,
      );
      await playFromUrl(url);
    } catch (e) {
      debugPrint('AudioHandler: _playFromLibraryItem error: $e');
    }
  }

  Future<void> playFromFile(String filePath,
      {Duration? initialPosition}) async {
    try {
      await player.setFilePath(filePath,
          initialPosition: initialPosition ?? Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint('Error playing from file: $e');
    }
  }

  @override
  Future<void> play() async {
    try {
      await player.play();
    } catch (e) {
      debugPrint('AudioHandler: play error: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await player.pause();
    } catch (e) {
      debugPrint('AudioHandler: pause error: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await player.stop();
      await super.stop();
    } catch (e) {
      debugPrint('AudioHandler: stop error: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await player.seek(position);
    } catch (e) {
      debugPrint('AudioHandler: seek error: $e');
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    try {
      await player.setSpeed(speed);
    } catch (e) {
      debugPrint('AudioHandler: setSpeed error: $e');
    }
  }

  Future<void> Function()? onSkipToNext;
  Future<void> Function()? onSkipToPrevious;

  @override
  Future<void> skipToNext() async {
    try {
      final callback = onSkipToNext;
      if (callback != null) {
        await callback();
        return;
      }
      await super.skipToNext();
    } catch (e) {
      debugPrint('AudioHandler: skipToNext error: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      final callback = onSkipToPrevious;
      if (callback != null) {
        await callback();
        return;
      }
      await super.skipToPrevious();
    } catch (e) {
      debugPrint('AudioHandler: skipToPrevious error: $e');
    }
  }

  @override
  Future<void> fastForward() async {
    try {
      final newPosition = player.position + const Duration(seconds: 15);
      if (newPosition < (player.duration ?? Duration.zero)) {
        await player.seek(newPosition);
      }
    } catch (e) {
      debugPrint('AudioHandler: fastForward error: $e');
    }
  }

  @override
  Future<void> rewind() async {
    try {
      final newPosition = player.position - const Duration(seconds: 15);
      if (newPosition > Duration.zero) {
        await player.seek(newPosition);
      } else {
        await player.seek(Duration.zero);
      }
    } catch (e) {
      debugPrint('AudioHandler: rewind error: $e');
    }
  }

  Duration get position => player.position;
  Duration? get duration => player.duration;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  Future<void> dispose() async {
    for (final subject in _childrenChangeControllers.values) {
      if (!subject.isClosed) await subject.close();
    }
    await player.dispose();
  }
}
