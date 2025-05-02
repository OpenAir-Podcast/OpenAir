import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPodcast extends ConsumerStatefulWidget {
  const AddPodcast({super.key});

  @override
  ConsumerState createState() => _AddPodcastState();
}

class _AddPodcastState extends ConsumerState<AddPodcast> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Podcast'),
      ),
      body: const Center(
        child: Text('Add Podcast'),
      ),
    );
  }
}
