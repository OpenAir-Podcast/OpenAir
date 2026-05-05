import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/history_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/services/audio_handler.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/nav_pages/downloads_page.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';
import 'package:openair/views/nav_pages/history_page.dart';
import 'package:openair/views/nav_pages/queue_page.dart';
import 'package:openair/views/navigation/list_drawer.dart';
import 'package:opml/opml.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

final audioControllerProvider = ChangeNotifierProvider<AudioController>(
  (ref) => AudioController(ref),
);

enum DownloadStatus { downloaded, downloading, notDownloaded }

enum PlayingStatus { detail, buffering, playing, paused, stop }

class AudioController extends ChangeNotifier {
  AudioController(this.ref);

  final Ref ref;

  final OpenAirAudioHandler _audioHandler = getAudioHandler();
  OpenAirAudioHandler get audioHandler => _audioHandler;
  AudioPlayer get player => _audioHandler.player;

  PodcastModel? currentPodcast;
  Map<String, dynamic>? currentEpisode;
  Map<String, dynamic>? nextEpisode;

  bool isPodcastSelected = false;
  bool onceQueueComplete = false;
  bool isCompleted = false;

  late String podcastTitle;
  late String podcastSubtitle;

  late String audioState;
  late String loadState;

  Duration playerPosition = Duration.zero;
  Duration playerTotalDuration = Duration.zero;

  late double podcastCurrentPositionInMilliseconds;
  late String currentPlaybackPositionString;
  late String currentPlaybackRemainingTimeString;
  late String? currentPlaybackDurationString;

  late PlayingStatus isPlaying = PlayingStatus.stop;

  String? currentPodcastTimeRemaining;

  List<String> audioSpeedOptions = ['0.5x', '1.0x', '1.25x', '1.5x', '2.0x'];

  List downloadingPodcasts = [];

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

