import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/models/completed_episode_model.dart';
import 'package:openair/models/download_model.dart';
import 'package:openair/models/episode_model.dart';
import 'package:openair/models/history_model.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/models/podcast_model.dart';
import 'package:openair/models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/nav_pages/downloads_page.dart';
import 'package:openair/views/mobile/nav_pages/feeds_page.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

final openAirProvider = ChangeNotifierProvider<OpenAirProvider>(
  (ref) => OpenAirProvider(ref),
);

enum DownloadStatus { downloaded, downloading, notDownloaded }

enum PlayingStatus { detail, buffering, playing, paused, stop }

class OpenAirProvider with ChangeNotifier {
  late AudioPlayer player;
  late StreamSubscription? mPlayerSubscription;

  late BuildContext context;

  late String podcastTitle;
  late String podcastSubtitle;

  late String audioState; // Play, Pause, Stop
  late String loadState; // Play, Load, Detail

  late Duration playerPosition;
  late Duration playerTotalDuration;

  late double podcastCurrentPositionInMilliseconds;
  late String currentPlaybackPositionString;
  late String currentPlaybackRemainingTimeString;

  final String storagePath = 'openair/downloads';

  Directory? directory;

  int navIndex = 1;

  bool isPodcastSelected = false;
  bool onceQueueComplete = false;

  PodcastModel? currentPodcast;
  Map<String, dynamic>? currentEpisode;
  Map<String, dynamic>? nextEpisode;

  late PlayingStatus isPlaying = PlayingStatus.stop;

  late String? currentPodcastTimeRemaining;

  String audioSpeedButtonLabel = '1.0x';

  List<String> audioSpeedOptions = ['0.5x', '1.0x', '1.5x', '2.0x'];

  late bool hasConnection;

  final Ref<OpenAirProvider> ref;

  OpenAirProvider(this.ref);

  List downloadingPodcasts = [];

