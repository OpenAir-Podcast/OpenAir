import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';

AppBar appBar(WidgetRef ref) {
  return AppBar(
    elevation: 4.0,
    shadowColor: Colors.grey,
    title: const Text(
      'OpenAir',
      textAlign: TextAlign.left,
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          tooltip: 'Remove all downloaded podcasts',
          onPressed: () {
            ref.read(openAirProvider).removeAllDownloadedPodcasts();
          },
          icon: const Icon(Icons.search),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
        child: IconButton(
          tooltip: 'Pause player',
          onPressed: () {
            ref.read(openAirProvider.notifier).playerPauseButtonClicked();
          },
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
    ],
  );
}
