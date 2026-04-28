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
  late TabController _tabController;
  String _pageTitle = 'openAir';

  static const _titles = ['openAir', 'trending', 'categories'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _pageTitle = _titles[_tabController.index];
      });
    }
  }

  void _onPageSelected(Widget page) {
    // Check if it's a tab page
    if (page is FeaturedPage) {
      _tabController.animateTo(0);
    } else if (page is TrendingPage) {
      _tabController.animateTo(1);
    } else if (page is CategoriesPage) {
      _tabController.animateTo(2);
    } else {
      // Non-tab page - navigate normally
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
      return;
    }
    setState(() {});
  }

  void _rebuildDrawer() {
    setState(() {});
  }

  String _getTitle() {
    if (_pageTitle == 'openAir') {
      return Translations.of(context).text('openAir');
    }
    return Translations.of(context).text(_pageTitle);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = _isWideScreen(context);
    final isPodcastPlaying =
        ref.watch(audioProvider.select((p) => p.isPodcastSelected));

    return isWideScreen
        ? _buildWideLayout()
        : _buildNormalLayout(isPodcastPlaying);
  }

  bool _isWideScreen(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (Platform.isAndroid || Platform.isIOS) {
      return width >= wideScreenMinWidth;
    }
    return width > 630.0 ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isWindows;
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Card(
            color: Theme.of(context).cardColor,
            elevation: 2.0,
            margin: EdgeInsets.zero,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: WideDrawer(
              onPageSelected: _onPageSelected,
              rebuildDrawer: _rebuildDrawer,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Scaffold(
            appBar: AppBar(
              elevation: 4.0,
              shadowColor: Colors.grey,
              title: Text(_getTitle()),
              actions: [
                IconButton(
                  tooltip: Translations.of(context).text('search'),
                  onPressed: () => _navigateToSearch(),
                  icon: const Icon(Icons.search_rounded),
                ),
                IconButton(
                  tooltip: Translations.of(context).text('refresh'),
                  onPressed: () => _onRefresh(),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.home_rounded)),
                  Tab(icon: Icon(Icons.trending_up_rounded)),
                  Tab(icon: Icon(Icons.category_rounded)),
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
            drawer: null,
          ),
        ),
      ],
    );
  }

  Widget _buildNormalLayout(bool isPodcastPlaying) {
    return _buildMainContent(
      ListDrawer(languageChanged: () {}),
    );
  }

  Widget _buildMainContent(Widget? drawer) {
    final isPodcastPlaying =
        ref.watch(audioProvider.select((p) => p.isPodcastSelected));

    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        elevation: 4.0,
        shadowColor: Colors.grey,
        title: Text(_getTitle()),
        actions: [
          IconButton(
            tooltip: Translations.of(context).text('search'),
            onPressed: () => _navigateToSearch(),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: Translations.of(context).text('refresh'),
            onPressed: () => _onRefresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home_rounded)),
            Tab(icon: Icon(Icons.trending_up_rounded)),
            Tab(icon: Icon(Icons.category_rounded)),
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
        height: isPodcastPlaying ? bannerAudioPlayerHeight : 0.0,
        child: isPodcastPlaying
            ? const BannerAudioPlayer()
            : const SizedBox.shrink(),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPodcastPage()),
    );
  }

  void _onRefresh() async {
    final hiveService = ref.read(hiveServiceProvider);

    switch (_tabController.index) {
      case 0:
        await hiveService.removeAllFeaturedPodcasts();
        break;
      case 1:
        await hiveService.removeAllTrendingPodcast();
        ref.invalidate(trendingDataProvider);
        break;
    }

    setState(() {});
  }
}
