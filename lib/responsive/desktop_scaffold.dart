import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/desktop/main_pages/categories_page.dart';
import 'package:openair/views/desktop/main_pages/featured_page.dart';
import 'package:openair/views/desktop/main_pages/trending_page.dart';
import 'package:openair/views/desktop/nav_pages/add_podcast_page.dart';
import 'package:openair/views/desktop/nav_pages/downloads_page.dart';
import 'package:openair/views/desktop/nav_pages/favorites_page.dart';
import 'package:openair/views/desktop/nav_pages/feeds_page.dart';
import 'package:openair/views/desktop/nav_pages/history_page.dart';
import 'package:openair/views/desktop/nav_pages/inbox_page.dart';
import 'package:openair/views/desktop/nav_pages/sign_in_page.dart';
import 'package:openair/views/desktop/nav_pages/queue_page.dart';
import 'package:openair/views/desktop/nav_pages/settings_page.dart';
import 'package:openair/views/desktop/nav_pages/subscriptions_page.dart';
import 'package:openair/views/desktop/player/banner_audio_player.dart';
import 'package:openair/views/mobile/navigation/app_drawer.dart';

class DesktopScaffold extends ConsumerStatefulWidget {
  const DesktopScaffold({super.key});

  @override
  ConsumerState<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends ConsumerState<DesktopScaffold>
    with TickerProviderStateMixin {
  late Widget _content;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _content = _buildMainContent();
      _initialized = true;
    }
  }

  void _handleNavigation(Widget content) {
    setState(() {
      if (content is Text && content.data == 'home') {
        _content = _buildMainContent();
      } else {
        _content = content;
      }
    });
  }

  void rebuildDrawer() {
    setState(() {});
  }

  Widget _buildMainContent() {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        shadowColor: Colors.grey,
        title: Text(
          Translations.of(context).text('openAir'),
          textAlign: TextAlign.left,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              tooltip: Translations.of(context).text('search'),
              onPressed: () {
                _handleNavigation(const AddPodcastPage());
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              tooltip: Translations.of(context).text('refresh'),
              onPressed: () async {
                switch (tabController.index) {
                  case 0:
                    await ref
                        .watch(hiveServiceProvider)
                        .removeAllFeaturedPodcasts();
                    ref.invalidate(podcastDataByTopProvider);
                    ref.invalidate(podcastDataByEducationProvider);
                    ref.invalidate(podcastDataByHealthProvider);
                    ref.invalidate(podcastDataByTechnologyProvider);
                    ref.invalidate(podcastDataBySportsProvider);
                    break;
                  case 1:
                    await ref
                        .watch(hiveServiceProvider)
                        .removeAllTrendingPodcast();
                    ref.invalidate(podcastDataByTrendingProvider);
                    break;
                }

                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.home_rounded),
            ),
            Tab(
              icon: Icon(Icons.trending_up_rounded),
            ),
            Tab(
              icon: Icon(Icons.category_rounded),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          FeaturedPage(),
          TrendingPage(),
          CategoriesPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
            ? bannerAudioPlayerHeight
            : 0.0,
        child: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
            ? const BannerAudioPlayer()
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Card(
            color: Theme.of(context).cardColor,
            elevation: 2.0,
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: _DesktopDrawer(
              onPageSelected: _handleNavigation,
              rebuildDrawer: rebuildDrawer,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: _content,
        ),
      ],
    );
  }
}

final getSessionProvider = FutureProvider.autoDispose((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.client.auth.currentUser;
});

class _DesktopDrawer extends ConsumerStatefulWidget {
  final Function(Widget) onPageSelected;
  final Function() rebuildDrawer;

  const _DesktopDrawer({
    required this.onPageSelected,
    required this.rebuildDrawer,
  });

  @override
  ConsumerState<_DesktopDrawer> createState() => __DesktopDrawerState();
}

class __DesktopDrawerState extends ConsumerState<_DesktopDrawer> {
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

    double circleSize = 90.0;

    return Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/icons/icon.png',
                    width: circleSize,
                    height: circleSize,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8.0),
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
            widget.onPageSelected(Settings(
              rebuildDrawer: widget.rebuildDrawer,
            ));
          },
        ),
      ],
    );
  }
}
