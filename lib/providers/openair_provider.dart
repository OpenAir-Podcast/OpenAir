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
import 'package:openair/models/episode_model.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/views/mobile/nav_pages/feeds_page.dart'; // Import for getFeedsProvider
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final openAirProvider = ChangeNotifierProvider<OpenAirProvider>(
  (ref) {
    return OpenAirProvider(ref);
  },
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

  Map<String, dynamic>? currentPodcast;
  Map<String, dynamic>? currentEpisode;
  Map<String, dynamic>? nextEpisode;

  late PlayingStatus isPlaying = PlayingStatus.stop;

  List<String> downloadingPodcasts = [];

  late String? currentPodcastTimeRemaining;

  String audioSpeedButtonLabel = '1.0x';

  List<String> audioSpeedOptions = ['0.5x', '1.0x', '1.5x', '2.0x'];

  late bool hasConnection;

  final Ref<OpenAirProvider> ref;

  OpenAirProvider(this.ref);

  Future<void> initial(
    BuildContext context,
  ) async {
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    // Initialise db
    await ref.read(hiveServiceProvider).init();

    player = AudioPlayer();

    this.context = context;

    podcastSubtitle = 'podcastImage';
    podcastTitle = 'episodeName';
    podcastSubtitle = 'name';

    playerPosition = Duration.zero;
    playerTotalDuration = Duration.zero;

    podcastCurrentPositionInMilliseconds = 0;
    currentPlaybackPositionString = '00:00:00';
    currentPlaybackRemainingTimeString = '00:00:00';

    currentPodcast = {};
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

  Future<List<String>> setPodcastStream(
    Map<String, dynamic> currentEpisode,
  ) async {
    loadState = 'Load';
    isPlaying = PlayingStatus.buffering;
    notifyListeners();

    String mp3Name =
        formattedDownloadedPodcastName(currentEpisode['enclosureUrl']);

    bool isDownloaded = await isMp3FileDownloaded(mp3Name);

    List<String> result = [mp3Name, isDownloaded.toString()];

    return result;
  }

  void rewindButtonClicked() {
    if (playerPosition.inSeconds - 10 > 0) {
      player.seek(Duration(seconds: playerPosition.inSeconds - 10));
    }
  }

  Future<void> playerPlayButtonClicked(
    Map<String, dynamic> episodeItem,
  ) async {
    debugPrint('playerPlayButtonClicked called for: ${episodeItem['title']}');
    currentEpisode = episodeItem;
    List<String> result = await setPodcastStream(currentEpisode!);

    isPodcastSelected = true;
    onceQueueComplete = false;

    try {
      // Checks if the episode has already been downloaded
      if (result[1] == 'true') {
        final filePath = await getDownloadsPath(result[0]);
        debugPrint('Attempting to play DeviceFileSource: $filePath');
        await player
            .play(DeviceFileSource(filePath))
            .timeout(const Duration(seconds: 30));
      } else {
        debugPrint(
            'Attempting to play UrlSource: ${currentEpisode!['enclosureUrl']}');
        await player
            .play(UrlSource(currentEpisode!['enclosureUrl']))
            .timeout(const Duration(seconds: 30));
      }

      if (episodeItem['guid'] == currentEpisode!['guid']) {
        isPlaying = PlayingStatus.playing;
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Playback timed out. Please check your connection or try again.'),
        ),
      );
    } catch (e) {
      debugPrint('Error playing audio: $e');
      isPlaying = PlayingStatus.stop;
      audioState = 'Stop';
      loadState = 'Detail';
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to play audio: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> queuePlayButtonClicked(
    Map<String, dynamic> queueItem,
    Duration position,
  ) async {
    debugPrint(
        'queuePlayButtonClicked called for: ${queueItem['title']} at position: $position');

    currentEpisode = queueItem;
    List<String> result = await setPodcastStream(currentEpisode!);

    isPodcastSelected = true;
    onceQueueComplete = false;

    debugPrint('Position: ${position.toString()}');
    debugPrint('Player Position: ${playerPosition.toString()}');

    playerPosition = position;

    // Checks if the episode has already been downloaded
    if (result[1] == 'true') {
      final filePath = await getDownloadsPath(result[0]);

      debugPrint('Attempting to play DeviceFileSource from queue: $filePath');

      await player.play(
        DeviceFileSource(filePath),
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
      // loadState can remain 'Detail' or be set to 'Play' based on desired UI behavior
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
    debugPrint('Updating current queue card: $guid');
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
    } else {
      debugPrint('Queue item with GUID $guid not found for update.');
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
          formatCurrentPlaybackPosition(this.playerPosition);

      currentPlaybackRemainingTimeString = formatCurrentPlaybackRemainingTime(
          this.playerPosition, playerTotalDuration);

      podcastCurrentPositionInMilliseconds =
          (playerPosition.inMilliseconds / playerTotalDuration.inMilliseconds)
              .clamp(0.0, 1.0);

      notifyListeners();
    });

    player.onPlayerStateChanged.listen((PlayerState playerState) async {
      // TODO: Add marking podcast as completed automatically here
      // TODO: Autoplay next podcast here

      if (playerState == PlayerState.completed) {
        if (!onceQueueComplete) {
          debugPrint('Completed');
          onceQueueComplete = true;

          isPodcastSelected = false;
          audioState = 'Stop';
          isPlaying = PlayingStatus.stop;

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
          debugPrint('Paused');

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
      debugPrint(
          'Switching track. Saving progress for previous episode: ${currentEpisode!['guid']}');

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
      await ref
          .read(hiveServiceProvider)
          .addToCompletedEpisode(CompletedEpisode(guid: completedEpisodeGuid));

      // 3. Get the updated queue to determine the next episode.
      // The sortedQueueListProvider will also update reactively for the UI.
      final updatedQueue = await ref.read(hiveServiceProvider).getSortedQueue();

      if (updatedQueue.isNotEmpty) {
        // 4. If the queue is not empty, play the next episode.
        final nextEpisodeToPlay = updatedQueue.first;

        currentEpisode = nextEpisodeToPlay.toJson();
        currentPodcast = nextEpisodeToPlay.podcast;

        // TODO Here
        // playerPlayButtonClicked(nextEpisodeToPlay.toJson());
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

  // TODO: Add playlist here

  Future<DownloadStatus> getDownloadStatus(String filename) async {
    if (await isMp3FileDownloaded(filename)) {
      return DownloadStatus.downloaded;
    }

    return DownloadStatus.notDownloaded;
  }

  Future<bool> isMp3FileDownloaded(String filename) async {
    final filePath = '${directory!.path}/downloads/$filename';
    final file = File(filePath);
    return file.exists();
  }

  Future<String> getDownloadsPath(String filename) async {
    const storagePath = 'downloads'; // Assuming a downloads subdirectory

    // Create the downloads directory if it doesn't exist
    await Directory(path.join(directory!.path, storagePath))
        .create(recursive: true);

    final absolutePath = path.joinAll([directory!.path, storagePath, filename]);

    return absolutePath;
  }

  String formattedDownloadedPodcastName(String audioUrl) {
    String filename = path.basename(audioUrl); // Extract filename from URL

    int indexOfQuestionMark = filename.indexOf('?');

    if (indexOfQuestionMark != -1) {
      filename = filename.substring(0, indexOfQuestionMark);
    }

    return filename;
  }

  // TODO: Add playlist here

  Future<void> removeAllDownloadedPodcasts() async {
    Directory downloadsDirectory =
        Directory('/data/user/0/com.liquidhive.openair/app_flutter/downloads');
    List<FileSystemEntity> files = downloadsDirectory.listSync();

    for (FileSystemEntity file in files) {
      file.deleteSync();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed all downloaded podcasts'),
      ),
    );

    notifyListeners();
  }

  // TODO: Needs to be multithreaded
  void playerDownloadButtonClicked(Map<String, dynamic> item) async {
    // item.setDownloaded = DownloadStatus.downloading;
    // downloadingPodcasts.add(item.rssItem!.guid!);
    //
    // notifyListeners();
    //
    // final response = await http.get(Uri.parse(item.rssItem!.enclosure!.url!));
    //
    // if (response.statusCode == 200) {
    //   String filename =
    //       formattedDownloadedPodcastName(item.rssItem!.enclosure!.url!);
    //
    //   final file = File(await getDownloadsPath(filename));
    //
    //   await file.writeAsBytes(response.bodyBytes).whenComplete(
    //     () {
    //       item.setDownloaded = DownloadStatus.downloaded;
    //       downloadingPodcasts.remove(item..rssItem!.guid);
    //       notifyListeners();
    //     },
    //   );
    // } else {
    //   throw Exception(
    //       'Failed to download podcast (Status Code: ${response.statusCode})');
    // }
  }

  void playerRemoveDownloadButtonClicked(Map<String, dynamic> item) async {
    // Directory downloadsDirectory =
    //     Directory('/data/user/0/com.liquidhive.openair/app_flutter/downloads');
    // List<FileSystemEntity> files = downloadsDirectory.listSync();
    //
    // String filename =
    //     formattedDownloadedPodcastName(item.rssItem!.enclosure!.url!);
    //
    // for (FileSystemEntity file in files) {
    //   if (path.basename(file.path) == filename) {
    //     file.deleteSync();
    //     break;
    //   }
    // }
    //
    // item.downloaded = DownloadStatus.notDownloaded;
    //
    // Navigator.pop(context);
    // notifyListeners();
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
  Future<bool> isSubscribed(int podcastId) async {
    Subscription? resultSet = await ref
        .read(hiveServiceProvider)
        .getSubscription(podcastId.toString());

    if (resultSet != null) {
      return true;
    }

    return false;
  }

  Future<Map<String, Subscription>> getSubscriptions() async {
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
    return await ref
        .read(hiveServiceProvider)
        .podcastAccumulatedSubscribedEpisodes();
  }

  Future<String> getFeedsCount() async {
    return await ref.read(hiveServiceProvider).feedsCount();
  }

  Future<String> getQueueCount() async {
    return await ref.read(hiveServiceProvider).queueCount();
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
    Map<String, dynamic>? podcast,
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
    Map<String, dynamic> podcast,
  ) async {
    try {
      int podcastEpisodeCount = await ref
          .read(podcastIndexProvider)
          .getPodcastEpisodeCountByPodcastId(podcast['id']);

      Subscription subscription = Subscription(
        id: podcast['id'],
        title: podcast['title'],
        author: podcast['author'] ?? 'Unknown',
        feedUrl: podcast['url'],
        imageUrl: podcast['image'],
        episodeCount: podcastEpisodeCount,
      );

      ref.read(hiveServiceProvider).subscribe(subscription);

      await addPodcastEpisodes(podcast);

      // subscriptionsProvider (from hive_provider.dart) will update reactively
      // as it watches hiveServiceProvider, which is notified by the subscribe call.
      ref.invalidate(getFeedsProvider);
      notifyListeners();
    } on DioException catch (e) {
      debugPrint('Failed to subscribe to ${podcast['title']}: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to subscribe: ${e.message}'),
        ),
      );
    } catch (e) {
      debugPrint('Failed to subscribe to ${podcast['title']}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred while subscribing.'),
        ),
      );
    }
  }

  void unsubscribe(Map<String, dynamic> podcast) async {
    ref.read(hiveServiceProvider).unsubscribe(podcast['id'].toString());
    removePodcastEpisodes(podcast);

    // subscriptionsProvider (from hive_provider.dart) will update reactively
    // as it watches hiveServiceProvider, which is notified by the unsubscribe call.
    ref.invalidate(getFeedsProvider);
    notifyListeners();
  }

  Future<void> addPodcastEpisodes(Map<String, dynamic> podcast) async {
    final apiService = ref.read(podcastIndexProvider);
    try {
      Map<String, dynamic> episodes =
          await apiService.getEpisodesByFeedUrl(podcast['url']);

      Episode episode;

      for (int i = 0; i < episodes['count']; i++) {
        int enclosureLength = episodes['items'][i]['enclosureLength'];
        String duration = getPodcastDuration(enclosureLength);
        String size = getEpisodeSize(enclosureLength);

        episode = Episode(
          podcastId: podcast['id'].toString(),
          guid: episodes['items'][i]['guid'],
          title: episodes['items'][i]['title'],
          author: podcast['author'] ?? 'Unknown',
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

        notifyListeners();
      }
    } on DioException catch (e) {
      debugPrint(
          'Failed to fetch episodes for ${podcast['title']}: ${e.message}');
      // This error will be caught by the 'subscribe' method's catch block
      // if called from there, which will show a SnackBar.
      // To avoid duplicate error messages, we can rethrow.
      rethrow;
    } catch (e) {
      debugPrint('Failed to fetch episodes for ${podcast['title']}: $e');
      // Rethrow to be handled by the caller.
      rethrow;
    }
  }

  void removePodcastEpisodes(Map<String, dynamic> podcast) async {
    ref.read(hiveServiceProvider).deleteEpisodes(podcast['id'].toString());
    notifyListeners();
  }

  Future<bool> isEpisodeNew(String guid) async {
    Episode? resultSet = await ref.read(hiveServiceProvider).getEpisode(guid);

    if (resultSet != null) {
      return false;
    }

    return true;
  }

  Future<List<Episode>> getSubscribedEpisodes() async {
    return ref.read(hiveServiceProvider).getEpisodes();
  }
}
