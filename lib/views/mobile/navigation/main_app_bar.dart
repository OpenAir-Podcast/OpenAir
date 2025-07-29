import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
