import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/categories_page.dart';
import 'package:openair/views/mobile/main_pages/featured_page.dart';
import 'package:openair/views/mobile/main_pages/trending_page.dart';
import 'package:openair/views/mobile/navigation/app_drawer.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';

class MobileScaffold extends ConsumerStatefulWidget {
  const MobileScaffold({super.key});

  @override
  ConsumerState<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends ConsumerState<MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref.read(hiveServiceProvider).getSettings(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            String? currentRouteName = ModalRoute.of(context)?.settings.name;

            if (!onChanged) {
              onChanged = true;
              debugPrint('Current route: $currentRouteName');
              Translations.changeLanguage(
                asyncSnapshot.data!.locale,
              );
            }
          }

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
                        // TODO Implement refreash mechanic
                      },
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ),
                ],
                bottom: TabBar(
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
              drawer: const AppDrawer(),
              body: TabBarView(
                children: [
                  const FeaturedPage(),
                  const TrendingPage(),
                  CategoriesPage(),
                ],
              ),
              bottomNavigationBar: SizedBox(
                height: ref.watch(
                        openAirProvider.select((p) => p.isPodcastSelected))
                    ? 80.0
                    : 0.0,
                child: ref.watch(
                        openAirProvider.select((p) => p.isPodcastSelected))
                    ? const BannerAudioPlayer()
                    : const SizedBox.shrink(),
              ),
            ),
          );
        });
  }
}
