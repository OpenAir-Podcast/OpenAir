import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Queue extends ConsumerStatefulWidget {
  const Queue({super.key});

  @override
  ConsumerState createState() => _QueueState();
}

class _QueueState extends ConsumerState<Queue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
      ),
      body: const Center(
        child: Text('Queue'),
      ),
    );
  }
}
