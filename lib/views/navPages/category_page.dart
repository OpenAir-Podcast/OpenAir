import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/api_service_provider.dart';
import 'package:openair/views/widgets/discover_card.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({
    super.key,
    required this.category,
  });

  final String category;

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref
          .watch(apiServiceProvider)
          .getPodcastsByCategory(widget.category.toLowerCase()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              itemCount: snapshot.data!['count'],
              itemBuilder: (context, index) {
                return DiscoverCard(
                  podcastItem: snapshot.data!['feeds'][index],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
