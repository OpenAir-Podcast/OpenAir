import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';

import 'package:openair/views/main_pages/categories_page.dart';
import 'package:openair/views/main_pages/featured_page.dart';
import 'package:openair/views/main_pages/trending_page.dart';
import 'package:openair/views/nav_pages/add_podcast_page.dart';

import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/navigation/app_drawer.dart';
import 'package:openair/views/widgets/desktop_drawer.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  late Widget _content;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _content = _buildMainContent(null);
      _initialized = true;
    }
  }

  void _handleNavigation(Widget content) {
    setState(() {
      if (content is Text && content.data == 'home') {
        _content = _buildMainContent(null);
      } else {
        _content = content;
      }
    });
  }

  void rebuildDrawer() {
    setState(() {});
  }

  Widget _buildMainContent(Widget? drawer) {
    TabController tabController = TabController(length: 3, vsync: this);

    return Scaffold(
      drawer: drawer,
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
    if (MediaQuery.sizeOf(context).width > wideScreenMinWidth) {
      _buildMainContent(AppDrawer());
    }

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
            child: WideDrawer(
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
