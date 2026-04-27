import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/controllers/audio_controller.dart';

export 'package:openair/controllers/audio_controller.dart'
    show AudioController, DownloadStatus, PlayingStatus;

final audioProvider = ChangeNotifierProvider<AudioController>(
  (ref) => AudioController(ref),
);
