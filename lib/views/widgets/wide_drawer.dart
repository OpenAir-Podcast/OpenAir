import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/drawer_counts.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/nav_pages/add_podcast_page.dart';
import 'package:openair/views/nav_pages/downloads_page.dart';
import 'package:openair/views/nav_pages/favorites_page.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';
import 'package:openair/views/nav_pages/history_page.dart';
import 'package:openair/views/nav_pages/inbox_page.dart';
import 'package:openair/views/nav_pages/log_in_page.dart';
import 'package:openair/views/nav_pages/queue_page.dart';
import 'package:openair/views/nav_pages/settings_page.dart';
import 'package:openair/views/nav_pages/subscriptions_page.dart';
import 'package:openair/views/main_pages/featured_page.dart';
import 'package:openair/views/navigation/list_drawer.dart';

final getSessionProvider = FutureProvider.autoDispose((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.client.auth.currentUser;
});

class WideDrawer extends ConsumerStatefulWidget {
  final Function(Widget) onPageSelected;
  final Function() rebuildDrawer;

  const WideDrawer({
    super.key,
    required this.onPageSelected,
    required this.rebuildDrawer,
  });

  @override
  ConsumerState<WideDrawer> createState() => __WideDrawerState();
}

class __WideDrawerState extends ConsumerState<WideDrawer> {
  void returnFromSignin() {
    // todo continue from here... need to return the user to the main page after logging in.
    debugPrint('Returned from SignIn');
    // Navigator.of(context).pop();
    // widget.onPageSelected(const FeaturedPage());
    // ref.invalidate(getSessionProvider);
    // widget.rebuildDrawer();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);

    final drawerCounts = ref.watch(drawerCountsProvider);
    final session = ref.watch(getSessionProvider);
    final supabaseService = ref.watch(supabaseServiceProvider);

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Column(
                    spacing: 16.0,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/icons/icon.png',
                          width: circleSize,
                          height: circleSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      session.when(
                        data: (data) {
                          return ElevatedButton(
                            onPressed: () {
                              if (session.value == null) {
                                widget.onPageSelected(LogIn());
                              } else {
                                supabaseService.signOut();
                                ref.invalidate(getSessionProvider);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(
                              session.value == null
                                  ? Translations.of(context).text('signIn')
                                  : Translations.of(context).text('logout'),
                            ),
                          );
                        },
                        error: (error, stackTrace) => Text(
                          Translations.of(context).text('errorLoadingData'),
                        ),
                        loading: () => const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: Text(Translations.of(context).text('home')),
                onTap: () {
                  widget.onPageSelected(const FeaturedPage());
                },
              ),
              const Divider(),
              _buildDrawerCountTile(
                drawerCounts,
                Icons.subscriptions_rounded,
                Translations.of(context).text('subscriptions'),
                (c) => c.subscriptions,
                () => widget.onPageSelected(SubscriptionsPage()),
                onRetry: () => ref.invalidate(subCountProvider),
              ),
              const Divider(),
              _buildDrawerCountTile(
                drawerCounts,
                Icons.feed_rounded,
                Translations.of(context).text('feeds'),
                (c) => c.feeds,
                () {
                  ref.invalidate(getSubscribedEpisodesProvider);
                  widget.onPageSelected(FeedsPage());
                },
                onRetry: () => ref.invalidate(feedCountProvider),
              ),
              const Divider(),
              _buildDrawerCountTile(
                drawerCounts,
                Icons.inbox_rounded,
                Translations.of(context).text('inbox'),
                (c) => c.inbox,
                () => widget.onPageSelected(InboxPage()),
                onRetry: () => ref.invalidate(inboxCountProvider),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                ),
                title: Text(Translations.of(context).text('favorites')),
                onTap: () {
                  widget.onPageSelected(FavoritesPage());
                },
              ),
              const Divider(),
              _buildDrawerCountTile(
                drawerCounts,
                Icons.queue_music_rounded,
                Translations.of(context).text('queue'),
                (c) => c.queue,
                () {
                  ref.invalidate(sortedProvider);
                  widget.onPageSelected(QueuePage());
                },
                onRetry: () => ref.invalidate(queueCountProvider),
              ),
              const Divider(),
              _buildDrawerCountTile(
                drawerCounts,
                Icons.download_rounded,
                Translations.of(context).text('downloads'),
                (c) => c.downloads,
                () => widget.onPageSelected(DownloadsPage()),
                onRetry: () => ref.invalidate(downloadsCountProvider),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: Text(Translations.of(context).text('history')),
                onTap: () {
                  widget.onPageSelected(HistoryPage());
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_rounded),
                title: Text(Translations.of(context).text('addPodcast')),
                onTap: () {
                  widget.onPageSelected(AddPodcastPage());
                },
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings_rounded),
          title: Text(Translations.of(context).text('settings')),
          onTap: () {
            widget.onPageSelected(
              Settings(
                functionBuild: () {
                  widget.rebuildDrawer();
                  setState(() {});
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawerCountTile(
    AsyncValue<DrawerCounts> counts,
    IconData icon,
    String title,
    String Function(DrawerCounts) selector,
    VoidCallback onTap, {
    VoidCallback? onRetry,
  }) {
    return counts.when(
      loading: () => ListTile(
        leading: Icon(icon),
        title: Text(title,
            style: const TextStyle(overflow: TextOverflow.ellipsis)),
        trailing: const Text('...'),
      ),
      error: (_, __) => ListTile(
        leading: Icon(icon),
        title: Text(title,
            style: const TextStyle(overflow: TextOverflow.ellipsis)),
        trailing: onRetry != null
            ? ElevatedButton(onPressed: onRetry, child: const Text('Retry'))
            : const Icon(Icons.error_outline),
        onTap: onRetry,
      ),
      data: (data) => ListTile(
        leading: Icon(icon),
        title: Text(title,
            style: const TextStyle(overflow: TextOverflow.ellipsis)),
        trailing: Text(selector(data)),
        onTap: onTap,
      ),
    );
  }
}
