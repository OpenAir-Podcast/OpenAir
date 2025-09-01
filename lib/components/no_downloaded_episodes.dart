import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';

class NoDownloadedEpisodes extends StatelessWidget {
  const NoDownloadedEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('noDownloadedEpisodes')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_rounded,
                size: 75.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 20.0),
              Text(
                Translations.of(context).text('oopsNoEpisodesDownloaded'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Text(
                Translations.of(context).text('pleaseDownloadSomeEpisodes'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
