import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';

class NoConnection extends ConsumerStatefulWidget {
  const NoConnection({
    super.key,
  });

  @override
  ConsumerState<NoConnection> createState() => _NoConnectionState();
}

class _NoConnectionState extends ConsumerState<NoConnection> {
  String podcastDate = "";

  @override
  Widget build(BuildContext context) {
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
            'Oops, an error occurred...',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Please connect to network and try again',
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

                debugPrint(ref.read(openAirProvider).hasConnection.toString());
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
