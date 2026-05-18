import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:openair/config/config.dart';
import 'package:openair/controllers/subscription_controller.dart';
import 'package:openair/controllers/sync_controller.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/history_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/views/main_pages/episode_detail.dart';
import 'package:path_provider/path_provider.dart';

final openAirProvider = ChangeNotifierProvider<OpenAirProvider>(
  (ref) => OpenAirProvider(ref),
);

class OpenAirProvider extends ChangeNotifier {
  late BuildContext context;

  final String storagePath = 'openair/downloads';

  Directory? directory;

  int navIndex = 1;

  late bool hasConnection;

  final Ref ref;

  OpenAirProvider(this.ref);

  HiveService get hiveService => ref.read(hiveServiceProvider);
  SyncController get syncController => ref.read(syncControllerProvider);
  AudioController get audioController => ref.read(audioProvider);
  SubscriptionController get subscriptionController =>
      ref.read(subscriptionControllerProvider);

  Future<void> initial(BuildContext context) async {
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    this.context = context;

    final hiveService = ref.read(hiveServiceProvider);
    if (context.mounted) await hiveService.initial(context);

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

    automaticDownloadQueuedEpisodes();
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

  void automaticDownloadQueuedEpisodes() {
    if (downloadQueuedEpisodesConfig) {
      // Implementation delegated to audio controller
    }
  }

  Future<void> exportToDb(String path) async {
    await syncController.exportDatabase(path);
  }

  Future<void> importFromDb(File file) async {
    await syncController.importDatabase(file);
  }

  // Backward compatibility methods delegating to controllers

  Future<bool> isSubscribed(String podcastTitle) async {
    return await subscriptionController.checkSubscriptionStatus(podcastTitle);
  }

  Future<Map<String, SubscriptionModel>> getSubscriptions() async {
    final subs = await subscriptionController.fetchAllSubscriptions();
    return subs;
  }

  Future<String> getSubscriptionsCount(String title) async {
    return await subscriptionController.getEpisodeCount(title);
  }

  Future<String> getAccumulatedSubscriptionCount() async {
    return await subscriptionController.getTotalNewEpisodesCount();
  }

  Future<String> getFeedsCount() async {
    return await hiveService.feedsCount();
  }

  Future<int> getInboxCount() async {
    return await hiveService.getNewInboxCount();
  }

  Future<String> getQueueCount() async {
    return await hiveService.queueCount();
  }

  Future<int> getDownloadsCount() async {
    return await hiveService.downloadsCount();
  }

  Future getQueue() async {
    return await hiveService.getQueue();
  }

  Future<bool> isEpisodeNew(String guid) async {
    final result = await hiveService.getEpisode(guid);
    return result == null;
  }

  Future<List<Map>> getSubscribedEpisodes() async {
    return await hiveService.getEpisodes();
  }

  Future<List<DownloadModel>> getSortedDownloadedEpisodes() async {
    return await hiveService.getSortedDownloads();
  }

  Future<List<HistoryModel>> getSortedHistory() async {
    return await hiveService.getSortedHistory();
  }

  void shareEpisode(
    BuildContext context,
    Map<String, dynamic> episode,
    String podcastTitle,
  ) {
    final episodeTitle = episode['title'] ?? 'Episode';
    final enclosureUrl = episode['enclosureUrl'] ?? '';
    final description = episode['description'] ?? '';
    final episodeUrl = episode['feedUrl'] ?? enclosureUrl;
    final guid = episode['guid'] ?? enclosureUrl;

    // Generate deep link for the episode
    final deepLink = 'openair://episode/${Uri.encodeComponent(guid)}';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Share Episode',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                // Copy Deep Link
                ListTile(
                  leading: const Icon(Icons.link_rounded),
                  title: const Text('Copy App Link'),
                  subtitle: const Text('Opens this episode in the OpenAir app'),
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: deepLink),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App link copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                // Copy Episode Link
                ListTile(
                  leading: const Icon(Icons.link_rounded),
                  title: const Text('Copy Episode Link'),
                  subtitle: const Text('Direct link to the episode audio'),
                  onTap: () {
                    if (episodeUrl.isNotEmpty) {
                      Clipboard.setData(
                        ClipboardData(text: episodeUrl),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Episode link copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                // Copy Episode Details
                ListTile(
                  leading: const Icon(Icons.info_rounded),
                  title: const Text('Copy Episode Details'),
                  onTap: () {
                    final shareText =
                        '$episodeTitle\n\nPodcast: $podcastTitle\n\n$description\n\n$deepLink';
                    Clipboard.setData(
                      ClipboardData(text: shareText),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Episode details copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const Divider(height: 24),
                // Share via Social Media
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Share to Social Media',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                // Twitter/X
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share on Twitter'),
                  onTap: () {
                    _shareToTwitter(
                      context,
                      episodeTitle,
                      podcastTitle,
                      deepLink,
                    );
                  },
                ),
                // Facebook
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share on Facebook'),
                  onTap: () {
                    _shareToFacebook(
                      context,
                      episodeTitle,
                      podcastTitle,
                      deepLink,
                    );
                  },
                ),
                // WhatsApp
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share on WhatsApp'),
                  onTap: () {
                    _shareToWhatsApp(
                      context,
                      episodeTitle,
                      podcastTitle,
                      deepLink,
                    );
                  },
                ),
                // Email
                ListTile(
                  leading: const Icon(Icons.email_rounded),
                  title: const Text('Share via Email'),
                  onTap: () {
                    _shareViaEmail(
                      context,
                      episodeTitle,
                      podcastTitle,
                      deepLink,
                      description,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareToTwitter(
    BuildContext context,
    String episodeTitle,
    String podcastTitle,
    String episodeUrl,
  ) async {
    try {
      final text = Uri.encodeComponent(
        'Listening to "$episodeTitle" from $podcastTitle\n$episodeUrl',
      );
      final url = 'https://twitter.com/intent/tweet?text=$text';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error sharing to Twitter: $e');
    }
  }

  Future<void> _shareToFacebook(
    BuildContext context,
    String episodeTitle,
    String podcastTitle,
    String episodeUrl,
  ) async {
    try {
      final url =
          'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(episodeUrl)}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error sharing to Facebook: $e');
    }
  }

  Future<void> _shareToWhatsApp(
    BuildContext context,
    String episodeTitle,
    String podcastTitle,
    String episodeUrl,
  ) async {
    try {
      final text = Uri.encodeComponent(
        'Check out "$episodeTitle" from $podcastTitle: $episodeUrl',
      );
      final url = 'whatsapp://send?text=$text';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp is not installed'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error sharing to WhatsApp: $e');
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _shareViaEmail(
    BuildContext context,
    String episodeTitle,
    String podcastTitle,
    String episodeUrl,
    String description,
  ) async {
    try {
      final subject = Uri.encodeComponent('Check out: $episodeTitle');
      final body = Uri.encodeComponent(
        'I wanted to share this episode with you:\n\n'
        'Episode: $episodeTitle\n'
        'Podcast: $podcastTitle\n\n'
        'Description:\n$description\n\n'
        'Listen here: $episodeUrl',
      );
      final url = 'mailto:?subject=$subject&body=$body';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error sharing via email: $e');
    }
  }

  void share() {
    debugPrint('share button clicked');
  }

  Future<void> exportPodcastToOpml() async {}

  Future<void> openEpisodeByGuid(String guid, BuildContext context) async {
    try {
      final episode = await hiveService.getEpisode(guid);
      if (episode != null && context.mounted) {
        // Get podcast information from episode
        final podcastData = episode['podcast'] as Map<String, dynamic>?;
        if (podcastData != null) {
          final podcast = PodcastModel.fromJson(podcastData);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EpisodeDetail(
                episodeItem: episode,
                podcast: podcast,
              ),
            ),
          );
        } else {
          debugPrint('Podcast data not found for episode');
        }
      } else {
        debugPrint('Episode not found with guid: $guid');
        if (context.mounted) {
          _showEpisodeNotFoundDialog(context, guid);
        }
      }
    } catch (e) {
      debugPrint('Error opening episode by guid: $e');
      if (context.mounted) {
        _showEpisodeNotFoundDialog(context, guid);
      }
    }
  }

  void _showEpisodeNotFoundDialog(BuildContext context, String guid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Episode Not Found'),
        content: Text(
          'This episode is not in your local database. You may need to subscribe to the podcast first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void downloadEnqueue(BuildContext context) async {
    // Implementation delegated to audio controller
  }

  Future<void> synchronize(BuildContext context) async {
    await syncController.synchronize(context);
  }
}

final getConnectionStatusProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final podcastIndexService = ref.read(openAirProvider);
  return await podcastIndexService.getConnectionStatus();
});
