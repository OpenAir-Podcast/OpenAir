import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Subscriptions extends ConsumerStatefulWidget {
  const Subscriptions({super.key});

  @override
  ConsumerState createState() => _SubscriptionsState();
}

class _SubscriptionsState extends ConsumerState<Subscriptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      body: const Center(
        child: Text('Subscriptions'),
      ),
    );
  }
}
