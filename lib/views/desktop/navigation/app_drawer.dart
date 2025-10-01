import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/desktop/nav_pages/add_podcast_page.dart';
import 'package:openair/views/desktop/nav_pages/downloads_page.dart';
import 'package:openair/views/desktop/nav_pages/favorites_page.dart';
import 'package:openair/views/desktop/nav_pages/feeds_page.dart';
import 'package:openair/views/desktop/nav_pages/history_page.dart';
import 'package:openair/views/desktop/nav_pages/inbox_page.dart';
import 'package:openair/views/desktop/nav_pages/queue_page.dart';
import 'package:openair/views/desktop/nav_pages/settings_page.dart';
import 'package:openair/views/desktop/nav_pages/log_in_page.dart';
import 'package:openair/views/desktop/nav_pages/subscriptions_page.dart';

final subCountProvider = FutureProvider.autoDispose<String>((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  var episodes = await hiveService.getNewEpisodesCount();

  if (episodes != -1) {
    return episodes.toString();
  }

  // Watch hiveServiceProvider as subscription counts depend on Hive data
  return await ref.read(openAirProvider).getAccumulatedSubscriptionCount();
});

final feedCountProvider = FutureProvider.autoDispose<String>((ref) async {
  // Watch hiveServiceProvider as feed counts depend on Hive data
  return await ref.read(openAirProvider).getFeedsCount();
});

final inboxCountProvider = FutureProvider.autoDispose<int>((ref) async {
  return await ref.watch(openAirProvider).getInboxCount();
});

final queueCountProvider = FutureProvider.autoDispose<String>((ref) async {
  // Watch hiveServiceProvider as queue counts depend on Hive data
  return await ref.watch(openAirProvider).getQueueCount();
});

final downloadsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  // Watch hiveServiceProvider as queue counts depend on Hive data
  return await ref.watch(openAirProvider).getDownloadsCount();
});

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({
    super.key,
  });

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<String> getSubCountValue = ref.watch(subCountProvider);
    final AsyncValue<String> getFeedsCountValue = ref.watch(feedCountProvider);
    final AsyncValue<int> getInboxCountValue = ref.watch(inboxCountProvider);
    final AsyncValue<String> getQueueCountValue = ref.watch(queueCountProvider);
    final AsyncValue<int> getDownloadsCountValue =
        ref.watch(downloadsCountProvider);

    double circleSize = 90.0;

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
                      'assets/images/openair-logo.png',
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
              children: [
                // Home button
                ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: Text(Translations.of(context).text('home')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/');
                  },
                ),
                const Divider(),
                // Subscribed button
                getSubCountValue.when(
                  loading: () {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title:
                          Text(Translations.of(context).text('subscriptions')),
                      trailing: const Text('...'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SubscriptionsPage()),
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title:
                          Text(Translations.of(context).text('subscriptions')),
                      trailing: ElevatedButton(
                        child: const Text('Retry'),
                        onPressed: () => ref.invalidate(subCountProvider),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SubscriptionsPage()),
                        );
                      },
                    );
                  },
                  data: (String data) {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title:
                          Text(Translations.of(context).text('subscriptions')),
                      trailing: Text(data),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SubscriptionsPage()),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                // Feeds button
                getFeedsCountValue.when(
                  loading: () {
                    return ListTile(
                      leading: const Icon(Icons.feed_rounded),
                      title: Text(Translations.of(context).text('feeds')),
                      trailing: const Text('...'),
                    );
                  },
                  error: (error, stackTrace) {
                    return ListTile(
                      leading: const Icon(Icons.feed_rounded),
                      title: Text(Translations.of(context).text('feeds')),
                      trailing: ElevatedButton(
                        child: const Text('Retry'),
                        onPressed: () => ref.invalidate(feedCountProvider),
                      ),
                    );
                  },
                  data: (String data) {
                    return ListTile(
                      leading: const Icon(Icons.feed_rounded),
                      title: Text(Translations.of(context).text('feeds')),
                      trailing: Text(data),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => FeedsPage()),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                // Inbox
                getInboxCountValue.when(
                  loading: () {
                    return ListTile(
                      leading: const Icon(Icons.inbox_rounded),
                      title: Text(Translations.of(context).text('inbox')),
                      trailing: const Text('...'),
                    );
                  },
                  error: (error, stackTrace) {
                    return ListTile(
                      leading: const Icon(Icons.inbox_rounded),
                      title: Text(Translations.of(context).text('inbox')),
                      trailing: ElevatedButton(
                        child: const Text('Retry'),
                        onPressed: () => ref.invalidate(inboxCountProvider),
                      ),
                    );
                  },
                  data: (int data) {
                    return ListTile(
                      leading: const Icon(Icons.inbox_rounded),
                      title: Text(Translations.of(context).text('inbox')),
                      trailing: Text('$data'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => InboxPage()),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                // Favourite
                ListTile(
                  leading: const Icon(Icons.favorite_rounded),
                  title: Text(Translations.of(context).text('favorites')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FavoritesPage()),
                    );
                  },
                ),

                const Divider(),
                // Queue button
                getQueueCountValue.when(
                  loading: () {
                    return ListTile(
                      leading: const Icon(Icons.queue_music_rounded),
                      title: Text(Translations.of(context).text('queue')),
                      trailing: const Text('...'),
                    );
                  },
                  error: (error, stackTrace) {
                    return ListTile(
                      leading: const Icon(Icons.queue_music_rounded),
                      title: Text(Translations.of(context).text('queue')),
                      trailing: ElevatedButton(
                        child: const Text('Retry'),
                        onPressed: () => ref.invalidate(queueCountProvider),
                      ),
                    );
                  },
                  data: (String data) {
                    return ListTile(
                      leading: const Icon(Icons.queue_music_rounded),
                      title: Text(Translations.of(context).text('queue')),
                      trailing: Text(data),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => QueuePage()),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                // Downloads button
                getDownloadsCountValue.when(
                  loading: () {
                    return ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: Text(Translations.of(context).text('downloads')),
                      trailing: const Text('...'),
                    );
                  },
                  error: (error, stackTrace) {
                    return ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: Text(Translations.of(context).text('downloads')),
                      trailing: ElevatedButton(
                        child: const Text('Retry'),
                        onPressed: () => ref.invalidate(queueCountProvider),
                      ),
                    );
                  },
                  data: (int data) {
                    return ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: Text(Translations.of(context).text('downloads')),
                      trailing: Text(data.toString()),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => DownloadsPage()),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                // History button
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: Text(Translations.of(context).text('history')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HistoryPage()),
                    );
                  },
                ),
                const Divider(),
                // Settings button
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: Text(Translations.of(context).text('addPodcast')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AddPodcastPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // Settings button
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: Text(Translations.of(context).text('settings')),
            onTap: () {
              // Navigator.pop(context);
              Navigator.of(context)
                  .push(
                MaterialPageRoute(builder: (context) => Settings()),
              )
                  .then(
                (value) {
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
