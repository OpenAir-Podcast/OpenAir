import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:theme_provider/theme_provider.dart';

final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref),
);

class SettingsController extends ChangeNotifier {
  final Ref ref;

  SettingsController(this.ref);

  HiveService get _hiveService => ref.read(hiveServiceProvider);

  Future<Map<String, dynamic>> getUserInterfaceSettings() async {
    return await _hiveService.getUserInterfaceSettings();
  }

  Future<Map<String, dynamic>> getPlaybackSettings() async {
    return await _hiveService.getPlaybackSettings();
  }

  Future<Map<String, dynamic>> getAutomaticSettings() async {
    return await _hiveService.getAutomaticSettings();
  }

  Future<Map<String, dynamic>> getSynchronizationSettings() async {
    return await _hiveService.getSynchronizationSettings();
  }

  Future<Map<String, dynamic>> getImportExportSettings() async {
    final result = await _hiveService.getImportExportSettings();
    return result ?? {};
  }

  Future<Map<String, dynamic>> getNotificationsSettings() async {
    final result = await _hiveService.getNotificationsSettings();
    return result ?? {};
  }

  void saveUserInterfaceSettings(Map userInterfaceSettings) {
    _hiveService.saveUserInterfaceSettings(userInterfaceSettings);
  }

  void savePlaybackSettings(Map playbackSettings) {
    _hiveService.savePlaybackSettings(playbackSettings);
  }

  void saveAutomaticSettings(Map automaticSettings) {
    _hiveService.saveAutomaticSettings(automaticSettings);
  }

  void saveSynchronizationSettings(Map synchronizationSettings) {
    _hiveService.saveSynchronizationSettings(synchronizationSettings);
  }

  void saveImportExportSettings(Map importExportSettings) {
    _hiveService.saveImportExportSettings(importExportSettings);
  }

  void saveNotificationsSettings(Map notificationsSettings) {
    _hiveService.saveNotificationsSettings(notificationsSettings);
  }

  String _getDarkThemeName(String fontSize) {
    switch (fontSize) {
      case 'small':
        return 'blue_accent_dark_small';
      case 'medium':
        return 'blue_accent_dark_medium';
      case 'large':
        return 'blue_accent_dark_large';
      case 'extraLarge':
        return 'blue_accent_dark_extra_large';
      default:
        return 'blue_accent_dark_medium';
    }
  }

  String _getLightThemeName(String fontSize) {
    switch (fontSize) {
      case 'small':
        return 'blue_accent_light_small';
      case 'medium':
        return 'blue_accent_light_medium';
      case 'large':
        return 'blue_accent_light_large';
      case 'extraLarge':
        return 'blue_accent_light_extra_large';
      default:
        return 'blue_accent_light_medium';
    }
  }

  void _applyTheme(
      String fontSize, Brightness brightness, BuildContext context) {
    String themeName;

    switch (themeModeConfig) {
      case 'System':
        if (brightness == Brightness.dark) {
          themeName = _getDarkThemeName(fontSize);
        } else {
          themeName = _getLightThemeName(fontSize);
        }
        break;
      case 'Light':
        themeName = _getLightThemeName(fontSize);
        break;
      case 'Dark':
        themeName = _getDarkThemeName(fontSize);
        break;
      default:
        if (brightness == Brightness.dark) {
          themeName = _getDarkThemeName(fontSize);
        } else {
          themeName = _getLightThemeName(fontSize);
        }
    }

    ThemeProvider.controllerOf(context).setTheme(themeName);
  }

  void updateFontSize(String size, BuildContext context) {
    fontSizeConfig = size;
    _hiveService.saveUserInterfaceSettings({
      'fontSizeFactor': fontSizeConfig,
      'language': languageConfig,
      'locale': localeConfig,
    });

    Brightness platformBrightness =
        View.of(context).platformDispatcher.platformBrightness;

    _applyTheme(size, platformBrightness, context);
    notifyListeners();
  }

  void updateLanguage(String language, String locale) {
    languageConfig = language;
    localeConfig = locale;
    _hiveService.saveUserInterfaceSettings({
      'fontSizeFactor': fontSizeConfig,
      'language': languageConfig,
      'locale': localeConfig,
    });
    notifyListeners();
  }

