import 'dart:async';

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
    // The plugin builds this handler inside its background isolate, which can
    // never reach the controller that loads subscriptions. Only once that
    // controller exists can syncMediaLibrary() publish the real tree, so do not
    // release the browse gate here: a cold start launched from the head unit
    // has to wait for the library rather than flash an empty root.
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
            // Both directions are advertised as system actions too. Without
            // that the head unit has no previous/next buttons at all, even
            // though skipToPrevious()/skipToNext() are implemented.
            MediaControl.skipToPrevious,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.skipToPrevious,
            MediaAction.skipToNext,
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

  /// Mirrors `PlaybackStateCompat.ERROR_CODE_UNKNOWN_ERROR`.
  static const int _unknownPlaybackError = 1;

  /// Android surfaces [PlaybackState.errorCode]/[PlaybackState.errorMessage]
  /// on the car media card. Without them a stream that fails to load leaves the
  /// car showing a permanently "playing" item with a frozen scrubber, which is
  /// indistinguishable from a broken app.
  void _reportError(String message) {
    playbackState.add(playbackState.value.copyWith(
      errorCode: _unknownPlaybackError,
      errorMessage: message,
      playing: false,
    ));
  }

  void _clearError() {
    if (playbackState.value.errorCode == null) return;
    playbackState.add(playbackState.value.copyWith(
      errorCode: null,
      errorMessage: null,
    ));
  }

  Future<void> playFromUrl(String url, {Duration? initialPosition}) async {
    _clearError();
    try {
      await player.setUrl(url,
          initialPosition: initialPosition ?? Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint('Error playing from URL: $e');
      _reportError('Unable to play this episode');
    }
  }

  // Media library snapshot used by Android Auto / the media browser. The UI
  // keeps this up to date via [updateMediaLibrary] whenever subscriptions or
  // episodes change.
  List<MediaItem> _podcasts = [];
  final Map<String, List<MediaItem>> _episodesByPodcastId = {};
  final Map<String, MediaItem> _episodesById = {};

  /// Every known episode, newest first. Backs the "play me something" path for
  /// car voice actions that arrive without search terms.
  final List<MediaItem> _episodesByRecency = [];
  final Map<String, String> _urlsByGuid = {};

  // The head unit can bind to our MediaBrowserService before the Flutter UI has
  // finished loading subscriptions, so getChildren() parks on this completer
  // instead of answering with an empty tree and showing a blank browser.
  final Completer<void> _libraryReady = Completer<void>();
  Timer? _libraryReadyTimer;

  /// Called once the media library has been populated, or once it is clear that
  /// it never will be.
  void markLibraryReady() {
    _libraryReadyTimer?.cancel();
    _libraryReadyTimer = null;
    if (!_libraryReady.isCompleted) _libraryReady.complete();
  }

  Future<void> _awaitLibraryReady() async {
    if (_libraryReady.isCompleted) return;
    // Never leave a car browse request hanging: if the library never arrives
    // the head unit gets an empty tree, which is better than an endless spinner.
    _libraryReadyTimer ??= Timer(const Duration(seconds: 20), () {
      debugPrint('AudioHandler: media library was not ready in time');
      markLibraryReady();
    });
    await _libraryReady.future;
  }

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
    _episodesByRecency.clear();
    for (final episodes in _episodesByPodcastId.values) {
      for (final episode in episodes) {
        _episodesById[episode.id] = episode;
        _episodesByRecency.add(episode);
      }
    }
    _episodesByRecency.sort(_byRecency);
    _urlsByGuid
      ..clear()
      ..addAll(urlsByGuid);
    markLibraryReady();
    _notifyChildrenChanged();
  }

  /// Orders episodes newest first using the publish date that the media library
  /// sync stashes in [MediaItem.extras].
  static int _byRecency(MediaItem a, MediaItem b) {
    int published(MediaItem item) {
      final raw = item.extras?['publishedAt'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      return 0;
    }

    return published(b).compareTo(published(a));
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    try {
      await _awaitLibraryReady();
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
      await _awaitLibraryReady();
      return _searchEpisodes(query, extras);
    } catch (e) {
      debugPrint('AudioHandler: search error: $e');
      return [];
    }
  }

  /// Android Auto and the Assistant describe a voice action with a free-text
  /// query plus a Bundle of category hints. Those Bundle keys differ between
  /// the MediaBrowser and MediaMetadata namespaces
  /// (`android.media.extra.TITLE` vs `android.media.metadata.TITLE`), so match
  /// on the last key segment rather than hard-coding full key names.
  static String? _hintFor(Map<String, dynamic>? extras, String token) {
    if (extras == null) return null;
    for (final entry in extras.entries) {
      final separator = entry.key.lastIndexOf('.');
      final local =
          (separator == -1 ? entry.key : entry.key.substring(separator + 1))
              .toLowerCase();
      if (local != token) continue;
      final value = entry.value;
      if (value is String && value.trim().isNotEmpty) {
        return value.trim().toLowerCase();
      }
    }
    return null;
  }

  List<MediaItem> _recentEpisodes({int limit = 25}) {
    return _episodesByRecency.take(limit).toList();
  }

  List<MediaItem> _searchEpisodes(String query, Map<String, dynamic>? extras) {
    final freeText = query.trim().toLowerCase();
    final hints = <String>[
      for (final token in ['title', 'album', 'artist', 'genre', 'playlist'])
        if (_hintFor(extras, token) != null) _hintFor(extras, token)!,
    ];

    // A generic "play <something>" request arrives with an empty query. Falling
    // back to the newest episodes keeps the car from answering with silence,
    // which a reviewer reads as a broken app.
    if (freeText.isEmpty && hints.isEmpty) return _recentEpisodes();

    bool matches(MediaItem item, String needle) {
      final haystack = [
        item.title,
        item.artist ?? '',
        item.album ?? '',
        _hintFor(item.extras, 'genre') ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(needle);
    }

    // Category hints are ANDed first, then relaxed to OR, then to "recently
    // published". Grading rather than returning nothing matters more than
    // strictness here: a wrong episode is recoverable, silence in the car is not.
    int score(MediaItem item, {required bool requireAll}) {
      var value = 0;
      var satisfied = 0;
      for (final hint in hints) {
        if (matches(item, hint)) {
          satisfied++;
          value += 2;
        }
      }
      if (requireAll && satisfied != hints.length) return -1;

      if (freeText.isNotEmpty) {
        if (item.title.toLowerCase().contains(freeText)) {
          value += 3;
        } else if (matches(item, freeText)) {
          value += 1;
        } else if (requireAll) {
          return -1;
        }
      }
      return value;
    }

    for (final requireAll in [true, false]) {
      final scored = <(int, MediaItem)>[];
      for (final item in _episodesByRecency) {
        final value = score(item, requireAll: requireAll);
        if (value > 0) scored.add((value, item));
      }
      if (scored.isEmpty) continue;
      scored.sort((a, b) => b.$1.compareTo(a.$1));
      return scored.take(50).map((entry) => entry.$2).toList();
    }

    return _recentEpisodes();
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    try {
      await _awaitLibraryReady();
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
      await _awaitLibraryReady();
      final results = _searchEpisodes(query, extras);
      if (results.isEmpty) {
        debugPrint('AudioHandler: nothing matched "$query"');
        return;
      }
      await _playFromLibraryItem(results.first);
    } catch (e) {
      debugPrint('AudioHandler: playFromSearch error for $e');
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await _awaitLibraryReady();
    await _playFromLibraryItem(mediaItem);
  }

  Future<void> _playFromLibraryItem(MediaItem episode) async {
    try {
      // If the item is a podcast id itself, play its most recent episode.
      final podcastEpisodes = _episodesByPodcastId[episode.id];
      final target = (podcastEpisodes != null && podcastEpisodes.isNotEmpty)
          ? podcastEpisodes.first
          : episode;

      final url = _urlsByGuid[target.id];
      if (url == null || url.isEmpty) {
        debugPrint('AudioHandler: No URL known for ${target.id}');
        _reportError('This episode is not available offline');
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
    _clearError();
    try {
      await player.setFilePath(filePath,
          initialPosition: initialPosition ?? Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint('Error playing from file: $e');
      _reportError('Unable to play this episode');
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
