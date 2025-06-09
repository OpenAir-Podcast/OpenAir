import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/nav_pages/add_podcast.dart';
import 'package:openair/views/mobile/nav_pages/downloads.dart';
import 'package:openair/views/mobile/nav_pages/feeds_page.dart';
import 'package:openair/views/mobile/nav_pages/history.dart';
import 'package:openair/views/mobile/nav_pages/queue.dart';
import 'package:openair/views/mobile/nav_pages/settings.dart';
import 'package:openair/views/mobile/nav_pages/sign_in.dart';
import 'package:openair/views/mobile/nav_pages/subscriptions_page.dart';

final FutureProvider<String> subCountProvider = FutureProvider((ref) async {
  return await ref.watch(openAirProvider).getAccumulatedSubscriptionCount();
});

final FutureProvider<String> feedCountProvider = FutureProvider((ref) async {
  return await ref.watch(openAirProvider).getFeedsCount();
});

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<String> getSubCountValue = ref.watch(subCountProvider);
    final AsyncValue<String> getFeedsCountValue = ref.watch(feedCountProvider);

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
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/');
                  },
                ),
                // Subscribed button
                getSubCountValue.when(
                  loading: () {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title: const Text('Subscribed'),
                      trailing: const Text('...'),
                    );
                  },
                  error: (error, stackTrace) {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title: const Text('Subscribed'),
                      trailing: ElevatedButton(
                        child: const Text('Retry'),
                        onPressed: () => ref.invalidate(subCountProvider),
                      ),
                    );
                  },
                  data: (String data) {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title: const Text('Subscriptions'),
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
                // TODO Show the total number of episodes in total.
                // Feeds button
                getFeedsCountValue.when(
                  loading: () {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title: const Text('Feeds'),
                      trailing: const Text('...'),
                    );
                  },
                  error: (error, stackTrace) {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title: const Text('Feeds'),
                      trailing: ElevatedButton(
                        child: const Text('Feeds'),
                        onPressed: () => ref.invalidate(subCountProvider),
                      ),
                    );
                  },
                  data: (String data) {
                    return ListTile(
                      leading: const Icon(Icons.subscriptions_rounded),
                      title: const Text('Feeds'),
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
                ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: const Text('Queue'),
                  trailing: const Text('0'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Queue()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Downloads'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Downloads()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('History'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => History()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: const Text('Add podcast'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AddPodcast()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.more_horiz_rounded),
                  title: const Text('More options'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
          ),
        ],
      ),
    );
  }
}
