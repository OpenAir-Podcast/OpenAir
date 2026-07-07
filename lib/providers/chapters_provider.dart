import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/chapters_model.dart';
import 'package:openair/providers/audio_provider.dart';

final chaptersProvider = Provider<ChaptersData?>(
  (ref) {
    final audio = ref.watch(audioProvider);
    return audio.currentChapters;
  },
);
