import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/models/subscription.dart';
import 'package:openair/providers/openair_provider.dart';

final getSubscriptionsProvider =
    FutureProvider<Map<String, Subscription>>((ref) async {
  final apiService = ref.read(openAirProvider);
  return await apiService.getSubscriptions();
});

class Subscribed extends ConsumerStatefulWidget {
  const Subscribed({super.key});

  @override
  ConsumerState createState() => _SubscriptionsState();
}

class _SubscriptionsState extends ConsumerState<Subscribed> {
  @override
  Widget build(BuildContext context) {
    // TODO: Continue from here
    final AsyncValue<Map<String, Subscription>> getSubscriptionsValue =
        ref.watch(getSubscriptionsProvider);

    return getSubscriptionsValue.when(
      data: (data) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscribed'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
          body: Text('data'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}
