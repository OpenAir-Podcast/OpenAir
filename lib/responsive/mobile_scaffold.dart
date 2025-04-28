import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/navPages/categories_page.dart';
import 'package:openair/views/navPages/featured_page.dart';
import 'package:openair/views/navPages/trending_page.dart';
import 'package:openair/views/navigation/app_drawer.dart';
import 'package:openair/views/navigation/main_app_bar.dart';
import 'package:openair/views/player/banner_audio_player.dart';

class MobileScaffold extends ConsumerWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: mainAppBar(ref),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            const FeaturedPage(),
            const TrendingPage(),
            CategoriesPage(),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: ref.watch(openAirProvider).isPodcastSelected ? 80.0 : 0.0,
          child: ref.watch(openAirProvider).isPodcastSelected
              ? const BannerAudioPlayer()
              : const SizedBox(),
        ),
      ),
    );
  }
}
