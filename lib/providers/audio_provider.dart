import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/completed_episode_model.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/history_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/nav_pages/queue_page.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';
import 'package:openair/views/navigation/app_drawer.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/nav_pages/favorites_page.dart';
import 'package:opml/opml.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

final audioProvider = ChangeNotifierProvider<AudioProvider>(
  (ref) {
    return AudioProvider(ref);
  },
);

enum DownloadStatus { downloaded, downloading, notDownloaded }

enum PlayingStatus { detail, buffering, playing, paused, stop }

class AudioProvider extends ChangeNotifier {
  AudioProvider(this.ref);

  Ref ref;

  late AudioPlayer player;

  PodcastModel? currentPodcast;
  Map<String, dynamic>? currentEpisode;
  Map<String, dynamic>? nextEpisode;

  bool isPodcastSelected = false;
  bool onceQueueComplete = false;
  bool isCompleted = false;

  late String podcastTitle;
  late String podcastSubtitle;

  late String audioState; // Play, Pause, Stop
  late String loadState; // Play, Load, Detail

  late Duration playerPosition;
  late Duration playerTotalDuration;

  late double podcastCurrentPositionInMilliseconds;
  late String currentPlaybackPositionString;
  late String currentPlaybackRemainingTimeString;

  late PlayingStatus isPlaying = PlayingStatus.stop;

  late String? currentPodcastTimeRemaining;

  List<String> audioSpeedOptions = ['0.5x', '1.0x', '1.25x', '1.5x', '2.0x'];

  List downloadingPodcasts = [];

  Future<void> initAudio(BuildContext context) async {
    player = AudioPlayer();

    podcastSubtitle = 'podcastImage';
    podcastSubtitle = 'name';

    playerPosition = Duration.zero;
    playerTotalDuration = Duration.zero;

    podcastCurrentPositionInMilliseconds = 0;
    currentPlaybackPositionString = '00:00:00';
    currentPlaybackRemainingTimeString = '00:00:00';

    currentEpisode = {};
    nextEpisode = {};

    audioState = 'Pause';
    loadState = 'Detail'; // Play, Load, Detail
  }

  Icon getDownloadIcon(DownloadStatus downloadStatus) {
    Icon icon;

    switch (downloadStatus) {
      case DownloadStatus.notDownloaded:
        icon = const Icon(Icons.download_rounded);
        break;
      case DownloadStatus.downloading:
        icon = const Icon(Icons.downloading_rounded);
        break;
      case DownloadStatus.downloaded:
        icon = const Icon(Icons.download_done_rounded);
        break;
    }

    return icon;
  }