  void updatePlaybackSettings({
    String? fastForwardInterval,
    String? rewindInterval,
    String? playbackSpeed,
    String? enqueuePosition,
    bool? enqueueDownloaded,
    bool? continuePlayback,
    String? smartMarkAsCompleted,
    bool? keepSkippedEpisodes,
  }) {
    if (fastForwardInterval != null) {
      fastForwardIntervalConfig = fastForwardInterval;
    }
    if (rewindInterval != null) rewindIntervalConfig = rewindInterval;
    if (playbackSpeed != null) playbackSpeedConfig = playbackSpeed;
    if (enqueuePosition != null) enqueuePositionConfig = enqueuePosition;
    if (enqueueDownloaded != null) enqueueDownloadedConfig = enqueueDownloaded;
    if (continuePlayback != null) autoplayNextInQueueConfig = continuePlayback;
    if (smartMarkAsCompleted != null) {
      smartMarkAsCompletionConfig = smartMarkAsCompleted;
    }
    if (keepSkippedEpisodes != null) {
      keepSkippedEpisodesConfig = keepSkippedEpisodes;
    }

    savePlaybackSettings({
      'fastForwardInterval': fastForwardIntervalConfig,
      'rewindInterval': rewindIntervalConfig,
      'playbackSpeed': playbackSpeedConfig,
      'enqueuePosition': enqueuePositionConfig,
      'enqueueDownloaded': enqueueDownloadedConfig,
      'continuePlayback': autoplayNextInQueueConfig,
      'smartMarkAsCompleted': smartMarkAsCompletionConfig,
      'keepSkippedEpisodes': keepSkippedEpisodesConfig,
    });
    notifyListeners();
  }

  void updateAutomaticSettings({
    String? refreshPodcasts,
    bool? downloadNewEpisodes,
    bool? downloadQueuedEpisodes,
    String? downloadEpisodeLimit,
    bool? deletePlayedEpisodes,
    bool? keepFavouriteEpisodes,
  }) {
    if (refreshPodcasts != null) refreshPodcastsConfig = refreshPodcasts;
    if (downloadNewEpisodes != null) {
      downloadNewEpisodesConfig = downloadNewEpisodes;
    }
    if (downloadQueuedEpisodes != null) {
      downloadQueuedEpisodesConfig = downloadQueuedEpisodes;
    }
    if (downloadEpisodeLimit != null) {
      downloadEpisodeLimitConfig = downloadEpisodeLimit;
    }
    if (deletePlayedEpisodes != null) {
      deletePlayedEpisodesConfig = deletePlayedEpisodes;
    }
    if (keepFavouriteEpisodes != null) {
      keepFavouriteEpisodesConfig = keepFavouriteEpisodes;
    }

    saveAutomaticSettings({
      'refreshPodcasts': refreshPodcastsConfig,
      'downloadNewEpisodes': downloadNewEpisodesConfig,
      'downloadQueuedEpisodes': downloadQueuedEpisodesConfig,
      'downloadEpisodeLimit': downloadEpisodeLimitConfig,
      'deletePlayedEpisodes': deletePlayedEpisodesConfig,
      'keepFavouriteEpisodes': keepFavouriteEpisodesConfig,
    });
    notifyListeners();
  }

  void updateSynchronizationSettings({
    bool? syncFavourites,
    bool? syncQueue,
    bool? syncHistory,
    bool? syncPlaybackPosition,
    bool? syncSettings,
  }) {
    if (syncFavourites != null) syncFavouritesConfig = syncFavourites;
    if (syncQueue != null) syncQueueConfig = syncQueue;
    if (syncHistory != null) syncHistoryConfig = syncHistory;
    if (syncPlaybackPosition != null) {
      syncPlaybackPositionConfig = syncPlaybackPosition;
    }
    if (syncSettings != null) syncSettingsConfig = syncSettings;

    saveSynchronizationSettings({
      'syncFavourites': syncFavouritesConfig,
      'syncQueue': syncQueueConfig,
      'syncHistory': syncHistoryConfig,
      'syncPlaybackPosition': syncPlaybackPositionConfig,
      'syncSettings': syncSettingsConfig,
    });
    notifyListeners();
  }

  void updateNotificationsSettings({
    bool? receiveNotificationsForNewEpisodes,
    bool? receiveNotificationsWhenDownloading,
    bool? receiveNotificationsWhenPlaying,
  }) {
    if (receiveNotificationsForNewEpisodes != null) {
      receiveNotificationsForNewEpisodesConfig =
          receiveNotificationsForNewEpisodes;
    }
    if (receiveNotificationsWhenDownloading != null) {
      receiveNotificationsWhenDownloadConfig =
          receiveNotificationsWhenDownloading;
    }
    if (receiveNotificationsWhenPlaying != null) {
      receiveNotificationsWhenPlayConfig = receiveNotificationsWhenPlaying;
    }

    saveNotificationsSettings({
      'receiveNotificationsForNewEpisodes':
          receiveNotificationsForNewEpisodesConfig,
      'receiveNotificationsWhenDownloading':
          receiveNotificationsWhenDownloadConfig,
      'receiveNotificationsWhenPlaying': receiveNotificationsWhenPlayConfig,
    });
    notifyListeners();
  }

  void updateImportExportSettings({bool? autoBackup}) {
    if (autoBackup != null) automaticExportDatabaseConfig = autoBackup;

    saveImportExportSettings({
      'autoBackup': automaticExportDatabaseConfig,
    });
    notifyListeners();
  }
}
