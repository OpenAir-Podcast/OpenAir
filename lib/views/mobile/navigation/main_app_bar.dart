import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/views/mobile/nav_pages/add_podcast_page.dart';

AppBar mainAppBar(WidgetRef ref, BuildContext context) {
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
          tooltip: 'Refreash',
          onPressed: () {
            // TODO Implement refreash mechanic 
          },
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          tooltip: 'Search Podcasts',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPodcast(),
            ),
          ),
          icon: const Icon(Icons.search),
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
