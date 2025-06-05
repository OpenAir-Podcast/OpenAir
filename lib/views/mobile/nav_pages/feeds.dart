import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Feeds extends ConsumerStatefulWidget {
  const Feeds({super.key});

  @override
  ConsumerState createState() => _FeedsState();
}

class _FeedsState extends ConsumerState<Feeds> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: const Center(
        child: Text('Feed'),
      ),
    );
  }
}
