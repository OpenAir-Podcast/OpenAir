import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RatePrompt {
  RatePrompt._();

  static const String _boxName = 'openAirBox';
  static const String _storageKey = 'ratePrompt';
  static const String _donationStorageKey = 'donationPrompt';

  static const String _packageName = 'com.liquidhive.openair';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=$_packageName';
  static const String _playStoreAndroidUrl = 'market://details?id=$_packageName';

  static const Duration _cooldown = Duration(days: 30);
  static const int _minLaunches = 10;
  static const Duration _displayDelay = Duration(seconds: 12);

  // Minimum gap between this prompt and any other prompt so the two never
  // stack on top of each other.
  static const Duration _promptSpacing = Duration(minutes: 2);

  static Future<void> maybeShow(BuildContext context) async {
    try {
      final box = await Hive.openBox(_boxName);
      final stored = box.get(_storageKey);
      final prompt = stored is Map
          ? Map<String, dynamic>.from(stored)
          : <String, dynamic>{};

      if (prompt['neverShow'] == true) return;

      final launchCount = (prompt['launchCount'] as num?)?.toInt() ?? 0;
      prompt['launchCount'] = launchCount + 1;

      final lastShown = (prompt['lastShown'] as num?)?.toInt() ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cooledDown =
          lastShown == 0 || now - lastShown >= _cooldown.inMilliseconds;

      if (prompt['launchCount'] < _minLaunches || !cooledDown) {
        await box.put(_storageKey, prompt);
        return;
      }

      await Future.delayed(_displayDelay);
      if (!context.mounted) return;

      // Another prompt (e.g. the donation prompt) may already be on screen.
      if (_shownRecently(box, _donationStorageKey)) return;

      prompt['lastShown'] = now;
      await box.put(_storageKey, prompt);

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            Icons.star_rounded,
            color: Theme.of(dialogContext).colorScheme.primary,
            size: 32,
          ),
          title: Text(
            Translations.of(dialogContext).text('ratePromptTitle'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            Translations.of(dialogContext).text('ratePromptMessage'),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () async {
                final data = box.get(_storageKey);
                final updated = data is Map
                    ? Map<String, dynamic>.from(data)
                    : <String, dynamic>{};
                updated['neverShow'] = true;
                await box.put(_storageKey, updated);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: Text(
                Translations.of(dialogContext).text('dontShowAgain'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(Translations.of(dialogContext).text('maybeLater')),
            ),
            FilledButton(
              onPressed: () => _openPlayStore(dialogContext),
              child: Text(Translations.of(dialogContext).text('rateOnPlayStore')),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Rate prompt error: $e');
    }
  }

  static bool _shownRecently(Box box, String key) {
    final stored = box.get(key);
    final data = stored is Map ? Map<String, dynamic>.from(stored) : null;
    final lastShown = (data?['lastShown'] as num?)?.toInt() ?? 0;
    if (lastShown == 0) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastShown < _promptSpacing.inMilliseconds;
  }

  static Future<void> _openPlayStore(BuildContext context) async {
    if (context.mounted) Navigator.of(context).pop();
    if (Platform.isAndroid) {
      final launched = await _launch(_playStoreAndroidUrl);
      if (launched) return;
    }
    await _launch(_playStoreUrl);
  }

  static Future<bool> _launch(String url) async {
    try {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Rate prompt could not open $url: $e');
      return false;
    }
  }
}
