import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/models/subscription.dart';
import 'package:openair/providers/hive_provider.dart';
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

  late Duration podcastPosition;
  late Duration podcastDuration;

  late double podcastCurrentPositionInMilliseconds;
  late String currentPlaybackPositionString;
  late String currentPlaybackRemainingTimeString;

  final String storagePath = 'openair/downloads';

  late Directory directory;

  int navIndex = 1;

  bool isPodcastSelected = false;

  late Map<String, dynamic>? currentPodcast;
  late Map<String, dynamic>? currentEpisode;
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
    // Initialise db
    ref.read(hiveServiceProvider).init();

    player = AudioPlayer();

    this.context = context;

    podcastSubtitle = 'podcastImage';
    podcastTitle = 'episodeName';
    podcastSubtitle = 'name';

    podcastPosition = Duration.zero;
    podcastDuration = Duration.zero;

    podcastCurrentPositionInMilliseconds = 0;
    currentPlaybackPositionString = '00:00:00';
    currentPlaybackRemainingTimeString = '00:00:00';

    currentEpisode = {};

    audioState = 'Pause';
    loadState = 'Detail'; // Play, Load, Detail

    directory = await getApplicationDocumentsDirectory();

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

    // TODO: Add support for multiple podcast
    String mp3Name =
        formattedDownloadedPodcastName(currentEpisode['enclosureUrl']);

    bool isDownloaded = await isMp3FileDownloaded(mp3Name);

    List<String> result = [mp3Name, isDownloaded.toString()];

    // TODO:Add support for downloading podcasts
    // isDownloaded
    //     ? {
    //         await player.setSource(DeviceFileSource(
    //           currentEpisode['enclosureUrl'],
    //           mimeType: currentEpisode['enclosureType'],
    //         ))
    //       }
    //     : await player.setSource(
    //         UrlSource(
    //           currentEpisode['enclosureUrl'],
    //           mimeType: currentEpisode['enclosureType'],
    //         ),
    //       );

    // TODO: Remove this when I implement the isDownload functionality
    player.setSource(
      UrlSource(
        currentEpisode['enclosureUrl'],
        mimeType: currentEpisode['enclosureType'],
      ),
    );

    return result;
  }

  void rewindButtonClicked() {
    if (podcastPosition.inSeconds - 10 > 0) {
      player.seek(Duration(seconds: podcastPosition.inSeconds - 10));
    }
  }

  void playerPlayButtonClicked(
    Map<String, dynamic> episodeItem,
  ) async {
    currentEpisode = episodeItem;
    List<String> result = await setPodcastStream(currentEpisode!);

    isPodcastSelected = true;

    // Checks if the episode has already been downloaded
    if (result[1] == 'true') {
      player.play(DeviceFileSource(
          '/data/user/0/com.liquidhive.openair/app_flutter/downloads/${result[0]}'));
    } else {
      await player.play(UrlSource(currentEpisode!['enclosureUrl']));
    }

    if (episodeItem == currentEpisode) {
      isPlaying = PlayingStatus.playing;
    }

    // TODO: Add the episode to the Episode and History Tables

    audioState = 'Play';
    loadState = 'Play';
    nextEpisode = currentEpisode;
    updatePlaybackBar();
    notifyListeners();
  }

  Future<void> playerPauseButtonClicked() async {
    audioState = 'Pause';
    loadState = 'Detail';

    if (player.state == PlayerState.playing) {
      await player.pause();
    }

    isPlaying = PlayingStatus.paused;

    notifyListeners();
  }

  void fastForwardButtonClicked() {
    if (podcastPosition.inSeconds + 10 < podcastDuration.inSeconds) {
      player.seek(Duration(seconds: podcastPosition.inSeconds + 10));
    }
  }

  void audioSpeedButtonClicked() {
    int index = audioSpeedOptions.indexOf(audioSpeedButtonLabel);
    int newIndex = (index + 1) % audioSpeedOptions.length;
    audioSpeedButtonLabel = audioSpeedOptions[newIndex];
    player.setPlaybackRate(double.parse(audioSpeedButtonLabel.substring(0, 3)));
    notifyListeners();
  }

  void updatePlaybackBar() {
    player.getDuration().then((Duration? value) {
      if (value == null) {
        return;
      }

      podcastDuration = value;
      notifyListeners();
    });

    player.onPositionChanged.listen((Duration p) {
      podcastPosition = p;

      currentPlaybackPositionString =
          formatCurrentPlaybackPosition(podcastPosition);

      currentPlaybackRemainingTimeString =
          formatCurrentPlaybackRemainingTime(podcastPosition, podcastDuration);

      podcastCurrentPositionInMilliseconds =
          (podcastPosition.inMilliseconds / podcastDuration.inMilliseconds)
              .clamp(0.0, 1.0);

      notifyListeners();
    });

    player.onPlayerStateChanged.listen((PlayerState playerState) {
      // TODO: Add marking podcast as completed automatically here
      // TODO: Autoplay next podcast here
      if (playerState == PlayerState.completed) {
        isPodcastSelected = false;
        audioState = 'Stop';
        isPlaying = PlayingStatus.stop;
      }
    });

    notifyListeners();
  }

  String formatCurrentPlaybackPosition(Duration timeline) {
    int hours = timeline.inHours;
    int minutes = timeline.inMinutes;

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
    final filePath = '${directory.path}/downloads/$filename';
    final file = File(filePath);
    return file.exists();
  }

  Future<String> getDownloadsPath(String filename) async {
    const storagePath = 'downloads'; // Assuming a downloads subdirectory

    // Create the downloads directory if it doesn't exist
    await Directory(path.join(directory.path, storagePath))
        .create(recursive: true);

    final absolutePath = path.joinAll([directory.path, storagePath, filename]);

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

    // FIXME: Fix this
    // for (RssItemModel item in data) {
    //   if (item.downloaded == DownloadStatus.downloaded) {
    //     item.setDownloaded = DownloadStatus.notDownloaded;
    //   }
    // }

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
        milliseconds: (sliderValue * podcastDuration.inMilliseconds).toInt());

    podcastCurrentPositionInMilliseconds =
        ((sliderValue * podcastDuration.inMilliseconds) /
                podcastDuration.inMilliseconds)
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

  String getSubscriptionsCount() {
    // return ref.read(hiveServiceProvider).getSubscriptionsCount();
    return '0';
  }

  void subscribe(
    Map<String, dynamic> podcast,
  ) async {
    Subscription subscription = Subscription(
      id: podcast['id'],
      title: podcast['title'],
      author: podcast['author'] ?? 'Unknown',
      feedUrl: podcast['url'],
      imageUrl: podcast['image'],
    );

    ref.read(hiveServiceProvider).subscribe(subscription);
    ref.invalidate(subscriptionsProvider);
    notifyListeners();
  }

  void unsubscribe(Map<String, dynamic> podcast) async {
    ref.read(hiveServiceProvider).unsubscribe(podcast['id'].toString());
    ref.invalidate(subscriptionsProvider);
    notifyListeners();
  }
}
