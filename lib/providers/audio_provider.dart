import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:openair/controllers/audio_controller.dart';
import 'package:openair/services/audio_handler.dart';

export 'package:openair/controllers/audio_controller.dart'
    show AudioController, DownloadStatus, PlayingStatus;
export 'package:openair/services/audio_handler.dart' show OpenAirAudioHandler;

final audioProvider = ChangeNotifierProvider<AudioController>(
  (ref) => AudioController(ref),
);

final audioHandlerProvider = Provider<OpenAirAudioHandler>(
  (ref) => ref.watch(audioProvider).audioHandler,
);
