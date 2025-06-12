import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_queue.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/views/mobile/widgets/queue_card.dart';

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
      ),
      body: StreamBuilder<List<QueueModel>>(
        stream: ref.watch(hiveServiceProvider).getQueue().asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return NoQueue(title: 'Queue');
          }

          return QueueCard(
            snapshot: snapshot,
          );
        },
      ),
    );
  }
}
