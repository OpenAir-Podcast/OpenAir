import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/mobile/main_pages/categories_page.dart';
import 'package:openair/views/mobile/main_pages/featured_page.dart';
import 'package:openair/views/mobile/main_pages/trending_page.dart';
import 'package:openair/views/mobile/nav_pages/add_podcast_page.dart';
import 'package:openair/views/mobile/navigation/app_drawer.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';

class MobileScaffold extends ConsumerStatefulWidget {
  const MobileScaffold({super.key});

  @override
  ConsumerState<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends ConsumerState<MobileScaffold>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController? tabController = TabController(length: 3, vsync: this);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                tooltip: Translations.of(context).text('refresh'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPodcastPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                tooltip: Translations.of(context).text('refresh'),
                onPressed: () {
                  // TODO Implement refreash mechanic
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
          ],
          bottom: TabBar(
            controller: tabController,
            tabs: [
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
        drawer: AppDrawer(),
        onDrawerChanged: (isOpened) {
          if (!isOpened && !onChanged) {
            int currentIndex = tabController.index;
            const int durationTime = 1000;

            switch (currentIndex) {
              case 0:
                tabController.index = 1;
                // tabController.animateTo(1);
                Future.delayed(
                  const Duration(milliseconds: durationTime),
                  () {
                    tabController.index = 0;
                    // tabController.animateTo(0);
                  },
                );

                break;
              case 1:
                tabController.index = 2;
                // tabController.animateTo(2);
                Future.delayed(
                  const Duration(milliseconds: durationTime),
                  () {
                    tabController.index = 1;
                    // tabController.animateTo(1);
                  },
                );
                break;
              case 2:
                tabController.index = 0;
                // tabController.animateTo(0);
                Future.delayed(
                  const Duration(milliseconds: durationTime),
                  () {
                    tabController.index = 2;
                    // tabController.animateTo(2);
                  },
                );
                break;
            }

            onChanged = true;
          }
        },
        body: TabBarView(
          controller: tabController,
          children: [
            const FeaturedPage(),
            const TrendingPage(),
            const CategoriesPage(),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
              ? 80.0
              : 0.0,
          child: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
              ? const BannerAudioPlayer()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
