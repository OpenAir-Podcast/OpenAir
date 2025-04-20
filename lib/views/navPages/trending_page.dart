import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/feed_model.dart';
import '../../providers/parses/podcast_provider.dart';
import '../../providers/podcast_provider.dart';
import '../widgets/discover_card.dart';

bool once = false;

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(feedFutureProvider.future),
        child: podcastRef.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: false,
          data: (List<FeedModel> data) {
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  if (index >= data.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return DiscoverCard(
                    podcastItem: data[index],
                  );
                });
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
      ),
    );
  }
}
