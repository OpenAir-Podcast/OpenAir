import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

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
        playing: processingState == ProcessingState.completed ? false : playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenToDurationChanges() {
    player.durationStream.listen((duration) {
      final newQueue = queue.value;
      if (newQueue.isNotEmpty) {
        final oldMediaItem = newQueue[0];
        final newMediaItem = oldMediaItem.copyWith(duration: duration);
        newQueue[0] = newMediaItem;
        queue.add(newQueue);
        mediaItem.add(newMediaItem);
      }
    });
  }

  void _listenToCurrentPosition() {
    player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }

  void _listenToPlayerStateChanges() {
    player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        debugPrint('AudioHandler: Playback completed');

        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.completed,
          playing: false,
        ));
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
      artUri: artUri != null &&
              (artUri.startsWith('http://') || artUri.startsWith('https://'))
          ? Uri.parse(artUri)
          : null,
      duration: duration,
    );
    queue.add([mediaItem]);
    this.mediaItem.add(mediaItem);
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
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  @override
  Future<void> skipToNext() async {
    await super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await super.skipToPrevious();
  }

  @override
  Future<void> fastForward() async {
    final newPosition = player.position + const Duration(seconds: 15);
    if (newPosition < (player.duration ?? Duration.zero)) {
      await player.seek(newPosition);
    }
  }

  @override
  Future<void> rewind() async {
    final newPosition = player.position - const Duration(seconds: 15);
    if (newPosition > Duration.zero) {
      await player.seek(newPosition);
    } else {
      await player.seek(Duration.zero);
    }
  }

  Duration get position => player.position;
  Duration? get duration => player.duration;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  Future<void> dispose() async {
    await player.dispose();
  }
}