  Future<void> playerPlayButtonClicked(
    Map<String, dynamic> episodeItem,
    BuildContext context,
  ) async {
    currentEpisode = episodeItem;
    bool isDownloaded = await isAudioFileDownloaded(currentEpisode!['guid']);

    isPodcastSelected = true;
    onceQueueComplete = false;
    isCompleted = false;

    try {
      // Checks if the episode has already been downloaded
      if (isDownloaded == true) {
        final downloadsDir = await getDownloadsDir();
        final filePath = path.join(downloadsDir, '${episodeItem['guid']}.mp3');

        await player
            .play(DeviceFileSource(filePath))
            .timeout(const Duration(seconds: 30));
      } else {
        await player
            .play(UrlSource(currentEpisode!['enclosureUrl']))
            .timeout(const Duration(seconds: 30));
      }

      if (context.mounted && receiveNotificationsWhenPlayConfig) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('playing')}:${episodeItem['title']}',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('playing')}:${episodeItem['title']}',
              ),
            ),
          );
        }
      }

      if (episodeItem['guid'] == currentEpisode!['guid']) {
        isPlaying = PlayingStatus.playing;
      }

      addToHistory(
        episodeItem,
        currentPodcast,
      );

      audioState = 'Play';
      loadState = 'Play';
      nextEpisode = currentEpisode;
      if (context.mounted) updatePlaybackBar(context);
      notifyListeners();
    } on TimeoutException catch (e) {
      debugPrint('Timeout playing audio: $e');
      isPlaying = PlayingStatus.stop;
      audioState = 'Stop';
      loadState = 'Detail';
      notifyListeners();
      if (context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}125',
              );
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}125',
          //     ),
          //   ),
          // );
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      isPlaying = PlayingStatus.stop;
      audioState = 'Stop';
      loadState = 'Detail';
      notifyListeners();

      if (context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}130',
              );
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}130',
          //     ),
          //   ),
          // );
        }
      }
    }
  }

  /// Returns the directory where downloaded episodes are stored.
  /// This method creates the directory if it doesn't exist.
  Future<String> getDownloadsDir() async {
    if (kIsWeb) {
      throw UnsupportedError(
          'File system operations are not supported on web.');
    }

    // The HiveService initializes and holds the reference to the app's base directory.
    final hiveService = ref.read(hiveServiceProvider);
    final baseDir = hiveService.openAirDir;

    // Define a specific subdirectory for downloads to keep things organized.
    final downloadsDirPath = path.join(baseDir.path, '.downloaded_episodes');

    final downloadsDir = Directory(downloadsDirPath);

    // Ensure the directory exists before we try to use it.
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    return downloadsDir.path;
  }

  Future<bool> isAudioFileDownloaded(String guid) async {
    if (kIsWeb) {
      return false;
    }

    // The filename is consistently the GUID with a .mp3 extension.
    final filename = '$guid.mp3';
    final downloadsDir = await getDownloadsDir();
    final filePath = path.join(downloadsDir, filename);
    return File(filePath).exists();
  }

  Future<void> removeAllDownloadedPodcasts(BuildContext context) async {
    if (kIsWeb) {
      if (context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}140',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}140',
              ),
            ),
          );
        }
      }
      return;
    }

    try {
      final downloadsDirPath = await getDownloadsDir();
      final downloadsDirectory = Directory(downloadsDirPath);

      if (await downloadsDirectory.exists()) {
        // Use async listing and deletion
        await for (final entity in downloadsDirectory.list()) {
          await entity.delete(recursive: true);
        }
      }

      final hiveService = ref.read(hiveServiceProvider);
      await hiveService.clearDownloads();

      if (context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                Translations.of(context).text('removedAllDownloadedPodcasts'),
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Translations.of(context).text('removedAllDownloadedPodcasts'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error removing all downloaded podcasts: $e');

      if (context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}145',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}145',
              ),
            ),
          );
        }
      }
    }

    notifyListeners();
  }

  Future<void> downloadEpisode(
    Map<String, dynamic> item,
    PodcastModel podcast,
    BuildContext? context,
  ) async {
    final hiveService = ref.read(hiveServiceProvider);

    // Get the download limit.
    final downloadLimitString = downloadEpisodeLimitConfig;

    final downloadLimit = downloadLimitString != 'Unlimited'
        ? int.tryParse(downloadLimitString)
        : null;

    // Get the number of downloaded episodes.
    final downloadedCount = await hiveService.downloadsCount();

    // Check if the limit has been reached.
    if (downloadLimit != null && downloadedCount >= downloadLimit) {
      if (context!.mounted && receiveNotificationsWhenDownloadConfig) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('downloadLimitOf')} $downloadLimit ${Translations.of(context).text('episodesReached')}',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('downloadLimitOf')} $downloadLimit ${Translations.of(context).text('episodesReached')}',
              ),
            ),
          );
        }
      }

      return;
    }

    final dio = Dio();

    final guid = item['guid'] as String;
    final url = item['enclosureUrl'] as String;

    final size = getEpisodeSize(item['enclosureLength']);

    if (downloadingPodcasts.contains(guid)) {
      return;
    }

    downloadingPodcasts.add(guid);
    notifyListeners();

    try {
      String filename = '${item['guid']}.mp3';
      final downloadsDir = await getDownloadsDir();
      final savePath = path.join(downloadsDir, filename);

      await dio.download(url, savePath);

      final downloadModel = DownloadModel(
        guid: guid,
        image: item['image'] ?? item['feedImage'],
        title: item['title'],
        author: item['author'],
        datePublished: item['datePublished'],
        description: item['description'],
        feedUrl: item['feedUrl'],
        duration: Duration(milliseconds: item['duration']),
        size: size,
        podcastId: podcast.id,
        enclosureLength: item['enclosureLength'],
        enclosureUrl: item['enclosureUrl'],
        downloadDate: DateTime.now(),
        fileName: filename,
      );

      await hiveService.addToDownloads(downloadModel);

      ref.invalidate(sortedDownloadsProvider);
      ref.invalidate(downloadsCountProvider);

      if (context != null && context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('downloadEpisode')}: \'${item['title']}\'',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('downloadEpisode')}: \'${item['title']}\'',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading ${item['title']}: $e');

      String filename = '${item['guid']}.mp3';

      final filePath = await getDownloadsDir();
      final file = File('$filePath/$filename');

      if (await file.exists()) {
        await file.delete();
      }

      if (context != null && context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}150',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}150',
              ),
            ),
          );
        }
      }
    } finally {
      downloadingPodcasts.remove(guid);
      notifyListeners();
    }
  }

  Future<void> removeDownload(Map<String, dynamic> item) async {
    if (kIsWeb) {
      // This action is not possible on the web.
      return;
    }
    final guid = item['guid'] as String;

    try {
      String filename = '${item['guid']}.mp3';
      final filePath = await getDownloadsDir();
      final file = File('$filePath/$filename');

      if (await file.exists()) {
        await file.delete();
      }

      final hiveService = ref.read(hiveServiceProvider);
      await hiveService.deleteDownload(guid);

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing download for ${item['title']}: $e');
    }
  }

  Future<void> queuePlayButtonClicked(
    Map<String, dynamic> queueItem,
    Duration position,
    BuildContext context,
  ) async {
    bool isDownloaded = await isAudioFileDownloaded(queueItem['guid']);

    currentEpisode = queueItem;

    isPodcastSelected = true;
    onceQueueComplete = false;
    isCompleted = false;

    playerPosition = position;

    // Checks if the episode has already been downloaded
    if (isDownloaded == true) {
      String filename = '${currentEpisode!['guid']}.mp3';
      final filePath = await getDownloadsDir();
      final file = File('$filePath/$filename');

      await player.play(
        DeviceFileSource(file.path),
        position: position,
      );
    } else {
      await player.play(
        UrlSource(currentEpisode!['enclosureUrl']),
        position: position,
      );
    }

    if (context.mounted && receiveNotificationsWhenPlayConfig) {
      if (!Platform.isAndroid && !Platform.isIOS) {
        ref.read(notificationServiceProvider).showNotification(
              'OpenAir ${Translations.of(context).text('notification')}',
              '${Translations.of(context).text('playing')}:${currentEpisode!['title']}',
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Translations.of(context).text('playing')}:${currentEpisode!['title']}',
            ),
          ),
        );
      }
    }

    if (queueItem['guid'] == currentEpisode!['guid']) {
      isPlaying = PlayingStatus.playing;
    }

    addToHistory(
      queueItem,
      currentPodcast,
    );

    audioState = 'Play';
    loadState = 'Play';
    nextEpisode = currentEpisode;
    if (context.mounted) updatePlaybackBar(context);
    notifyListeners();
  }

  Future<void> playerResumeButtonClicked() async {
    if (player.state == PlayerState.paused) {
      await player.resume();
      audioState = 'Play';
      // loadState can remain 'Detail' or be set to 'Play' based on desired UI behaviour
      loadState = 'Play';
      isPlaying = PlayingStatus.playing;
      notifyListeners();
    }
    // If player was stopped but currentEpisode is set, one might consider
    // re-playing it from its last known position, but that's more complex
    // than a simple resume. For now, resume only works from paused state.
  }

  Future<void> playerPauseButtonClicked() async {
    if (player.state == PlayerState.playing) {
      await player.pause();
      audioState = 'Pause';
      loadState = 'Detail';
      isPlaying = PlayingStatus.paused;
    }
  }

  Future<void> playPreviousEpisode(
    BuildContext context,
  ) async {
    // 1. Check if currentEpisode is set
    if (currentEpisode == null || currentEpisode!.isEmpty) {
      return;
    }

    final hiveService = ref.read(hiveServiceProvider);
    Map queueMap = await hiveService.getQueue();

    // Convert to list and sort by position
    List<Map<String, dynamic>> queueList =
        queueMap.values.map((e) => Map<String, dynamic>.from(e)).toList();

    queueList.sort((a, b) => (a['pos'] as int).compareTo(b['pos'] as int));

    // Find the index of the current episode
    int currentEpisodeIndex = -1;

    for (int i = 0; i < queueList.length; i++) {
      if (queueList[i]['guid'] == currentEpisode!['guid']) {
        currentEpisodeIndex = i;
        break;
      }
    }

    if (!keepSkippedEpisodesConfig) {
      await hiveService.removeFromQueue(guid: currentEpisode!['guid']);
    }

    // 2. If current episode is not found or is the first, do nothing
    if (currentEpisodeIndex == -1 || currentEpisodeIndex == 0) {
      return; // Do nothing if it's the first or not found
    }

    // 3. Save progress of the current episode before switching
    await updateCurrentQueueCard(
      currentEpisode!['guid'],
      podcastCurrentPositionInMilliseconds,
      currentPlaybackPositionString,
      currentPlaybackRemainingTimeString,
      playerPosition,
    );

    // 4. Stop current playback and play the previous episode
    await player.stop(); // Ensure player is stopped before changing source

    Map<String, dynamic> previousEpisode = queueList[currentEpisodeIndex - 1];
    currentEpisode = previousEpisode;

    currentPodcast = previousEpisode[
        'podcast']; // Assuming 'podcast' is stored in queue item

    if (context.mounted) {
      await queuePlayButtonClicked(
        previousEpisode,
        previousEpisode['playerPosition'],
        context,
      );
    }

    notifyListeners();
  }

  void rewindButtonClicked() {
    if (playerPosition.inSeconds - int.parse(rewindIntervalConfig) > 0) {
      player.seek(Duration(
          seconds: playerPosition.inSeconds - int.parse(rewindIntervalConfig)));
    }
  }

  void fastForwardButtonClicked() {
    if (playerPosition.inSeconds + int.parse(fastForwardIntervalConfig) <
        playerTotalDuration.inSeconds) {
      player.seek(Duration(
          seconds:
              playerPosition.inSeconds + int.parse(fastForwardIntervalConfig)));
    }
  }

  Future<void> playNextEpisode(BuildContext context) async {
    // 1. Check if there's a current episode playing.
    if (currentEpisode == null || currentEpisode!.isEmpty) {
      return;
    }

    final hiveService = ref.read(hiveServiceProvider);
    final Map queueMap = await hiveService.getQueue();

    // Convert to a list and sort by position to ensure correct order.
    List<Map<String, dynamic>> queueList =
        queueMap.values.map((e) => Map<String, dynamic>.from(e)).toList();
    queueList.sort((a, b) => (a['pos'] as int).compareTo(b['pos'] as int));

    // Find the index of the current episode in the sorted queue.
    int currentEpisodeIndex = -1;
    for (int i = 0; i < queueList.length; i++) {
      if (queueList[i]['guid'] == currentEpisode!['guid']) {
        currentEpisodeIndex = i;
        break;
      }
    }

    if (!keepSkippedEpisodesConfig) {
      await hiveService.removeFromQueue(guid: currentEpisode!['guid']);
    }

    // 2. If the episode isn't in the queue or is already the last one, do nothing.
    if (currentEpisodeIndex == -1 ||
        currentEpisodeIndex == queueList.length - 1) {
      return;
    }

    // 3. Save the progress of the currently playing episode before switching.
    await updateCurrentQueueCard(
      currentEpisode!['guid'],
      podcastCurrentPositionInMilliseconds,
      currentPlaybackPositionString,
      currentPlaybackRemainingTimeString,
      playerPosition,
    );

    // 4. Stop the current playback.
    await player.stop();

    // 5. Get the next episode's data and start playing it.
    final Map<String, dynamic> nextEpisode = queueList[currentEpisodeIndex + 1];
    currentEpisode = nextEpisode;
    currentPodcast = nextEpisode['podcast'];

    if (context.mounted) {
      await queuePlayButtonClicked(
          nextEpisode, nextEpisode['playerPosition'], context);
    }

    notifyListeners();
  }

  void audioSpeedButtonClicked() {
    int index = audioSpeedOptions.indexOf(playbackSpeedConfig);
    int newIndex = (index + 1) % audioSpeedOptions.length;
    playbackSpeedConfig = audioSpeedOptions[newIndex];
    player.setPlaybackRate(double.parse(playbackSpeedConfig.split('x').first));
    notifyListeners();
  }

  void timerButtonClicked() {}

  void updatePlaybackBar(BuildContext context) async {
    player.getDuration().then((Duration? value) {
      if (value != null) {
        playerTotalDuration = value;
        notifyListeners();
      } else {
        player.setSourceUrl(currentEpisode!['enclosureUrl']);
        if (context.mounted) updatePlaybackBar(context);
      }
    });

    player.onPositionChanged.listen((Duration p) async {
      playerPosition = p;

      currentPlaybackPositionString =
          formatCurrentPlaybackPosition(playerPosition);

      if (context.mounted) {
        currentPlaybackRemainingTimeString = formatCurrentPlaybackRemainingTime(
            playerPosition, playerTotalDuration, context);
      }

      podcastCurrentPositionInMilliseconds =
          (playerPosition.inMilliseconds / playerTotalDuration.inMilliseconds)
              .clamp(0.0, 1.0);

      if (smartMarkAsCompletionConfig != 'Disabled' && !isCompleted) {
        int sec = int.parse(smartMarkAsCompletionConfig);

        Future.delayed(Duration(seconds: 3), () async {
          int remainingTimeInSeconds =
              playerTotalDuration.inSeconds - playerPosition.inSeconds;

          if (remainingTimeInSeconds < sec && isCompleted == false) {
            isCompleted = true;

            final hiveService = ref.read(hiveServiceProvider);

            hiveService.addToCompletedEpisode(
              CompletedEpisodeModel(guid: currentEpisode!['guid']),
            );
          }
        });
      }

      notifyListeners();
    });

    player.onPlayerStateChanged.listen((PlayerState playerState) async {
      if (playerState == PlayerState.completed) {
        if (!onceQueueComplete) {
          onceQueueComplete = true;

          isPodcastSelected = false;
          audioState = 'Stop';
          isPlaying = PlayingStatus.stop;

          final hiveService = ref.read(hiveServiceProvider);
          hiveService.addToCompletedEpisode(
            CompletedEpisodeModel(guid: currentEpisode!['guid']),
          );

          await updateCurrentQueueCard(
            currentEpisode!['guid'],
            podcastCurrentPositionInMilliseconds,
            currentPlaybackPositionString,
            currentPlaybackRemainingTimeString,
            playerPosition,
          );

          if (autoplayNextInQueueConfig && context.mounted) {
            playNextInQueue(context);
          }
        }
      } else if (playerState == PlayerState.paused) {
        if (!onceQueueComplete) {
          onceQueueComplete = true;

          audioState = 'Pause';
          isPlaying = PlayingStatus.paused;

          await updateCurrentQueueCard(
            currentEpisode!['guid'],
            podcastCurrentPositionInMilliseconds,
            currentPlaybackPositionString,
            currentPlaybackRemainingTimeString,
            playerPosition,
          );
        }
      }
    });

    notifyListeners();
  }

  Future<void> playNewQueueItem(
    Map<String, dynamic> newItem,
    BuildContext context,
  ) async {
    // 1. Save progress of the current episode if one is active.
    if ((isPlaying == PlayingStatus.playing ||
            isPlaying == PlayingStatus.paused) &&
        currentEpisode != null) {
      // The provider's state is updated by onPositionChanged, so it's fresh enough.
      await updateCurrentQueueCard(
        currentEpisode!['guid'],
        podcastCurrentPositionInMilliseconds,
        currentPlaybackPositionString,
        currentPlaybackRemainingTimeString,
        playerPosition,
      );
    }

    if (context.mounted) {
      // 2. Play the new item from its saved position.
      await queuePlayButtonClicked(
        newItem,
        newItem['playerPosition'],
        context,
      );
    }
  }

  void playNextInQueue(BuildContext context) async {
    if (currentEpisode == null || currentEpisode!['guid'] == null) {
      isPodcastSelected = false;
      audioState = 'Stop';
      isPlaying = PlayingStatus.stop;
      notifyListeners();
      return;
    }

    final String completedEpisodeGuid = currentEpisode!['guid'];

    try {
      // Attempt to stop the player. It's okay if it's already stopped.
      // This helps ensure a clean state before playing the next track.
      if (player.state != PlayerState.stopped) {
        await player.stop();
        isPodcastSelected = false;
        audioState = 'Stop';
        isPlaying = PlayingStatus.stop;
      }

      final hiveService = ref.read(hiveServiceProvider);

      // 1. Remove the completed episode from the queue
      await hiveService.removeFromQueue(guid: completedEpisodeGuid);

      // 2. Add to completed episodes
      await hiveService.addToCompletedEpisode(
          CompletedEpisodeModel(guid: completedEpisodeGuid));

      ref.invalidate(getQueueProvider);
      ref.invalidate(sortedDownloadsProvider);

      // 3. Get the updated queue to determine the next episode.
      final updatedQueue = await hiveService.getQueue();

      if (updatedQueue.isNotEmpty) {
        // 4. If the queue is not empty, play the next episode.
        final Map<dynamic, dynamic> nextEpisodeToPlay =
            updatedQueue.entries.first.value;

        final episodeData = Map<String, dynamic>.from(nextEpisodeToPlay);

        currentEpisode = episodeData;

        PodcastModel podcastData = episodeData['podcast'];
        currentPodcast = podcastData;

        if (context.mounted) playNewQueueItem(episodeData, context);
      } else {
        // 5. If the queue is empty, reset player state.
        isPodcastSelected = false;
        audioState = 'Stop';
        isPlaying = PlayingStatus.stop;
        currentEpisode = null; // Clear the current episode
        // Reset playback bar values
        playerPosition = Duration.zero;
        playerTotalDuration = Duration.zero;
        podcastCurrentPositionInMilliseconds = 0;
        currentPlaybackPositionString = '00:00:00';
        currentPlaybackRemainingTimeString = '00:00:00';
        notifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error in playNextInQueue: $e');
      debugPrint('Stack trace: $s');
      // Fallback: Reset player state on error
      isPodcastSelected = false;
      audioState = 'Stop';
      isPlaying = PlayingStatus.stop;
      currentEpisode = null;
      notifyListeners();
    }
  }

  String formatCurrentPlaybackPosition(Duration timeline) {
    int hours = timeline.inHours;
    // Correctly get the minute part (0-59)
    int minutes = timeline.inMinutes % 60;

    int seconds = timeline.inSeconds % 60;

    String result =
        "${hours != 0 ? hours < 10 ? '0$hours:' : '$hours:' : '00:'}${minutes != 0 ? minutes < 10 ? '0$minutes:' : '$minutes:' : '00:'}${seconds != 0 ? seconds < 10 ? '0$seconds' : '$seconds' : '00'}";

    return result;
  }

  String getPodcastPublishedDateFromEpoch(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String getPodcastDuration(int epoch, BuildContext context) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    int hours = dateTime.hour;
    int minutes = dateTime.minute;
    // int seconds = dateTime.second;

    String result =
        "${hours != 0 ? hours < 10 ? hours == 1 ? '01 ${Translations.of(context).text('hour')} ' : '0$hours ${Translations.of(context).text('hours')} ' : '$hours ${Translations.of(context).text('hours')} ' : ''}${minutes != 0 ? minutes < 10 ? '0$minutes ${Translations.of(context).text('minutes')} ' : '$minutes ${Translations.of(context).text('minute')} ' : '00 ${Translations.of(context).text('minute')}'}";

    return result;
  }

  String formatCurrentPlaybackRemainingTime(
    Duration timelinePosition,
    Duration timelineDuration,
    BuildContext context,
  ) {
    int remainingSeconds =
        timelineDuration.inSeconds - timelinePosition.inSeconds;

    remainingSeconds = remainingSeconds > 0 ? remainingSeconds : 0;

    int remainingHours = Duration(seconds: remainingSeconds).inHours;
    int remainingMinutes = Duration(seconds: remainingSeconds).inMinutes % 60;
    int remainingSecondsAdjusted =
        Duration(seconds: remainingSeconds).inSeconds % 60;

    currentPodcastTimeRemaining =
        "${remainingHours != 0 ? remainingHours == 1 ? '1 ${Translations.of(context).text('hour')} ' : '$remainingHours ${Translations.of(context).text('hours')} ' : ''}${remainingMinutes != 0 ? '$remainingMinutes ${Translations.of(context).text('minutes')}' : '< 1 ${Translations.of(context).text('minute')}'} ${Translations.of(context).text('left')}";

    String result =
        "${remainingHours != 0 ? remainingHours < 10 ? '0$remainingHours:' : '$remainingHours:' : '00:'}${remainingMinutes != 0 ? remainingMinutes < 10 ? '0$remainingMinutes:' : '$remainingMinutes:' : '00:'}${remainingSecondsAdjusted != 0 ? remainingSecondsAdjusted < 10 ? '0$remainingSecondsAdjusted' : '$remainingSecondsAdjusted' : '00'}";

    return result;
  }

  // Update the main player slider position based on the slider value.
  void mainPlayerSliderClicked(double sliderValue) {
    Duration duration = Duration(
        milliseconds:
            (sliderValue * playerTotalDuration.inMilliseconds).toInt());

    podcastCurrentPositionInMilliseconds =
        ((sliderValue * playerTotalDuration.inMilliseconds) /
                playerTotalDuration.inMilliseconds)
            .clamp(0.0, 1.0);

    player.seek(duration);
    notifyListeners();
  }

  void mainPlayerTimerClicked() {}

  void mainPlayerCastClicked() {}

  void mainPlayerMoreOptionsClicked() {}

  void removeFromQueue(String guid) async {
    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.removeFromQueue(guid: guid);
    ref.invalidate(sortedProvider);
    ref.invalidate(getQueueProvider);
    notifyListeners();
  }

  void addToQueue(
    Map<String, dynamic> episode,
    PodcastModel? podcast,
  ) async {
    final hiveService = ref.read(hiveServiceProvider);
    Map queue = await hiveService.getQueue();

    List<Map<String, dynamic>> queueList =
        queue.values.map((e) => Map<String, dynamic>.from(e)).toList();

    queueList.sort((a, b) => a['pos'].compareTo(b['pos']));

    int pos;

    switch (enqueuePositionConfig) {
      case 'First':
        pos = 1;
        for (var item in queueList) {
          item['pos'] = item['pos'] + 1;
          await hiveService.addToQueue(item);
        }
        break;
      case 'Last':
        if (queue.isEmpty) {
          pos = 1;
        } else {
          pos = queueList.last['pos'] + 1;
        }
        break;
      case 'After current episode':
        if (currentEpisode != null && currentEpisode!.isNotEmpty) {
          if (queue.isEmpty) {
            pos = 1;
          } else {
            int currentPos = -1;
            try {
              currentPos = queueList.firstWhere((element) =>
                  element['guid'] == currentEpisode!['guid'])['pos'];
            } catch (e) {
              // current episode is not in the queue
              currentPos = queueList.last['pos'];
            }

            pos = currentPos + 1;

            for (var item in queueList) {
              if (item['pos'] >= pos) {
                item['pos'] = item['pos'] + 1;
                await hiveService.addToQueue(item);
              }
            }
          }
        } else {
          // if there is no current episode, add to the end
          if (queue.isEmpty) {
            pos = 1;
          } else {
            pos = queueList.last['pos'] + 1;
          }
        }
        break;
      default:
        if (queue.isEmpty) {
          pos = 1;
        } else {
          pos = queueList.last['pos'] + 1;
        }
    }

    int enclosureLength = episode['enclosureLength'];
    String downloadSize = getEpisodeSize(enclosureLength);

    Duration episodeTotalDuration =
        getEpisodeDuration(episode['enclosureLength']);

    // Determine initial playback state for the queue item
    double initialPositionMilliseconds;
    String initialPositionString;

    if (currentEpisode != null && currentEpisode!['guid'] == episode['guid']) {
      // If the episode being added is the one currently playing, use its current progress
      initialPositionMilliseconds = podcastCurrentPositionInMilliseconds;
      initialPositionString = currentPlaybackPositionString;
      // The QueueModel's remaining time string will be set to the total duration below.
    } else {
      // Otherwise, it's a new item, start from the beginning
      initialPositionMilliseconds = 0.0;
      initialPositionString = formatCurrentPlaybackPosition(Duration.zero);
    }

    final String formattedTotalDurationString =
        formatCurrentPlaybackRemainingTime(
            Duration.zero, episodeTotalDuration, context as BuildContext);

    hiveService.addToQueue({
      'guid': episode['guid'],
      'title': episode['title'],
      'author': episode['author'] ?? 'Unknown',
      'image': episode['feedImage'] ?? episode['image'],
      'datePublished': episode['datePublished'],
      'description': episode['description'],
      'feedUrl': episode['feedUrl'],
      'duration': episodeTotalDuration.inMilliseconds,
      'downloadSize': downloadSize,
      'enclosureType': episode['enclosureType'] ?? 'audio/mpeg',
      'enclosureLength': episode['enclosureLength'],
      'enclosureUrl': episode['enclosureUrl'],
      'podcast': podcast!.toJson(),
      'pos': pos,
      'podcastCurrentPositionInMilliseconds': initialPositionMilliseconds,
      'currentPlaybackPositionString': initialPositionString,
      'currentPlaybackRemainingTimeString': formattedTotalDurationString,
      'playerPosition': Duration.zero.inMilliseconds,
    });

    if (downloadQueuedEpisodesConfig) {
      await downloadEpisode(episode, podcast, null);
    }

    ref.invalidate(sortedProvider);
    ref.invalidate(getQueueProvider);
    notifyListeners();
  }

  Future<void> addPodcastEpisodes(
      SubscriptionModel podcast, BuildContext context) async {
    final podcastIndexService = ref.read(podcastIndexProvider);

    Map<String, dynamic> episodes =
        await podcastIndexService.getEpisodesByFeedUrl(podcast.feedUrl);

    Map episode;

    for (int i = 0; i < episodes['count']; i++) {
      int enclosureLength = episodes['items'][i]['enclosureLength'];
      String? duration;

      if (context.mounted) {
        duration = getPodcastDuration(enclosureLength, context);
      }

      String size = getEpisodeSize(enclosureLength);

      episode = {
        'podcastId': podcast.id.toString(),
        'guid': episodes['items'][i]['guid'],
        'title': episodes['items'][i]['title'],
        'author': episodes['items'][i]['author'],
        'image': episodes['items'][i]['feedImage'],
        'datePublished': episodes['items'][i]['datePublished'],
        'description': episodes['items'][i]['description'],
        'feedUrl': episodes['items'][i]['feedUrl'],
        'duration': duration,
        'size': size,
        'enclosureLength': enclosureLength,
        'enclosureUrl': episodes['items'][i]['enclosureUrl'],
      };

      final hiveService = ref.read(hiveServiceProvider);
      hiveService.insertEpisode(
        episode,
        episode['guid'],
      );
    }

    ref.invalidate(feedCountProvider);
    notifyListeners();
  }

  void removePodcastEpisodes(PodcastModel podcast) async {
    final hiveService = ref.read(hiveServiceProvider);
    hiveService.deleteEpisode(podcast.title);
    notifyListeners();
  }

  void subscribe(
    PodcastModel podcast,
    BuildContext context,
  ) async {
    try {
      int podcastEpisodeCount = await ref
          .read(podcastIndexProvider)
          .getPodcastEpisodeCountByPodcastId(podcast.id);

      SubscriptionModel subscription = SubscriptionModel(
        id: podcast.id,
        title: podcast.title,
        author: podcast.author,
        feedUrl: podcast.feedUrl,
        imageUrl: podcast.imageUrl,
        episodeCount: podcastEpisodeCount,
        description: podcast.description,
        artwork: podcast.artwork,
        updatedAt: DateTime.now(),
      );

      final hiveService = ref.read(hiveServiceProvider);
      hiveService.subscribe(subscription);
      if (context.mounted) await addPodcastEpisodes(subscription, context);

      // subscriptionsProvider (from hive_provider.dart) will update reactively
      // as it watches hiveServiceProvider, which is notified by the subscribe call.
      ref.invalidate(getFeedsProvider);
      notifyListeners();
    } on DioException {
      if (context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}160',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}160',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to subscribe to ${podcast.title}: $e');

      if (context.mounted) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          ref.read(notificationServiceProvider).showNotification(
                'OpenAir ${Translations.of(context).text('notification')}',
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}163',
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}163',
              ),
            ),
          );
        }
      }
    }
  }

  void subscribeByRssFeed(
    SubscriptionModel podcast,
    BuildContext context,
  ) async {
    try {
      int podcastEpisodeCount = await ref
          .read(podcastIndexProvider)
          .getPodcastEpisodeCountByTitle(podcast.title);

      SubscriptionModel subscription = SubscriptionModel(
        id: podcast.id,
        title: podcast.title,
        author: podcast.author,
        feedUrl: podcast.feedUrl,
        imageUrl: podcast.imageUrl,
        episodeCount: podcastEpisodeCount,
        description: podcast.description,
        artwork: podcast.artwork,
        updatedAt: DateTime.now(),
      );

      final hiveService = ref.read(hiveServiceProvider);
      hiveService.subscribe(subscription);
      if (context.mounted) await addPodcastEpisodes(podcast, context);
    } on DioException catch (e) {
      debugPrint(
          'Failed to subscribe to ${podcast.title}. DioError: ${e.message}. Stack trace: ${e.stackTrace}');

      rethrow;
    } catch (e) {
      debugPrint('Failed to subscribe to ${podcast.title}: $e');
      rethrow;
    }
  }

  void unsubscribe(PodcastModel podcast) async {
    final hiveService = ref.read(hiveServiceProvider);
    hiveService.unsubscribe(podcast.title);
    removePodcastEpisodes(podcast);

    // subscriptionsProvider (from hive_provider.dart) will update reactively
    // as it watches hiveServiceProvider, which is notified by the unsubscribe call.
    ref.invalidate(getFeedsProvider);
    notifyListeners();
  }

  Future<bool> addPodcastByRssUrl(String rssUrl, BuildContext context) async {
    try {
      String? xmlString = await ref
          .watch(fyydProvider)
          .getPodcastXml(rssUrl, context as BuildContext?);

      RssFeed rssFeed = RssFeed.parse(xmlString);

      SubscriptionModel podcast = SubscriptionModel(
        id: 0,
        title: rssFeed.title!,
        author: rssFeed.itunes?.author ?? rssFeed.dc?.creator ?? 'Unknown',
        feedUrl: rssUrl,
        imageUrl: rssFeed.itunes!.image!.href!,
        episodeCount: 0,
        description: rssFeed.description!,
        artwork: rssFeed.itunes!.image!.href!,
        updatedAt: DateTime.now(),
      );

      if (context.mounted) subscribeByRssFeed(podcast, context);
      return true;
    } on DioException catch (e) {
      debugPrint('DioError: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Failed to add podcast by RSS URL: $e');
      return false;
    }
  }

  Future<bool> importPodcastFromOpml(BuildContext context) async {
    String defaultFilePath;
    FilePickerResult? result;

    if (Platform.isAndroid) {
      defaultFilePath = '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      defaultFilePath = (await getApplicationDocumentsDirectory()).path;
    } else {
      defaultFilePath = (await getDownloadsDirectory())?.path ??
          (await getApplicationDocumentsDirectory()).path;
    }

    if (context.mounted) {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: Translations.of(context).text('importOpml'),
        type: FileType.custom,
        allowedExtensions: ['opml'],
        initialDirectory: defaultFilePath,
      );
    }

    if (result != null) {
      File file = File(result.files.single.path!);
      final xml = file.readAsStringSync();

      final doc = OpmlDocument.parse(xml);

      for (var feed in doc.body) {
        if (context.mounted) await addPodcastByRssUrl(feed.xmlUrl!, context);
      }

      return true;
    } else {
      return false;
    }
  }

  Duration getEpisodeDuration(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    int hours = dateTime.hour;
    int minutes = dateTime.minute;
    int seconds = dateTime.second;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  String getEpisodeSize(int size) {
    // Check if size is in bytes, kilobytes, or megabytes
    if (size < 1024) {
      return '$size Bytes';
    } else if (size < 1024 * 1024) {
      double sizeKB = size / 1024;
      return '${sizeKB.toStringAsFixed(2)} KB';
    } else {
      double sizeMB = size / (1024 * 1024);
      if (sizeMB < 1024) {
        return '${sizeMB.toStringAsFixed(2)} MB';
      } else {
        double sizeGB = sizeMB / 1024;
        return '${sizeGB.toStringAsFixed(2)} GB';
      }
    }
  }

  void addToHistory(
    Map<String, dynamic> episode,
    PodcastModel? podcast,
  ) async {
    final String downloadSize = getEpisodeSize(episode['enclosureLength']);

    final Duration episodeTotalDuration = getEpisodeDuration(
      episode['enclosureLength'].runtimeType == String
          ? int.parse(episode['enclosureLength'])
          : episode['enclosureLength'],
    );

    String historyPodcastId;
    String historyPodcastImage;
    String? historyPodcastAuthor;

    // Determine the correct podcast ID, image, and author based on the 'podcast' map structure
    if (podcast != null) {
      historyPodcastId = podcast.id.toString();
      historyPodcastImage = podcast.imageUrl;
      historyPodcastAuthor = podcast.author ?? 'Unknown';
    } else {
      historyPodcastId = episode['podcastId']?.toString() ?? 'unknown';
      historyPodcastImage = episode['image'] ?? '';
      historyPodcastAuthor = episode['author'] ?? 'Unknown';
    }

    HistoryModel historyMod = HistoryModel(
      guid: episode['guid'],
      image: historyPodcastImage,
      title: episode['title'],
      author: historyPodcastAuthor!,
      datePublished: episode['datePublished'],
      description: episode['description'],
      feedUrl: episode['feedUrl'],
      duration: episodeTotalDuration.inSeconds.toString(),
      size: downloadSize,
      podcastId: historyPodcastId,
      enclosureLength: episode['enclosureLength'],
      enclosureUrl: episode['enclosureUrl'],
      playDate: DateTime.now().millisecondsSinceEpoch,
    );

    final hiveService = ref.read(hiveServiceProvider);
    hiveService.addToHistory(historyMod);
  }

  Future<void> updateCurrentQueueCard(
    String guid,
    double podcastCurrentPositionInMilliseconds,
    String currentPlaybackPositionString,
    String currentPlaybackRemainingTimeString,
    Duration position,
  ) async {
    final hiveService = ref.read(hiveServiceProvider);

    // Retrieve the existing QueueModel from Hive
    Map? existingQueueItem = await hiveService.getQueueByGuid(guid);

    if (existingQueueItem != null) {
      // Update the properties of the existing item
      existingQueueItem['podcastCurrentPositionInMilliseconds'] =
          podcastCurrentPositionInMilliseconds;

      existingQueueItem['currentPlaybackPositionString'] =
          currentPlaybackPositionString;

      existingQueueItem['currentPlaybackRemainingTimeString'] =
          currentPlaybackRemainingTimeString;

      existingQueueItem['playerPosition'] = position;
      await hiveService.addToQueue(existingQueueItem);
    }
  }

  Future<void> addEpisodeToFavorite(
      Map<String, dynamic> episode, PodcastModel podcast) async {
    final hiveService = ref.read(hiveServiceProvider);
    hiveService.addEpisodeToFavorite(episode, podcast);
    ref.invalidate(getFavoriteProvider);
  }

  Future<void> removeEpisodeFromFavorite(String guid) async {
    final hiveService = ref.read(hiveServiceProvider);
    hiveService.removeEpisodeFromFavorite(guid);
    ref.invalidate(getFavoriteProvider);
  }

  Future<Map?> getFavoriteEpisodes() async {
    final hiveService = ref.read(hiveServiceProvider);
    return await hiveService.getFavoriteEpisodes();
  }

  Future<bool> isEpisodesFavorite(String guid) async {
    final hiveService = ref.read(hiveServiceProvider);
    final Map<dynamic, dynamic>? favoriteEpisodes =
        await hiveService.favoritesBox.then((box) => box.get(guid));

    if (favoriteEpisodes != null) {
      return true;
    }

    return false;
  }
}
