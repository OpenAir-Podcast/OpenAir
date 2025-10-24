import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/nav_pages/add_podcast_page.dart';
import 'package:openair/views/nav_pages/downloads_page.dart';
import 'package:openair/views/nav_pages/favorites_page.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';
import 'package:openair/views/nav_pages/history_page.dart';
import 'package:openair/views/nav_pages/inbox_page.dart';
import 'package:openair/views/nav_pages/queue_page.dart';
import 'package:openair/views/nav_pages/settings_page.dart';
import 'package:openair/views/nav_pages/sign_in_page.dart';
import 'package:openair/views/nav_pages/subscriptions_page.dart';
import 'package:openair/views/navigation/narrow_drawer.dart';

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
    widget.onPageSelected(const Text('home'));
    ref.invalidate(getSessionProvider);
    widget.rebuildDrawer();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);

    final getSubCountValue = ref.watch(subCountProvider);
    final getFeedsCountValue = ref.watch(feedCountProvider);
    final getInboxCountValue = ref.watch(inboxCountProvider);
    final getQueueCountValue = ref.watch(queueCountProvider);
    final getDownloadsCountValue = ref.watch(downloadsCountProvider);

    final session = ref.watch(getSessionProvider);
    final supabaseService = ref.watch(supabaseServiceProvider);

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: DrawerHeader(
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
                            widget.onPageSelected(SignIn(
                              returnFromSignin: returnFromSignin,
                            ));
                          } else {
                            supabaseService.signOut();
                            ref.invalidate(getSessionProvider);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
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
        ),
        Expanded(
          flex: 4,
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: Text(Translations.of(context).text('home')),
                onTap: () {
                  widget.onPageSelected(Text('home'));
                },
              ),
              const Divider(),
              getSubCountValue.when(
                loading: () => ListTile(
                  leading: const Icon(Icons.subscriptions_rounded),
                  title: Text(Translations.of(context).text('subscriptions')),
                  trailing: const Text('...'),
                ),
                error: (error, stackTrace) => ListTile(
                  leading: const Icon(Icons.subscriptions_rounded),
                  title: Text(Translations.of(context).text('subscriptions')),
                  trailing: ElevatedButton(
                    child: const Text('Retry'),
                    onPressed: () => ref.invalidate(subCountProvider),
                  ),
                ),
                data: (data) => ListTile(
                  leading: const Icon(Icons.subscriptions_rounded),
                  title: Text(Translations.of(context).text('subscriptions')),
                  trailing: Text(data),
                  onTap: () {
                    widget.onPageSelected(SubscriptionsPage());
                  },
                ),
              ),
              const Divider(),
              getFeedsCountValue.when(
                loading: () => ListTile(
                  leading: const Icon(Icons.feed_rounded),
                  title: Text(Translations.of(context).text('feeds')),
                  trailing: const Text('...'),
                ),
                error: (error, stackTrace) => ListTile(
                  leading: const Icon(Icons.feed_rounded),
                  title: Text(Translations.of(context).text('feeds')),
                  trailing: ElevatedButton(
                    child: const Text('Retry'),
                    onPressed: () => ref.invalidate(feedCountProvider),
                  ),
                ),
                data: (data) => ListTile(
                  leading: const Icon(Icons.feed_rounded),
                  title: Text(Translations.of(context).text('feeds')),
                  trailing: Text(data),
                  onTap: () {
                    ref.invalidate(feedCountProvider);
                    ref.invalidate(getFeedsProvider);
                    widget.onPageSelected(FeedsPage());
                  },
                ),
              ),
              const Divider(),
              getInboxCountValue.when(
                loading: () => ListTile(
                  leading: const Icon(Icons.inbox_rounded),
                  title: Text(Translations.of(context).text('inbox')),
                  trailing: const Text('...'),
                ),
                error: (error, stackTrace) => ListTile(
                  leading: const Icon(Icons.inbox_rounded),
                  title: Text(Translations.of(context).text('inbox')),
                  trailing: ElevatedButton(
                    child: const Text('Retry'),
                    onPressed: () => ref.invalidate(inboxCountProvider),
                  ),
                ),
                data: (data) => ListTile(
                  leading: const Icon(Icons.inbox_rounded),
                  title: Text(Translations.of(context).text('inbox')),
                  trailing: Text('$data'),
                  onTap: () {
                    widget.onPageSelected(InboxPage());
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.favorite_rounded),
                title: Text(Translations.of(context).text('favorites')),
                onTap: () {
                  widget.onPageSelected(FavoritesPage());
                },
              ),
              const Divider(),
              getQueueCountValue.when(
                loading: () => ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: Text(Translations.of(context).text('queue')),
                  trailing: const Text('...'),
                ),
                error: (error, stackTrace) => ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: Text(Translations.of(context).text('queue')),
                  trailing: ElevatedButton(
                    child: const Text('Retry'),
                    onPressed: () => ref.invalidate(queueCountProvider),
                  ),
                ),
                data: (data) => ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: Text(Translations.of(context).text('queue')),
                  trailing: Text(data),
                  onTap: () {
                    ref.invalidate(queueCountProvider);
                    ref.invalidate(sortedProvider);
                    widget.onPageSelected(QueuePage());
                  },
                ),
              ),
              const Divider(),
              getDownloadsCountValue.when(
                loading: () => ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: Text(Translations.of(context).text('downloads')),
                  trailing: const Text('...'),
                ),
                error: (error, stackTrace) => ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: Text(Translations.of(context).text('downloads')),
                  trailing: ElevatedButton(
                    child: const Text('Retry'),
                    onPressed: () => ref.invalidate(downloadsCountProvider),
                  ),
                ),
                data: (data) => ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: Text(Translations.of(context).text('downloads')),
                  trailing: Text(data.toString()),
                  onTap: () {
                    widget.onPageSelected(DownloadsPage());
                  },
                ),
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
              Settings(functionBuild: widget.rebuildDrawer),
            );
          },
        ),
      ],
    );
  }
}
