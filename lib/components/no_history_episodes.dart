import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';

class NoHistoryEpisodes extends StatelessWidget {
  const NoHistoryEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('history')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 75.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 20.0),
            Text(
              Translations.of(context).text('oopsNoHistory'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Brightness.light == Theme.of(context).brightness
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            Text(
              Translations.of(context).text('pleasePlaySomeEpisodes'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Brightness.light == Theme.of(context).brightness
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
