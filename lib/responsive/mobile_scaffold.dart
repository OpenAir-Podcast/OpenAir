import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_provider.dart';
import 'package:openair/views/navPages/featured_page.dart';
import 'package:openair/views/navPages/trending_page.dart';
import 'package:openair/views/navigation/app_drawer.dart';
import 'package:openair/views/navigation/main_app_bar.dart';

import '../views/navPages/categories_page.dart';

bool once = false;

class MobileScaffold extends ConsumerWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Run once to initialize the provider
    if (once == false) {
      // Initialize the provider
      ref.read(podcastProvider).initial(
            context,
          );
      once = true;
    }

    // final podcastRef = ref.watch(feedFutureProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: mainAppBar(ref),
        drawer: const AppDrawer(),
        // TODO: Redesign this
        // body: podcastRef.when(
        //   skipLoadingOnReload: true,
        //   skipLoadingOnRefresh: false,
        //   data: (List<FeedModel> data) {
        //     final pages = List<Widget>.unmodifiable([
        //       const HomePage(),
        //       const ExplorePage(),
        //       const LibraryPage(),
        //     ]);
        //
        //     return pages[ref.watch(podcastProvider).navIndex];
        //   },
        //   error: (error, stackTrace) {
        //     return Text(error.toString());
        //   },
        //   loading: () {
        //     return const Scaffold(
        //       body: Center(
        //         child: CircularProgressIndicator(),
        //       ),
        //     );
        //   },
        body: TabBarView(
          children: [
            const FeaturedPage(),
            TrendingPage(),
            CategoriesPage(),
          ],
        ),
      ),
    );
  }
}