  Future<String> getDownloadsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError(
          'File system operations are not supported on web.');
    }
    final hiveService = ref.read(hiveServiceProvider);
    final baseDir = hiveService.openAirDir;
    final downloadsDirPath = join(baseDir.path, '.downloaded_episodes');
    final downloadsDir = Directory(downloadsDirPath);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir.path;
  }

  Future<bool> isAudioDownloaded(String guid) async {
    if (kIsWeb) return false;
    final filename = '$guid.mp3';
    final downloadsDir = await getDownloadsDirectory();
    final filePath = join(downloadsDir, filename);
    return File(filePath).exists();
  }

  Future<void> playEpisode(
    Map<String, dynamic> episodeItem,
    BuildContext context,
  ) async {
    currentEpisode = episodeItem;
    if (currentPodcast != null) {
      if (currentEpisode!['podcastTitle'] == null) {
        currentEpisode!['podcastTitle'] = currentPodcast!.title;
      }
      if (currentEpisode!['author'] == null ||
          currentEpisode!['author'].isEmpty) {
        currentEpisode!['author'] = currentPodcast!.author ?? 'Unknown';
      }
    }
    final bool isDownloaded = await isAudioDownloaded(currentEpisode!['guid']);

    isPodcastSelected = true;
    onceQueueComplete = false;
    isCompleted = false;

    try {
      final imageUrl =
          currentEpisode!['image'] ?? currentEpisode!['feedImage'] ?? '';
      final title = currentEpisode!['title'] ?? 'Unknown';
      final artist = currentEpisode!['author'] ??
          currentEpisode!['podcastTitle'] ??
          'Unknown';

      await _audioHandler.setMediaItem(
        id: currentEpisode!['guid'],
        title: title,
        artist: artist,
        album: currentEpisode!['podcastTitle'] ?? '',
        artUri: imageUrl,
      );

      if (isDownloaded) {
        final downloadsDir = await getDownloadsDirectory();
        final filePath = join(downloadsDir, '${episodeItem['guid']}.mp3');
        await _audioHandler.playFromFile(filePath);
      } else {
        await _audioHandler.playFromUrl(currentEpisode!['enclosureUrl']);
      }

      Future.delayed(Duration(seconds: 3), () {
        final duration = _audioHandler.duration;
        if (duration != null) {
          currentPlaybackDurationString = formatPlaybackPosition(duration);
        }
      });

      isPlaying = PlayingStatus.playing;
      audioState = 'Play';
      loadState = 'Play';
      nextEpisode = currentEpisode;

      await addToHistory(currentEpisode!, currentPodcast);
      notifyListeners();
    } on TimeoutException {
      _handlePlaybackError();
    } catch (e) {
      _handlePlaybackError();
    }
  }

  void _handlePlaybackError() {
    isPlaying = PlayingStatus.stop;
    audioState = 'Stop';
    loadState = 'Detail';
    notifyListeners();
  }

  Future<void> resumePlayback() async {
    await _audioHandler.play();
    audioState = 'Play';
    loadState = 'Play';
    isPlaying = PlayingStatus.playing;
    isCompleted = false;
    notifyListeners();
  }

  Future<void> pausePlayback() async {
    await _audioHandler.pause();
    audioState = 'Pause';
    loadState = 'Detail';
    isPlaying = PlayingStatus.paused;
    notifyListeners();
  }

  void rewind() {
    if (playerPosition.inSeconds - int.parse(rewindIntervalConfig) > 0) {
      _audioHandler.seek(Duration(
          seconds: playerPosition.inSeconds - int.parse(rewindIntervalConfig)));
    }
  }

  void fastForward() {
    if (playerPosition.inSeconds + int.parse(fastForwardIntervalConfig) <
        playerTotalDuration.inSeconds) {
      _audioHandler.seek(Duration(
          seconds:
              playerPosition.inSeconds + int.parse(fastForwardIntervalConfig)));
    }
  }

  void cyclePlaybackSpeed() {
    final int index = audioSpeedOptions.indexOf(playbackSpeedConfig);
    final int newIndex = (index + 1) % audioSpeedOptions.length;
    playbackSpeedConfig = audioSpeedOptions[newIndex];
    _audioHandler.setSpeed(double.parse(playbackSpeedConfig.split('x').first));
    notifyListeners();
  }

  void seekTo(double sliderValue) {
    final Duration duration = Duration(
        milliseconds:
            (sliderValue * playerTotalDuration.inMilliseconds).toInt());
    podcastCurrentPositionInMilliseconds =
        ((sliderValue * playerTotalDuration.inMilliseconds) /
                playerTotalDuration.inMilliseconds)
            .clamp(0.0, 1.0);
    _audioHandler.seek(duration);
    notifyListeners();
  }

  String formatPlaybackPosition(Duration timeline) {
    final int hours = timeline.inHours;
    final int minutes = timeline.inMinutes % 60;
    final int seconds = timeline.inSeconds % 60;
    return "${hours != 0 ? hours < 10 ? '0$hours:' : '$hours:' : '00:'}${minutes != 0 ? minutes < 10 ? '0$minutes:' : '$minutes:' : '00:'}${seconds != 0 ? seconds < 10 ? '0$seconds' : '$seconds' : '00'}";
  }

  String getEpisodeSize(int size) {
    if (size < 1024) {
      return '$size Bytes';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      final double sizeMB = size / (1024 * 1024);
      if (sizeMB < 1024) {
        return '${sizeMB.toStringAsFixed(2)} MB';
      } else {
        return '${(sizeMB / 1024).toStringAsFixed(2)} GB';
      }
    }
  }

  Future<void> downloadEpisode(
    Map<String, dynamic> item,
    PodcastModel podcast,
    BuildContext? context,
  ) async {
    final hiveService = ref.read(hiveServiceProvider);
    final downloadLimitString = downloadEpisodeLimitConfig;
    final downloadLimit = downloadLimitString != 'Unlimited'
        ? int.tryParse(downloadLimitString)
        : null;
    final downloadedCount = await hiveService.downloadsCount();

    if (downloadLimit != null && downloadedCount >= downloadLimit) {
      return;
    }

    final dio = Dio();
    final guid = item['guid'] as String;
    final url = item['enclosureUrl'] as String;
    final size = getEpisodeSize(item['enclosureLength']);

    if (downloadingPodcasts.contains(guid)) return;
    downloadingPodcasts.add(guid);
    notifyListeners();

    try {
      final filename = '${item['guid']}.mp3';
      final downloadsDir = await getDownloadsDirectory();
      final savePath = join(downloadsDir, filename);
      await dio.download(url, savePath);

      final downloadModel = DownloadModel(
        guid: guid,
        image: item['image'] ?? item['feedImage'],
        title: item['title'],
        author: podcast.author!,
        datePublished: item['datePublished'],
        description: item['description'],
        feedUrl: item['feedUrl'],
        duration: item['duration'],
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
      ref.invalidate(getDownloadsProvider);
    } catch (e) {
      debugPrint('Error downloading ${item['title']}: $e');
      final filename = '${item['guid']}.mp3';
      final filePath = await getDownloadsDirectory();
      final file = File('$filePath/$filename');
      if (await file.exists()) await file.delete();
    } finally {
      downloadingPodcasts.remove(guid);
      notifyListeners();
    }
  }

  Future<void> removeDownload(Map<String, dynamic> item) async {
    if (kIsWeb) return;
    final guid = item['guid'] as String;
    try {
      final filename = '${item['guid']}.mp3';
      final filePath = await getDownloadsDirectory();
      final file = File('$filePath/$filename');
      if (await file.exists()) await file.delete();
      final hiveService = ref.read(hiveServiceProvider);
      await hiveService.deleteDownload(guid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing download for ${item['title']}: $e');
    }
  }

  Future<void> removeAllDownloads(BuildContext context) async {
    if (kIsWeb) return;
    try {
      final downloadsDirPath = await getDownloadsDirectory();
      final downloadsDirectory = Directory(downloadsDirPath);
      if (await downloadsDirectory.exists()) {
        await for (final entity in downloadsDirectory.list()) {
          await entity.delete(recursive: true);
        }
      }
      final hiveService = ref.read(hiveServiceProvider);
      await hiveService.clearDownloads();
      ref.invalidate(getDownloadsProvider);
      ref.invalidate(sortedDownloadsProvider);
      ref.invalidate(downloadsCountProvider);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing all downloaded podcasts: $e');
    }
  }

  Future<void> addToHistory(
      Map<String, dynamic> episode, PodcastModel? podcast) async {
    final String downloadSize = getEpisodeSize(episode['enclosureLength']);
    String historyPodcastId;
    String historyPodcastImage;
    String? historyPodcastAuthor;

    if (podcast != null) {
      historyPodcastId = podcast.id.toString();
      historyPodcastImage = podcast.imageUrl;
      historyPodcastAuthor = podcast.author ?? episode['author'] ?? 'Unknown';
    } else {
      historyPodcastId = episode['podcastId']?.toString() ?? '-1';
      historyPodcastImage = episode['image'] ?? '';
      historyPodcastAuthor =
          episode['author'] ?? episode['podcastTitle'] ?? 'Unknown';
    }

    final HistoryModel historyMod = HistoryModel(
      guid: episode['guid'],
      image: historyPodcastImage,
      title: episode['title'],
      author: historyPodcastAuthor!,
      datePublished: episode['datePublished'],
      description: episode['description'],
      feedUrl: episode['feedUrl'],
      duration: episode['duration'],
      size: downloadSize,
      podcastId: historyPodcastId,
      enclosureLength: episode['enclosureLength'],
      enclosureUrl: episode['enclosureUrl'],
      playDate: DateTime.now().millisecondsSinceEpoch,
    );

    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.addToHistory(historyMod);
    ref.invalidate(getHistoryProvider);
  }

  Future<void> addToQueue(Map<String, dynamic> episode, PodcastModel? podcast,
      BuildContext context) async {
    final hiveService = ref.read(hiveServiceProvider);
    final queue = await hiveService.getQueue();

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
        pos = queue.isEmpty ? 1 : queueList.last['pos'] + 1;
        break;
      case 'After current episode':
        if (currentEpisode != null && currentEpisode!.isNotEmpty) {
          pos = queue.isEmpty
              ? 1
              : (queueList
                          .where((e) => e['guid'] == currentEpisode!['guid'])
                          .firstOrNull?['pos'] ??
                      queueList.last['pos']) +
                  1;
          for (var item in queueList) {
            if (item['pos'] >= pos) {
              item['pos'] = item['pos'] + 1;
              await hiveService.addToQueue(item);
            }
          }
        } else {
          pos = queue.isEmpty ? 1 : queueList.last['pos'] + 1;
        }
        break;
      default:
        pos = queue.isEmpty ? 1 : queueList.last['pos'] + 1;
    }

    hiveService.addToQueue({
      'guid': episode['guid'],
      'title': episode['title'],
      'author': episode['author'] ?? 'Unknown',
      'image': episode['feedImage'] ?? episode['image'],
      'datePublished': episode['datePublished'],
      'description': episode['description'],
      'feedUrl': episode['feedUrl'],
      'duration': episode['duration'],
      'downloadSize': getEpisodeSize(episode['enclosureLength']),
      'enclosureType': episode['enclosureType'] ?? 'audio/mpeg',
      'enclosureLength': episode['enclosureLength'],
      'enclosureUrl': episode['enclosureUrl'],
      'podcast': podcast!.toJson(),
      'pos': pos,
      'podcastCurrentPositionInMilliseconds': 0.0,
      'currentPlaybackPositionString': formatPlaybackPosition(Duration.zero),
      'currentPlaybackRemainingTimeString': '',
      'playerPosition': Duration.zero.inMilliseconds,
    });

    if (downloadQueuedEpisodesConfig) {
      await downloadEpisode(episode, podcast, null);
    }

    ref.invalidate(getQueueProvider);
    notifyListeners();
  }

  Future<void> removeFromQueue(String guid) async {
    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.removeFromQueue(guid: guid);
    ref.invalidate(sortedProvider);
    ref.invalidate(getQueueProvider);
    notifyListeners();
  }

  Future<void> addPodcastEpisodes(
      SubscriptionModel podcast, BuildContext? context) async {
    final podcastIndexService = ref.read(podcastIndexProvider);
    final episodes =
        await podcastIndexService.getEpisodesByFeedUrl(podcast.feedUrl);
    final hiveService = ref.read(hiveServiceProvider);

    for (int i = 0; i < episodes['count']; i++) {
      final episode = {
        'podcastId': podcast.id.toString(),
        'podcastTitle': podcast.title,
        'guid': episodes['items'][i]['guid'],
        'title': episodes['items'][i]['title'],
        'author': podcast.author,
        'image': episodes['items'][i]['feedImage'],
        'datePublished': episodes['items'][i]['datePublished'],
        'description': episodes['items'][i]['description'],
        'feedUrl': episodes['items'][i]['feedUrl'],
        'duration': episodes['items'][i]['duration'],
        'size': getEpisodeSize(episodes['items'][i]['enclosureLength']),
        'enclosureLength': episodes['items'][i]['enclosureLength'],
        'enclosureUrl': episodes['items'][i]['enclosureUrl'],
      };
      await hiveService.insertEpisode(episode, episode['guid']);
    }

    ref.invalidate(feedCountProvider);
    notifyListeners();
  }

  Future<void> subscribeToPodcast(
      PodcastModel podcast, BuildContext? context) async {
    try {
      final podcastIndexService = ref.read(podcastIndexProvider);
      final podcastEpisodeCount = await podcastIndexService
          .getPodcastEpisodeCountByPodcastId(podcast.id);

      final subscription = SubscriptionModel(
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
      await hiveService.subscribe(subscription);
      if (context != null && context.mounted) {
        await addPodcastEpisodes(subscription, context);
      } else {
        await addPodcastEpisodes(subscription, null);
      }

      ref.invalidate(getSubscribedEpisodesProvider);
      ref.invalidate(subscriptionsProvider);
      ref.invalidate(subCountProvider);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to subscribe to ${podcast.title}: $e');
    }
  }

  Future<void> unsubscribeFromPodcast(PodcastModel podcast) async {
    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.unsubscribe(podcast.title);
    await hiveService.removePodcastEpisodes(podcast);
    ref.invalidate(getSubscribedEpisodesProvider);
    ref.invalidate(subscriptionsProvider);
    ref.invalidate(subCountProvider);
    ref.invalidate(inboxCountProvider);
    notifyListeners();
  }

  Future<bool> addPodcastByRssUrl(String rssUrl, BuildContext context) async {
    try {
      final fyydProviderService = ref.read(fyydProvider);
      final xmlString =
          await fyydProviderService.getPodcastXml(rssUrl, context);
      final rssFeed = RssFeed.parse(xmlString);

      final subscription = SubscriptionModel(
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

      if (context.mounted) {
        await subscribeToPodcastByRssFeed(subscription, context);
      }
      return true;
    } catch (e) {
      debugPrint('Failed to add podcast by RSS URL: $e');
      return false;
    }
  }

  Future<void> subscribeToPodcastByRssFeed(
      SubscriptionModel podcast, BuildContext context) async {
    try {
      final podcastIndexService = ref.read(podcastIndexProvider);
      final podcastEpisodeCount = await podcastIndexService
          .getPodcastEpisodeCountByTitle(podcast.title);

      final subscription = SubscriptionModel(
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
      await hiveService.subscribe(subscription);
      if (context.mounted) await addPodcastEpisodes(subscription, context);
      ref.invalidate(getSubscribedEpisodesProvider);
      ref.invalidate(subscriptionsProvider);
      ref.invalidate(subCountProvider);
    } catch (e) {
      debugPrint('Failed to subscribe (RSS Feed) to ${podcast.title}: $e');
      rethrow;
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

  Future<bool> isAudioFileDownloaded(String guid) => isAudioDownloaded(guid);

  Future<void> initAudio(BuildContext context) => initializeAudio(context);

  Future<void> initializeAudio(BuildContext context) async {
    // Set up position listener
    _audioHandler.positionStream.listen((Duration position) {
      playerPosition = position;
      currentPlaybackPositionString = formatPlaybackPosition(position);

      if (playerTotalDuration.inMilliseconds > 0) {
        podcastCurrentPositionInMilliseconds =
            (position.inMilliseconds / playerTotalDuration.inMilliseconds)
                .clamp(0.0, 1.0);

        final remaining = playerTotalDuration - position;
        currentPodcastTimeRemaining = formatPlaybackPosition(remaining);
      } else {
        podcastCurrentPositionInMilliseconds = 0.0;
      }

      notifyListeners();
    });

    // Set up duration listener
    _audioHandler.durationStream.listen((Duration? duration) {
      if (duration != null) {
        playerTotalDuration = duration;
        currentPlaybackDurationString = formatPlaybackPosition(duration);
        notifyListeners();
      }
    });

    // Set up player state listener
    _audioHandler.playerStateStream.listen((PlayerState state) {
      switch (state.processingState) {
        case ProcessingState.ready:
          if (state.playing) {
            isPlaying = PlayingStatus.playing;
            audioState = 'Play';
            loadState = 'Play';
          } else {
            isPlaying = PlayingStatus.paused;
            audioState = 'Pause';
            loadState = 'Detail';
          }
          break;
        case ProcessingState.completed:
          isPlaying = PlayingStatus.stop;
          audioState = 'Stop';
          loadState = 'Detail';
          isCompleted = true;
          break;
        case ProcessingState.idle:
          isPlaying = PlayingStatus.stop;
          audioState = 'Stop';
          loadState = 'Detail';
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  Future<void> playerPlayButtonClicked(
    Map<String, dynamic> episodeItem,
    BuildContext context,
  ) async {
    await playEpisode(episodeItem, context);
  }

  String getPodcastPublishedDateFromEpoch(int epoch) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void subscribe(PodcastModel podcast, BuildContext context) {
    subscribeToPodcast(podcast, context);
  }

  void unsubscribe(PodcastModel podcast) {
    unsubscribeFromPodcast(podcast);
  }

  Future<bool> importPodcastFromOpml(BuildContext context) async {
    return await importOpml(context);
  }

  Future<bool> importOpml(BuildContext context) async {
    String defaultFilePath;
    FilePickerResult? result;

    if (Platform.isAndroid) {
      defaultFilePath = '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      defaultFilePath = (await getApplicationDocumentsDirectory()).path;
    } else {
      defaultFilePath = await getDownloadsDirectory();
    }

    if (context.mounted) {
      result = await FilePicker.pickFiles(
        dialogTitle: 'Import OPML',
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
    }
    return false;
  }

  Future<void> removeAllDownloadedPodcasts(BuildContext context) async {
    await removeAllDownloads(context);
  }

  Future<void> playerPauseButtonClicked() => pausePlayback();

  Future<void> playerResumeButtonClicked() => resumePlayback();

  void mainPlayerSliderClicked(double sliderValue) => seekTo(sliderValue);

  Future<void> playPreviousEpisode(BuildContext context) async {
    // Implementation in audio controller
    final hiveService = ref.read(hiveServiceProvider);
    Map queueMap = await hiveService.getQueue();

    List<Map<String, dynamic>> queueList =
        queueMap.values.map((e) => Map<String, dynamic>.from(e)).toList();
    queueList.sort((a, b) => (a['pos'] as int).compareTo(b['pos'] as int));

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

    if (currentEpisodeIndex == -1 || currentEpisodeIndex == 0) return;

    await updateCurrentQueueCard(
      currentEpisode!['guid'],
      podcastCurrentPositionInMilliseconds,
      currentPlaybackPositionString,
      currentPlaybackRemainingTimeString,
      playerPosition,
    );

    await _audioHandler.stop();

    Map<String, dynamic> previousEpisode = queueList[currentEpisodeIndex - 1];
    currentEpisode = previousEpisode;
    currentPodcast = previousEpisode['podcast'];

    if (context.mounted) {
      await queuePlayButtonClicked(
        previousEpisode,
        previousEpisode['playerPosition'],
        context,
      );
    }
    notifyListeners();
  }

  void rewindButtonClicked() => rewind();

  void fastForwardButtonClicked() => fastForward();

  void audioSpeedButtonClicked() => cyclePlaybackSpeed();

  String convertSecondsToDuration(int totalSeconds, BuildContext context) {
    if (totalSeconds <= 0) return '';

    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }

    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  Future<Map> getFavoriteEpisodes() async {
    final hiveService = ref.read(hiveServiceProvider);
    return await hiveService.getFavoriteEpisodes();
  }

  Future<void> queuePlayButtonClicked(
    Map<String, dynamic> queueItem,
    Duration position,
    BuildContext context,
  ) async {
    currentEpisode = queueItem;
    isPodcastSelected = true;
    onceQueueComplete = false;
    isCompleted = false;
    playerPosition = position;

    final isDownloaded = await isAudioDownloaded(queueItem['guid']);

    if (isDownloaded) {
      final filename = '${currentEpisode!['guid']}.mp3';
      final filePath = await getDownloadsDirectory();
      final file = File('$filePath/$filename');
      await _audioHandler.playFromFile(file.path, initialPosition: position);
    } else {
      await _audioHandler.playFromUrl(currentEpisode!['enclosureUrl'],
          initialPosition: position);
    }

    isPlaying = PlayingStatus.playing;
    audioState = 'Play';
    loadState = 'Play';
    nextEpisode = currentEpisode;

    await addToHistory(currentEpisode!, currentPodcast);
    notifyListeners();
  }

  Future<void> updateCurrentQueueCard(
    String guid,
    double podcastCurrentPositionInMilliseconds,
    String currentPlaybackPositionString,
    String currentPlaybackRemainingTimeString,
    Duration position,
  ) async {
    final hiveService = ref.read(hiveServiceProvider);
    final existingQueueItem = await hiveService.getQueueByGuid(guid);

    if (existingQueueItem != null) {
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

  Future<void> playNewQueueItem(
      Map<String, dynamic> newItem, BuildContext context) async {
    if ((isPlaying == PlayingStatus.playing ||
            isPlaying == PlayingStatus.paused) &&
        currentEpisode != null) {
      await updateCurrentQueueCard(
        currentEpisode!['guid'],
        podcastCurrentPositionInMilliseconds,
        currentPlaybackPositionString,
        currentPlaybackRemainingTimeString,
        playerPosition,
      );
    }

    if (context.mounted) {
      await queuePlayButtonClicked(newItem, newItem['playerPosition'], context);
    }
  }

  Future<void> playNextEpisode(BuildContext context) async {
    if (currentEpisode == null || currentEpisode!.isEmpty) return;

    final hiveService = ref.read(hiveServiceProvider);
    final queueMap = await hiveService.getQueue();

    List<Map<String, dynamic>> queueList =
        queueMap.values.map((e) => Map<String, dynamic>.from(e)).toList();
    queueList.sort((a, b) => (a['pos'] as int).compareTo(b['pos'] as int));

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

    if (currentEpisodeIndex == -1 ||
        currentEpisodeIndex == queueList.length - 1) {
      return;
    }

    await updateCurrentQueueCard(
      currentEpisode!['guid'],
      podcastCurrentPositionInMilliseconds,
      currentPlaybackPositionString,
      currentPlaybackRemainingTimeString,
      playerPosition,
    );

    await _audioHandler.stop();

    final nextEpisodeData = queueList[currentEpisodeIndex + 1];
    currentEpisode = nextEpisodeData;
    currentPodcast = nextEpisodeData['podcast'];

    if (context.mounted) {
      await queuePlayButtonClicked(
          nextEpisodeData, nextEpisodeData['playerPosition'], context);
    }

    notifyListeners();
  }

  String formatCurrentPlaybackPosition(Duration timeline) {
    return formatPlaybackPosition(timeline);
  }
}
