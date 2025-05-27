import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AppBar mainAppBar(WidgetRef ref) {
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
          // TODO: Add search functionality
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
        child: IconButton(
          tooltip: 'Pause player',
          // TODO: Refresh featured podcasts
          onPressed: () {},
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
    ],
    bottom: const TabBar(
      tabs: [
        Tab(text: 'FEATURED'),
        Tab(text: 'TRENDING'),
        Tab(text: 'CATEGORIES'),
      ],
    ),
  );
}
