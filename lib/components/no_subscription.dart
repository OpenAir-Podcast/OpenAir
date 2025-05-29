import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';

class NoSubscription extends ConsumerWidget {
  const NoSubscription({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 75.0,
            color: Colors.grey,
          ),
          const SizedBox(height: 20.0),
          Text(
            'Oops, looks like you have no subscription...',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Please subscribe to a podcast and try again',
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: 180.0,
            height: 40.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                ref.read(openAirProvider).getConnectionStatusTriggered();
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
