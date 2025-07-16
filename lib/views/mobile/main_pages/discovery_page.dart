import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/views/mobile/nav_pages/add_podcast_page.dart';
import 'package:openair/views/mobile/widgets/discovery_podcast_card.dart';

final getConnectionStatusProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final apiService = ref.read(openAirProvider);
  return await apiService.getConnectionStatus();
});

class DiscoveryPage extends ConsumerStatefulWidget {
  final AsyncValue<List<dynamic>> podcastDataAsyncValue;
  const DiscoveryPage({super.key, required this.podcastDataAsyncValue});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  @override
  @override
  Widget build(BuildContext context) {
    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery'),
      ),
      body: getConnectionStatusValue.when(
        data: (connectionData) {
          if (connectionData == false) {
            return NoConnection();
          }

          return widget.podcastDataAsyncValue.when(
              loading: () => const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error: (error, stackTrace) => SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 75.0,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Oops, an error occurred...',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$error',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: 180.0,
                          height: 40.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () async {
                              ref.invalidate(podcastDataFeaturedProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    ),
                  ),
              data: (data) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    cacheExtent: cacheExtent,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return DiscoveryPodcastCard(
                        podcastItem: data[index],
                      );
                    },
                  ),
                );
              });
        },
        error: (error, stackTrace) => Scaffold(
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 75.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Oops, an error occurred...',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      '$error',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 180.0,
                  height: 40.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      ref.invalidate(getConnectionStatusProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
