import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';

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
            Translations.of(context).text('oopsNoQueue'),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            Translations.of(context).text('pleaseAddEpisodeToQueue'),
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
