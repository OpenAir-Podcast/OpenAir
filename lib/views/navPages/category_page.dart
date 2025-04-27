import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/api_service_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/widgets/discover_card.dart';

class CategoryPage extends ConsumerWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Run once to initialize the provider
    ref.read(openAirProvider).selectedCategory = category;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: FutureBuilder(
        future: ref.watch(apiServiceProvider).getPodcastsByCategory(category),
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
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                if (index >= snapshot.data!.length) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return DiscoverCard(
                  podcastItem: snapshot.data![index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
