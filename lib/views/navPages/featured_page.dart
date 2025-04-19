import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeaturedPage extends ConsumerWidget {
  const FeaturedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 10.0, 4.0, 4.0),
      child: ListView(
        children: [
          Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Text('Top Podcasts'),
                  trailing: const Text('See All'),
                  onTap: () {
                    debugPrint('See All - Top Podcasts');
                  },
                ),
                SizedBox(
                  height: 200.0,
                  width: double.infinity,
                  child: GridView.builder(
                    itemCount: 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 180.0,
                      // crossAxisSpacing: 5.0,
                      // mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        color: Colors.blue,
                        height: 170.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Text('Eduction'),
                  trailing: const Text('See All'),
                  onTap: () {
                    debugPrint('See All - Education');
                  },
                ),
                SizedBox(
                  height: 200.0,
                  width: double.infinity,
                  child: GridView.builder(
                    itemCount: 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 180.0,
                      // crossAxisSpacing: 5.0,
                      // mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        color: Colors.blue,
                        height: 170.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Text('Health & Fitness'),
                  trailing: const Text('See All'),
                  onTap: () {
                    debugPrint('See All - Health & Fitness');
                  },
                ),
                SizedBox(
                  height: 200.0,
                  width: double.infinity,
                  child: GridView.builder(
                    itemCount: 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 180.0,
                      // crossAxisSpacing: 5.0,
                      // mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        color: Colors.blue,
                        height: 170.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Text('Technology'),
                  trailing: const Text('See All'),
                  onTap: () {
                    debugPrint('See All - Technology');
                  },
                ),
                SizedBox(
                  height: 200.0,
                  width: double.infinity,
                  child: GridView.builder(
                    itemCount: 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 180.0,
                      // crossAxisSpacing: 5.0,
                      // mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        color: Colors.blue,
                        height: 170.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Text('Sports'),
                  trailing: const Text('See All'),
                  onTap: () {
                    debugPrint('See All');
                  },
                ),
                SizedBox(
                  height: 200.0,
                  width: double.infinity,
                  child: GridView.builder(
                    itemCount: 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 180.0,
                      // crossAxisSpacing: 5.0,
                      // mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        color: Colors.blue,
                        height: 170.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
