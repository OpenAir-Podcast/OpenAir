import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ShareAppPrompt {
  ShareAppPrompt._();

  static const String _boxName = 'openAirBox';
  static const String _storageKey = 'shareAppPrompt';

  static const Duration _cooldown = Duration(days: 21);
  static const int _minLaunches = 7;
  static const Duration _displayDelay = Duration(seconds: 8);

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

      prompt['lastShown'] = now;
      await box.put(_storageKey, prompt);

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            Icons.share_rounded,
            color: Theme.of(dialogContext).colorScheme.primary,
            size: 32,
          ),
          title: const Text(
            'Share OpenAir',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Enjoying OpenAir? Share it with friends and family so they can discover podcasts too.',
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
              child: const Text('Don\'t show again'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Maybe later'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Check out OpenAir, a free open-source podcast app: https://play.google.com/store/apps/details?id=com.liquidhive.openair',
                  ),
                );
              },
              child: const Text('Share'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Share app prompt error: $e');
    }
  }
}