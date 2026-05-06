import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/config/config.dart';
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

final subCountProvider = FutureProvider.autoDispose<String>((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
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
    ref.watch(localeProvider); // Ensure rebuild on language change
    final getSubCountValue = ref.watch(subCountProvider);
    final getFeedsCountValue = ref.watch(feedCountProvider);
    final getInboxCountValue = ref.watch(inboxCountProvider);
    final getQueueCountValue = ref.watch(queueCountProvider);
    final getDownloadsCountValue = ref.watch(downloadsCountProvider);

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
                    onPressed: () {
                      if (session == null) {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LogIn(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        supabaseService.signOut();
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
                  getSubCountValue,
                  () => _navigateTo(const SubscriptionsPage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.feed_rounded,
                  Translations.of(context).text('feeds'),
                  getFeedsCountValue,
                  () => _navigateTo(const FeedsPage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.inbox_rounded,
                  Translations.of(context).text('inbox'),
                  getInboxCountValue,
                  () => _navigateTo(const InboxPage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.queue_rounded,
                  Translations.of(context).text('queue'),
                  getQueueCountValue,
                  () => _navigateTo(const QueuePage()),
                ),
                const Divider(),
                _buildCountTile(
                  context,
                  Icons.download_rounded,
                  Translations.of(context).text('downloads'),
                  getDownloadsCountValue,
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
    AsyncValue<dynamic> countValue,
    VoidCallback onTap,
  ) {
    return countValue.when(
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
          data.toString(),
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
