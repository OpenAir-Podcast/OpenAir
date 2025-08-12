import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/nav_pages/add_podcast_page.dart';
import 'package:openair/views/mobile/nav_pages/downloads_page.dart';
import 'package:openair/views/mobile/nav_pages/feeds_page.dart';
import 'package:openair/views/mobile/nav_pages/history_page.dart';
import 'package:openair/views/mobile/nav_pages/queue_page.dart';
import 'package:openair/views/mobile/nav_pages/settings_page.dart';
import 'package:openair/views/mobile/nav_pages/sign_in_page.dart';
import 'package:openair/views/mobile/nav_pages/subscriptions_page.dart';

final subCountProvider = FutureProvider.autoDispose<String>((ref) async {
  // Watch hiveServiceProvider as subscription counts depend on Hive data
  return await ref.read(openAirProvider).getAccumulatedSubscriptionCount();
});

final feedCountProvider = FutureProvider.autoDispose<String>((ref) async {
  // Watch hiveServiceProvider as feed counts depend on Hive data
  return await ref.read(openAirProvider).getFeedsCount();
});

final queueCountProvider = FutureProvider.autoDispose<String>((ref) async {
  // Watch hiveServiceProvider as queue counts depend on Hive data
  return await ref.read(openAirProvider).getQueueCount();
});

final downloadsCountProvider = FutureProvider.autoDispose<String>((ref) async {
  // Watch hiveServiceProvider as queue counts depend on Hive data
  return await ref.read(openAirProvider).getDownloadsCount();
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
    final AsyncValue<String> getQueueCountValue = ref.watch(queueCountProvider);
    final AsyncValue<String> getDownloadsCountValue =
        ref.watch(downloadsCountProvider);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // TODO: check if the user is logged in
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TODO: Replace with OpenAir logo
                        Icon(Icons.person_rounded, size: 80.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignIn(),
                              ),
                            );
                          },
                          child: Text(Translations.of(context).text('signIn')),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  data: (String data) {
                    return ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: Text(Translations.of(context).text('downloads')),
                      trailing: Text(data),
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
                      MaterialPageRoute(builder: (context) => AddPodcast()),
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
