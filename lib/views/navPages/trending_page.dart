import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/api_service_provider.dart';
import 'package:openair/views/widgets/discover_card.dart';

class TrendingPage extends ConsumerStatefulWidget {
  const TrendingPage({super.key});

  @override
  TrendingPageState createState() => TrendingPageState();
}

class TrendingPageState extends ConsumerState<TrendingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref.watch(apiServiceProvider).getTrendingPodcasts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              itemCount: snapshot.data!['count'],
              itemBuilder: (context, index) {
                return DiscoverCard(
                  podcastItem: snapshot.data!['feeds'][index],
                );
              },
            ),
          );
        });
  }
}
