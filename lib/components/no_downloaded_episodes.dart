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
              ),
            ),
            Text(
              Translations.of(context).text('pleaseDownloadSomeEpisodes'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