  Future<void> initial(
    BuildContext context,
  ) async {
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    player = AudioPlayer();

    this.context = context;

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

    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        hasConnection = false;
      } else {
        hasConnection = true;
      }
    } catch (e) {
      debugPrint(e.toString());
      hasConnection = false;
    }
  }

  Future<bool> getConnectionStatus() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  void getConnectionStatusTriggered() {
    getConnectionStatus().then((value) {
      hasConnection = value;
      notifyListeners();
    });
  }

  void setNavIndex(int navIndex) {
    this.navIndex = navIndex;
    notifyListeners();
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

  void audioPlayerSheetCloseButtonClicked() {}

  void rewindButtonClicked() {
    if (playerPosition.inSeconds - 10 > 0) {
      player.seek(Duration(seconds: playerPosition.inSeconds - 10));
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

  Future<void> playerPlayButtonClicked(
    Map<String, dynamic> episodeItem,
  ) async {
    currentEpisode = episodeItem;
    bool isDownloaded = await isAudioFileDownloaded(currentEpisode!['guid']);

    isPodcastSelected = true;
    onceQueueComplete = false;

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
      updatePlaybackBar();
      notifyListeners();
    } on TimeoutException catch (e) {
      debugPrint('Timeout playing audio: $e');
      isPlaying = PlayingStatus.stop;
      audioState = 'Stop';
      loadState = 'Detail';
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Playback timed out. Please check your connection or try again.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      isPlaying = PlayingStatus.stop;
      audioState = 'Stop';
      loadState = 'Detail';
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> queuePlayButtonClicked(
    Map<String, dynamic> queueItem,
    Duration position,
  ) async {
    bool isDownloaded = await isAudioFileDownloaded(queueItem['guid']);

    currentEpisode = queueItem;

    isPodcastSelected = true;
    onceQueueComplete = false;

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
    updatePlaybackBar();
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

  void fastForwardButtonClicked() {
    if (playerPosition.inSeconds + 10 < playerTotalDuration.inSeconds) {
      player.seek(Duration(seconds: playerPosition.inSeconds + 10));
    }
  }

  void audioSpeedButtonClicked() {
    int index = audioSpeedOptions.indexOf(audioSpeedButtonLabel);
    int newIndex = (index + 1) % audioSpeedOptions.length;
    audioSpeedButtonLabel = audioSpeedOptions[newIndex];
    player.setPlaybackRate(double.parse(audioSpeedButtonLabel.substring(0, 3)));
    notifyListeners();
  }

  void timerButtonClicked() {}

  Future<void> updateCurrentQueueCard(
    String guid,
    double podcastCurrentPositionInMilliseconds,
    String currentPlaybackPositionString,
    String currentPlaybackRemainingTimeString,
    Duration position,
  ) async {
    final hiveService = ref.read(hiveServiceProvider);

    // Retrieve the existing QueueModel from Hive
    QueueModel? existingQueueItem = await hiveService.getQueueByGuid(guid);

    if (existingQueueItem != null) {
      // Update the properties of the existing item
      existingQueueItem.podcastCurrentPositionInMilliseconds =
          podcastCurrentPositionInMilliseconds;

      existingQueueItem.currentPlaybackPositionString =
          currentPlaybackPositionString;

      existingQueueItem.currentPlaybackRemainingTimeString =
          currentPlaybackRemainingTimeString;

      existingQueueItem.playerPosition = position;

      // Save the updated item back to Hive.
      // The `addToQueue` method is used here because it handles both
      // insertion and updating (if the key already exists).
      await hiveService.addToQueue(existingQueueItem, notify: true);
      // notify: false is important here to prevent an infinite loop
      // if this method is called from within a listener that triggers
      // a UI rebuild which then re-reads the queue.
    }
  }

  void updatePlaybackBar() async {
    player.getDuration().then((Duration? value) {
      if (value != null) {
        playerTotalDuration = value;
        notifyListeners();
      } else {
        player.setSourceUrl(currentEpisode!['enclosureUrl']);
        updatePlaybackBar();
      }
    });

    player.onPositionChanged.listen((Duration p) {
      playerPosition = p;

      currentPlaybackPositionString =
          formatCurrentPlaybackPosition(playerPosition);

      currentPlaybackRemainingTimeString = formatCurrentPlaybackRemainingTime(
          playerPosition, playerTotalDuration);

      podcastCurrentPositionInMilliseconds =
          (playerPosition.inMilliseconds / playerTotalDuration.inMilliseconds)
              .clamp(0.0, 1.0);

      notifyListeners();
    });

    player.onPlayerStateChanged.listen((PlayerState playerState) async {
      if (playerState == PlayerState.completed) {
        if (!onceQueueComplete) {
          onceQueueComplete = true;

          isPodcastSelected = false;
          audioState = 'Stop';
          isPlaying = PlayingStatus.stop;

          ref.watch(hiveServiceProvider).addToCompletedEpisode(
                CompletedEpisodeModel(guid: currentEpisode!['guid']),
              );

          await updateCurrentQueueCard(
            currentEpisode!['guid'],
            podcastCurrentPositionInMilliseconds,
            currentPlaybackPositionString,
            currentPlaybackRemainingTimeString,
            playerPosition,
          );

          playNextInQueue();
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

  Future<void> playNewQueueItem(QueueModel newItem) async {
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

    // 2. Play the new item from its saved position.
    await queuePlayButtonClicked(
      newItem.toJson(),
      newItem.playerPosition!,
    );
  }

  void playNextInQueue() async {
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

      // 1. Remove the completed episode from the queue
      await ref
          .read(hiveServiceProvider)
          .removeFromQueue(guid: completedEpisodeGuid);

      // 2. Add to completed episodes
      // Assuming CompletedEpisode model has a constructor like: CompletedEpisode({required this.guid})
      await ref.read(hiveServiceProvider).addToCompletedEpisode(
          CompletedEpisodeModel(guid: completedEpisodeGuid));

      // 3. Get the updated queue to determine the next episode.
      // The sortedQueueListProvider will also update reactively for the UI.
      final updatedQueue = await ref.read(hiveServiceProvider).getSortedQueue();

      if (updatedQueue.isNotEmpty) {
        // 4. If the queue is not empty, play the next episode.
        final nextEpisodeToPlay = updatedQueue.first;

        currentEpisode = nextEpisodeToPlay.toJson();
        currentPodcast = nextEpisodeToPlay.podcast;

        playNewQueueItem(nextEpisodeToPlay);
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

  String getPodcastDuration(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    int hours = dateTime.hour;
    int minutes = dateTime.minute;
    // int seconds = dateTime.second;

    String result =
        "${hours != 0 ? hours < 10 ? '0$hours hr ' : '$hours hr ' : '00 hrs '}${minutes != 0 ? minutes < 10 ? '0$minutes min ' : '$minutes min ' : '00 min '}";

    // ${seconds != 0 ? seconds < 10 ? '0$seconds secs' : '$seconds' : '00 secs'}

    return result;
  }

  String formatCurrentPlaybackRemainingTime(
    Duration timelinePosition,
    Duration timelineDuration,
  ) {
    int remainingSeconds =
        timelineDuration.inSeconds - timelinePosition.inSeconds;

    remainingSeconds = remainingSeconds > 0 ? remainingSeconds : 0;

    int remainingHours = Duration(seconds: remainingSeconds).inHours;
    int remainingMinutes = Duration(seconds: remainingSeconds).inMinutes % 60;
    int remainingSecondsAdjusted =
        Duration(seconds: remainingSeconds).inSeconds % 60;

    currentPodcastTimeRemaining =
        "${remainingHours != 0 ? '$remainingHours hr ' : ''}${remainingMinutes != 0 ? '$remainingMinutes min' : '< 1 min'} left";

    String result =
        "${remainingHours != 0 ? remainingHours < 10 ? '0$remainingHours:' : '$remainingHours:' : '00:'}${remainingMinutes != 0 ? remainingMinutes < 10 ? '0$remainingMinutes:' : '$remainingMinutes:' : '00:'}${remainingSecondsAdjusted != 0 ? remainingSecondsAdjusted < 10 ? '0$remainingSecondsAdjusted' : '$remainingSecondsAdjusted' : '00'}";

    return result;
  }

  Future<void> removeAllDownloadedPodcasts() async {
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This action is not available on the web.'),
          ),
        );
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

      ref.watch(hiveServiceProvider).clearDownloads();
      ref.invalidate(getDownloadsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed all downloaded podcasts'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing all downloaded podcasts: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove downloaded podcasts.'),
          ),
        );
      }
    }

    notifyListeners();
  }

  Future<void> downloadEpisode(
    Map<String, dynamic> item,
    PodcastModel podcast,
  ) async {
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading is not available on the web.'),
          ),
        );
      }
      return;
    }

    final dio = Dio();

    final guid = item['guid'] as String;
    final url = item['enclosureUrl'] as String;

    final size = getEpisodeSize(item['enclosureLength']);
    Duration episodeTotalDuration = getEpisodeDuration(item['enclosureLength']);

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
        image: item['image'],
        title: item['title'],
        author: item['author'] ?? 'Unknown',
        datePublished: item['datePublished'],
        description: item['description'],
        feedUrl: item['feedUrl'],
        duration: episodeTotalDuration,
        size: size,
        podcastId: podcast.id.toString(),
        enclosureLength: item['enclosureLength'],
        enclosureUrl: item['enclosureUrl'],
        downloadDate: DateTime.now(),
        fileName: filename,
      );

      await ref.read(hiveServiceProvider).addToDownloads(downloadModel);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded \'${item['title']}\''),
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error downloading ${item['title']}: $e');

      String filename = '${item['guid']}.mp3';
      final filePath = await getDownloadsDir();
      final file = File('$filePath/$filename');
      if (await file.exists()) {
        await file.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download ${item['title']}.'),
          ),
        );
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

      await ref.read(hiveServiceProvider).deleteDownload(guid);

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing download for ${item['title']}: $e');
    }
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

  void mainPlayerRewindClicked() {}

  void mainPlayerFastForwardClicked() {}

  void mainPlayerPaybackSpeedClicked() {}

  void mainPlayerTimerClicked() {}

  void mainPlayerCastClicked() {}

  void mainPlayerMoreOptionsClicked() {}

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

  // Database Operations:
  Future<bool> isSubscribed(String podcastTitle) async {
    SubscriptionModel? resultSet =
        await ref.read(hiveServiceProvider).getSubscription(podcastTitle);

    if (resultSet != null) {
      return true;
    }

    return false;
  }

  Future<Map<String, SubscriptionModel>> getSubscriptions() async {
    return await ref.read(hiveServiceProvider).getSubscriptions();
  }

  Future<String> getSubscriptionsCount(int podcastId) async {
    // Gets episodes count from last stored index of episodes
    int currentSubEpCount = await ref
        .read(hiveServiceProvider)
        .podcastSubscribedEpisodeCount(podcastId);

    // Gets episodes count from PodcastIndex
    try {
      int podcastEpisodeCount = await ref
          .read(podcastIndexProvider)
          .getPodcastEpisodeCountByPodcastId(podcastId);

      int result = podcastEpisodeCount - currentSubEpCount;

      return result.toString();
    } on DioException catch (e) {
      debugPrint(
          'DioError getting episode count for podcast $podcastId: ${e.message}');

      if (e.response != null) {
        debugPrint('Response: ${e.response?.data}');
      }
      return '...'; // Or some other indicator of an error
    } catch (e) {
      debugPrint('Error getting episode count for podcast $podcastId: $e');
      return '...';
    }
  }

  Future<String> getAccumulatedSubscriptionCount() async {
    // TODO Reimplement this function
    // return await ref
    //     .read(hiveServiceProvider)
    //     .podcastAccumulatedSubscribedEpisodes();

    return 'REWORK';
  }

  Future<String> getFeedsCount() async {
    return await ref.read(hiveServiceProvider).feedsCount();
  }

  Future<String> getQueueCount() async {
    return await ref.read(hiveServiceProvider).queueCount();
  }

  Future<String> getDownloadsCount() async {
    return await ref.read(hiveServiceProvider).downloadsCount();
  }

  Duration getEpisodeDuration(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    int hours = dateTime.hour;
    int minutes = dateTime.minute;
    int seconds = dateTime.second;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  void addToQueue(
    Map<String, dynamic> episode,
    PodcastModel? podcast,
  ) async {
    int pos;

    List<QueueModel> queue =
        await ref.read(hiveServiceProvider).getSortedQueue();

    if (queue.isEmpty) {
      pos = 1;
    } else {
      int lastPos = queue.last.pos;

      pos = lastPos + 1;
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

    // When adding to queue, currentPlaybackRemainingTimeString in QueueModel will store the formatted total duration.
    final String formattedTotalDurationString =
        formatCurrentPlaybackRemainingTime(Duration.zero, episodeTotalDuration);

    QueueModel queueMod = QueueModel(
      guid: episode['guid'],
      title: episode['title'],
      author: episode['author'] ?? 'Unknown',
      image: episode['feedImage'] ?? episode['image'],
      datePublished: episode['datePublished'],
      description: episode['description'],
      feedUrl: episode['feedUrl'],
      duration: episodeTotalDuration,
      downloadSize: downloadSize,
      enclosureType: episode['enclosureType'] ??
          'audio/mpeg', // Store enclosureType, provide a default if null
      enclosureLength: episode['enclosureLength'],
      enclosureUrl: episode['enclosureUrl'],
      podcast: podcast!,
      pos: pos,
      podcastCurrentPositionInMilliseconds: initialPositionMilliseconds,
      currentPlaybackPositionString: initialPositionString,
      currentPlaybackRemainingTimeString: formattedTotalDurationString,
      playerPosition: Duration.zero,
    );

    ref.read(hiveServiceProvider).addToQueue(queueMod);
  }

  void addToHistory(
    Map<String, dynamic> episode,
    PodcastModel? podcast,
  ) async {
    final int enclosureLength = episode['enclosureLength'];
    final String downloadSize = getEpisodeSize(enclosureLength);

    final Duration episodeTotalDuration =
        getEpisodeDuration(episode['enclosureLength']);

    String historyPodcastId;
    String historyPodcastImage;
    String historyPodcastAuthor;

    // Determine the correct podcast ID, image, and author based on the 'podcast' map structure
    if (podcast != null) {
      historyPodcastId = podcast.id.toString();
      historyPodcastImage = podcast.imageUrl;
      historyPodcastAuthor =
          podcast.author.isNotEmpty ? podcast.author : 'Unknown';
    } else {
      debugPrint(
          'Warning: Podcast map is null in addToHistory. Using episode author/image.');
      historyPodcastId = episode['podcastId']?.toString() ?? 'unknown';
      historyPodcastImage = episode['image'] ?? '';
      historyPodcastAuthor = episode['author'] ?? 'Unknown';
    }

    HistoryModel historyMod = HistoryModel(
      guid: episode['guid'],
      image: historyPodcastImage,
      title: episode['title'],
      author: historyPodcastAuthor,
      datePublished: episode['datePublished'],
      description: episode['description'],
      feedUrl: episode['feedUrl'],
      duration: episodeTotalDuration.inSeconds.toString(),
      size: downloadSize,
      podcastId: historyPodcastId,
      enclosureLength: episode['enclosureLength'],
      enclosureUrl: episode['enclosureUrl'],
      playDate: DateTime.now(),
    );

    ref.read(hiveServiceProvider).addToHistory(historyMod);
  }

  Future<Queue<QueueModel>> getQueue() async {
    Queue<QueueModel> queue = Queue();
    List<QueueModel> queueList =
        await ref.read(hiveServiceProvider).getSortedQueue();
    queue.addAll(queueList);
    return queue;
  }

  Future<QueueModel?> getQueueByGuid(String guid) async {
    return await ref.read(hiveServiceProvider).getQueueByGuid(guid);
  }

  void removeFromQueue(String guid) async {
    ref.read(hiveServiceProvider).removeFromQueue(guid: guid);
    // queueProvider will update reactively as it watches hiveServiceProvider,
    // which is notified by the removeFromQueue call above.
    notifyListeners();
  }

  void subscribe(
    PodcastModel podcast,
  ) async {
    try {
      int podcastEpisodeCount = await ref
          .read(podcastIndexProvider)
          .getPodcastEpisodeCountByPodcastId(podcast.id);

      debugPrint('podcast episode count: $podcastEpisodeCount');
      debugPrint('podcast id: ${podcast.id}');

      SubscriptionModel subscription = SubscriptionModel(
        id: podcast.id,
        title: podcast.title,
        author: podcast.author.isNotEmpty ? podcast.author : 'Unknown',
        feedUrl: podcast.feedUrl,
        imageUrl: podcast.imageUrl,
        episodeCount: podcastEpisodeCount,
        description: podcast.description,
        artwork: podcast.artwork,
      );

      ref.read(hiveServiceProvider).subscribe(subscription);
      await addPodcastEpisodes(subscription);

      // subscriptionsProvider (from hive_provider.dart) will update reactively
      // as it watches hiveServiceProvider, which is notified by the subscribe call.
      ref.invalidate(getFeedsProvider);
      notifyListeners();
    } on DioException catch (e) {
      debugPrint(
          'OP:Failed to subscribe to ${podcast.title}. DioError: ${e.message}\nStack trace: ${e.stackTrace}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to subscribe: ${e.message}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to subscribe to ${podcast.title}: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred while subscribing.'),
          ),
        );
      }
    }
  }

  void subscribeByRssFeed(
    SubscriptionModel podcast,
  ) async {
    try {
      int podcastEpisodeCount = await ref
          .read(podcastIndexProvider)
          .getPodcastEpisodeCountByTitle(podcast.title);

      SubscriptionModel subscription = SubscriptionModel(
        id: podcast.id,
        title: podcast.title,
        author: podcast.author.isNotEmpty ? podcast.author : 'Unknown',
        feedUrl: podcast.feedUrl,
        imageUrl: podcast.imageUrl,
        episodeCount: podcastEpisodeCount,
        description: podcast.description,
        artwork: '',
      );

      ref.read(hiveServiceProvider).subscribe(subscription);
      await addPodcastEpisodes(podcast);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Subscribed to ${podcast.title}',
            ),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint(
          'Failed to subscribe to ${podcast.title}. DioError: ${e.message}. Stack trace: ${e.stackTrace}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to subscribe: \'${podcast.title}\'. Try again later.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to subscribe to ${podcast.title}: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred while subscribing.'),
          ),
        );
      }
    }
  }

  void unsubscribe(PodcastModel podcast) async {
    ref.read(hiveServiceProvider).unsubscribe(podcast.title);
    removePodcastEpisodes(podcast);

    // subscriptionsProvider (from hive_provider.dart) will update reactively
    // as it watches hiveServiceProvider, which is notified by the unsubscribe call.
    ref.invalidate(getFeedsProvider);
    notifyListeners();
  }

  Future<void> addPodcastEpisodes(SubscriptionModel podcast) async {
    final apiService = ref.read(podcastIndexProvider);

    Map<String, dynamic> episodes =
        await apiService.getEpisodesByFeedUrl(podcast.feedUrl);

    EpisodeModel episode;

    for (int i = 0; i < episodes['count']; i++) {
      int enclosureLength = episodes['items'][i]['enclosureLength'];
      String duration = getPodcastDuration(enclosureLength);
      String size = getEpisodeSize(enclosureLength);

      episode = EpisodeModel(
        podcastId: podcast.id.toString(),
        guid: episodes['items'][i]['guid'],
        title: episodes['items'][i]['title'],
        author: podcast.author.isNotEmpty ? podcast.author : 'Unknown',
        image: episodes['items'][i]['feedImage'],
        datePublished: episodes['items'][i]['datePublished'],
        description: episodes['items'][i]['description'],
        feedUrl: episodes['items'][i]['feedUrl'],
        duration: duration,
        size: size,
        enclosureLength: enclosureLength,
        enclosureUrl: episodes['items'][i]['enclosureUrl'],
      );

      ref.read(hiveServiceProvider).insertEpisode(
            episode,
            episode.guid,
          );
    }

    notifyListeners();
  }

  void removePodcastEpisodes(PodcastModel podcast) async {
    ref.read(hiveServiceProvider).deleteEpisodes(podcast.title);
    notifyListeners();
  }

  Future<bool> isEpisodeNew(String guid) async {
    EpisodeModel? resultSet =
        await ref.read(hiveServiceProvider).getEpisode(guid);

    if (resultSet != null) {
      return false;
    }

    return true;
  }

  Future<List<EpisodeModel>> getSubscribedEpisodes() async {
    return ref.read(hiveServiceProvider).getEpisodes();
  }

  Future<List<DownloadModel>> getSortedDownloadedEpisodes() async {
    return ref.read(hiveServiceProvider).getSortedDownloads();
  }

  Future<List<HistoryModel>> getSortedHistory() async {
    return ref.read(hiveServiceProvider).getSortedHistory();
  }

  void share() {
    debugPrint('share button clicked');
  }

  void addPodcastByRssUrl(String rssUrl) async {
    String xmlString;
    try {
      xmlString = await ref.watch(fyydProvider).getPodcastXml(rssUrl, context);

      RssFeed rssFeed = RssFeed.parse(xmlString);

      // TODO Remove these
      // debugPrint(rssFeed.title);

      // debugPrint(rssFeed.link);
      // debugPrint(rssFeed.items!.first.link);
      // debugPrint(rssFeed.itunes!.newFeedUrl);
      // debugPrint(snapshot[index]['xmlURL']);

      SubscriptionModel podcast = SubscriptionModel(
        id: 0, // ID will be assigned by Hive
        title: rssFeed.title ?? 'Unknown Title',
        author:
            rssFeed.itunes?.author ?? rssFeed.dc?.creator ?? 'Unknown Author',
        feedUrl: rssUrl,
        imageUrl: rssFeed.itunes?.image?.href ?? rssFeed.image?.url ?? '',
        episodeCount: 0,
        description: rssFeed.description ?? '',
        artwork: rssFeed.image!.url!,
      );

      subscribeByRssFeed(podcast);
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: 2,
                vertical: MediaQuery.of(context).size.height * 0.3,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 62.0,
                vertical: 15.0,
              ),
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 100.0,
                vertical: 15.0,
              ),
              title: const Text(
                'Error',
                textAlign: TextAlign.center,
              ),
              content: const Text(
                'Cannot fetch podcast from RSS URL. Check if the URL is valid and try again.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
