import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:openair/views/widgets/update_dialog.dart';

class UpdateService {
  static const String _boxName = 'openAirBox';
  static const String _dismissedKey = 'updateDismissedVersion';

  /// Returns true if [current] < [latest] using simple semver comparison.
  static bool isOutdated(String current, String latest) {
    final c = _parse(current);
    final l = _parse(latest);
    for (int i = 0; i < 3; i++) {
      if (c[i] < l[i]) return true;
      if (c[i] > l[i]) return false;
    }
    return false;
  }

  static List<int> _parse(String v) {
    final cleaned = v.split('+').first;
    final parts = cleaned.split('.');
    final result = <int>[0, 0, 0];
    for (int i = 0; i < parts.length && i < 3; i++) {
      result[i] = int.tryParse(parts[i]) ?? 0;
    }
    return result;
  }

  static Future<void> checkForUpdate(
    BuildContext context, {
    required String latestVersion,
    String updateUrl = '',
    String title = 'A fresh update is ready',
    String subtitle = 'Update to keep things running smoothly.',
    String summary = 'Fixes & improvements.',
    List<UpdateHighlight> highlights = const [],
  }) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      if (!isOutdated(current, latestVersion)) return;

      final box = await Hive.openBox(_boxName);
      final dismissed = box.get(_dismissedKey)?.toString();
      if (dismissed == latestVersion) return;

      await Future.delayed(const Duration(seconds: 2));
      if (!context.mounted) return;

      await showUpdateDialog(
        context,
        title: title,
        version: latestVersion,
        subtitle: subtitle,
        summary: summary,
        highlights: highlights,
        onUpdate: () async {
          if (updateUrl.isNotEmpty) {
            final uri = Uri.parse(updateUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        onDismiss: () async {
          final b = await Hive.openBox(_boxName);
          await b.put(_dismissedKey, latestVersion);
        },
      );
    } catch (_) {}
  }
}