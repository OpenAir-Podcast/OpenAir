import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:openair/views/settings_pages/donate_page.dart';

class DonationPrompt {
  DonationPrompt._();

  static const String _boxName = 'openAirBox';
  static const String _storageKey = 'donationPrompt';

  static const Duration _cooldown = Duration(days: 14);
  static const int _minLaunches = 5;
  static const Duration _displayDelay = Duration(seconds: 5);

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

      prompt['lastShown'] = now;
      await box.put(_storageKey, prompt);

      await Future.delayed(_displayDelay);
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            Icons.favorite_rounded,
            color: Theme.of(dialogContext).colorScheme.primary,
            size: 32,
          ),
          title: Text(
            Translations.of(dialogContext).text('donationPromptTitle'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            Translations.of(dialogContext).text('donationPromptMessage'),
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DonatePage(),
                  ),
                );
              },
              child: Text(Translations.of(dialogContext).text('donate')),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Donation prompt error: $e');
    }
  }
}
