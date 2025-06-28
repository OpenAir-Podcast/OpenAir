import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/categories_page.dart';
import 'package:openair/views/mobile/main_pages/featured_page.dart';
import 'package:openair/views/mobile/main_pages/trending_page.dart';
import 'package:openair/views/mobile/navigation/app_drawer.dart';
import 'package:openair/views/mobile/navigation/main_app_bar.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';

class MobileScaffold extends ConsumerWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: mainAppBar(ref, context),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            const FeaturedPage(),
            const TrendingPage(),
            CategoriesPage(),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
              ? 80.0
              : 0.0,
          child: ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
              ? const BannerAudioPlayer()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
