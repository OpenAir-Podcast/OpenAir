import 'dart:io';

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
import 'package:openair/views/navigation/list_drawer.dart';
import 'package:openair/views/widgets/wide_drawer.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  late Widget _content;
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies(); // Call super.didChangeDependencies() first
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

  void languageChanged() {
    if (_tabController.index == 0) {
      _tabController.animateTo(1);
      Future.delayed(const Duration(seconds: 1), () {
        _tabController.animateTo(0);
      });
    } else if (_tabController.index == 1) {
      _tabController.animateTo(0);
      Future.delayed(const Duration(seconds: 1), () {
        _tabController.animateTo(1);
      });
    } else if (_tabController.index == 2) {
      _tabController.animateTo(1);
      Future.delayed(const Duration(seconds: 1), () {
        _tabController.animateTo(2);
      });
    }
  }

  Widget _buildMainContent(Widget? drawer) {
    return Scaffold(
      drawer: drawer,
      key: ValueKey(_tabController.index),
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
                switch (_tabController.index) {
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
          controller: _tabController,
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
        controller: _tabController,
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((wideScreenMinWidth < MediaQuery.sizeOf(context).width &&
                Platform.isAndroid ||
            Platform.isIOS) ||
        (MediaQuery.sizeOf(context).width > 630.0 && Platform.isLinux ||
            Platform.isMacOS ||
            Platform.isWindows)) {
      return Row(
        children: [
          Expanded(
            flex: 2,
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
            flex: 5,
            child: _content,
          ),
        ],
      );
    }

    return _buildMainContent(ListDrawer(
      languageChanged: languageChanged,
    ));
  }
}
