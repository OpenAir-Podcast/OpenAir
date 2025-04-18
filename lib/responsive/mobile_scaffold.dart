import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/models/feed_model.dart';
import 'package:openair/providers/parses/feed_future_provider.dart';
import 'package:openair/providers/podcast_provider.dart';
import 'package:openair/views/navPages/explore_page.dart';
import 'package:openair/views/navPages/home_page.dart';
import 'package:openair/views/navPages/library_page.dart';
import 'package:openair/views/navigation/app_bar.dart';
import 'package:openair/views/navigation/app_drawer.dart';

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

    final podcastRef = ref.watch(feedFutureProvider);

    return Scaffold(
      appBar: appBar(ref),
      drawer: const AppDrawer(),
      // TODO: Redesign this
      body: podcastRef.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: false,
        data: (List<FeedModel> data) {
          final pages = List<Widget>.unmodifiable([
            const HomePage(),
            const ExplorePage(),
            const LibraryPage(),
          ]);

          return pages[ref.watch(podcastProvider).navIndex];
        },
        error: (error, stackTrace) {
          return Text(error.toString());
        },
        loading: () {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
