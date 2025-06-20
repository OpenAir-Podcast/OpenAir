import 'package:flutter/material.dart';

class NoQueue extends StatelessWidget {
  const NoQueue({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 75.0,
            color: Colors.grey,
          ),
          const SizedBox(height: 20.0),
          Text(
            'Oops, looks like you have no queue...',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Please adding an episode to your queue and try again',
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
