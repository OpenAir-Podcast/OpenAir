import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/drawer_counts.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/nav_pages/add_podcast_page.dart';
import 'package:openair/views/nav_pages/downloads_page.dart';
import 'package:openair/views/nav_pages/favorites_page.dart';
import 'package:openair/views/nav_pages/queue_page.dart';
import 'package:openair/views/nav_pages/history_page.dart';
import 'package:openair/views/nav_pages/inbox_page.dart';
import 'package:openair/views/nav_pages/log_in_page.dart';
import 'package:openair/views/nav_pages/subscriptions_page.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';
import 'package:openair/views/nav_pages/settings_page.dart';
import 'package:openair/controllers/subscription_controller.dart';

// Legacy providers kept for backward compatibility
final subCountProvider = FutureProvider.autoDispose<String>((ref) async {
  final hiveService = ref.read(openAirProvider).hiveService;
  var episodes = await hiveService.getNewEpisodesCount();

  if (episodes != -1) {
    return episodes.toString();
  }

  return await ref.read(openAirProvider).getAccumulatedSubscriptionCount();
});

final feedCountProvider = FutureProvider.autoDispose<String>((ref) async {
  return await ref.read(openAirProvider).getFeedsCount();
});

final inboxCountProvider = FutureProvider.autoDispose<int>((ref) async {
  return await ref.read(openAirProvider).getInboxCount();
});

final queueCountProvider = FutureProvider.autoDispose<String>((ref) async {
  return await ref.read(openAirProvider).getQueueCount();
});

final downloadsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  return await ref.read(openAirProvider).getDownloadsCount();
});

final drawerCountsProvider =
    FutureProvider.autoDispose<DrawerCounts>((ref) async {
  final openAir = ref.read(openAirProvider);
  final hiveService = openAir.hiveService;

  final results = await Future.wait([
    hiveService.getNewEpisodesCount(),
    hiveService.feedsCount(),
    hiveService.getNewInboxCount(),
    hiveService.queueCount(),
    hiveService.downloadsCount(),
  ]);

  String subCount;
  if (results[0] != -1) {
    subCount = (results[0] as int).toString();
  } else {
    subCount = await openAir.getAccumulatedSubscriptionCount();
  }

  return DrawerCounts(
    subscriptions: subCount,
    feeds: results[1] as String,
    inbox: (results[2] as int).toString(),
    queue: results[3] as String,
    downloads: (results[4] as int).toString(),
  );
});

class ListDrawer extends ConsumerStatefulWidget {
  const ListDrawer({
    super.key,
  });

  @override
  ConsumerState<ListDrawer> createState() => _ListDrawerState();
}

class _ListDrawerState extends ConsumerState<ListDrawer> {
  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final drawerCounts = ref.watch(drawerCountsProvider);

    final supabaseService = ref.watch(supabaseServiceProvider);
    final session = supabaseService.client.auth.currentUser;

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8.0,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/icons/icon.png',
                      width: circleSize,
                      height: circleSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (session == null) {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LogIn(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        await ref
                            .read(subscriptionControllerProvider)
                            .clearAllSubscriptions();
                        ref.invalidate(drawerCountsProvider);
                        await supabaseService.signOut();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(
                      session == null
                          ? Translations.of(context).text('login')
                          : Translations.of(context).text('logout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: Text(Translations.of(context).text('home')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/');
                  },
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.subscriptions_rounded,
                  Translations.of(context).text('subscriptions'),
                  drawerCounts,
                  (c) => c.subscriptions,
                  () => _navigateTo(const SubscriptionsPage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.feed_rounded,
                  Translations.of(context).text('feeds'),
                  drawerCounts,
                  (c) => c.feeds,
                  () => _navigateTo(const FeedsPage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.inbox_rounded,
                  Translations.of(context).text('inbox'),
                  drawerCounts,
                  (c) => c.inbox,
                  () => _navigateTo(const InboxPage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.queue_rounded,
                  Translations.of(context).text('queue'),
                  drawerCounts,
                  (c) => c.queue,
                  () => _navigateTo(const QueuePage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.download_rounded,
                  Translations.of(context).text('downloads'),
                  drawerCounts,
                  (c) => c.downloads,
                  () => _navigateTo(const DownloadsPage()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.redAccent,
                  ),
                  title: Text(Translations.of(context).text('favorites')),
                  onTap: () => _navigateTo(const FavoritesPage()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: Text(Translations.of(context).text('history')),
                  onTap: () => _navigateTo(const HistoryPage()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: Text(Translations.of(context).text('addPodcast')),
                  onTap: () => _navigateTo(const AddPodcastPage()),
                ),
                const Divider(),
                const ListDrawerSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountTile(
    BuildContext context,
    IconData icon,
    String title,
    AsyncValue<DrawerCounts> drawerCounts,
    String Function(DrawerCounts) selector,
    VoidCallback onTap,
  ) {
    return drawerCounts.when(
      loading: () => ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, _) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.error_outline, color: Colors.red),
        onTap: onTap,
      ),
      data: (data) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          selector(data),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}

class ListDrawerSettings extends ConsumerWidget {
  const ListDrawerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.settings_rounded),
      title: Text(Translations.of(context).text('settings')),
      onTap: () => _navigateToSettings(context),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Settings(functionBuild: () {})),
    );
  }
}
