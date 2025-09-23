import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
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
import 'package:openair/views/desktop/nav_pages/log_in_page.dart';
import 'package:openair/views/desktop/nav_pages/queue_page.dart';
import 'package:openair/views/desktop/nav_pages/settings_page.dart';
import 'package:openair/views/desktop/nav_pages/subscriptions_page.dart';
import 'package:openair/views/desktop/player/banner_audio_player.dart';
import 'package:openair/views/desktop/navigation/app_drawer.dart';

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
              onPressed: () {
                // TODO Implement refresh mechanic
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
            elevation: 2.0,
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: _DesktopDrawer(onPageSelected: _handleNavigation),
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

class _DesktopDrawer extends ConsumerWidget {
  final Function(Widget) onPageSelected;

  const _DesktopDrawer({required this.onPageSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getSubCountValue = ref.watch(subCountProvider);
    final getFeedsCountValue = ref.watch(feedCountProvider);
    final getInboxCountValue = ref.watch(inboxCountProvider);
    final getQueueCountValue = ref.watch(queueCountProvider);
    final getDownloadsCountValue = ref.watch(downloadsCountProvider);

    double circleSize = 90.0;

    final supabaseService = ref.watch(supabaseServiceProvider);
    final session = supabaseService.client.auth.currentUser;

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
                    'assets/images/openair-logo.png',
                    width: circleSize,
                    height: circleSize,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    if (session == null) {
                      onPageSelected(const LogIn());
                    } else {
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
          flex: 4,
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: Text(Translations.of(context).text('home')),
                onTap: () {
                  onPageSelected(const Text('home'));
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
                    onPageSelected(SubscriptionsPage());
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
                    onPageSelected(FeedsPage());
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
                    onPageSelected(InboxPage());
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.favorite_rounded),
                title: Text(Translations.of(context).text('favorites')),
                onTap: () {
                  onPageSelected(FavoritesPage());
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
                    onPageSelected(QueuePage());
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
                    onPageSelected(DownloadsPage());
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: Text(Translations.of(context).text('history')),
                onTap: () {
                  onPageSelected(HistoryPage());
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_rounded),
                title: Text(Translations.of(context).text('addPodcast')),
                onTap: () {
                  onPageSelected(AddPodcastPage());
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
            onPageSelected(Settings());
          },
        ),
      ],
    );
  }
}
