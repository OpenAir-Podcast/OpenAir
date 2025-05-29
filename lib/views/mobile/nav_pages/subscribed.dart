import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscription.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/subscription.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart'; // Corrected import path

final FutureProvider<Map<String, Subscription>> subscriptionsProvider =
    FutureProvider((ref) async {
  // Use ref.watch if you want this provider to rebuild when openAirProvider changes.
  final openAir = ref.watch(openAirProvider);
  return await openAir.getSubscriptions();
});

class Subscribed extends ConsumerStatefulWidget {
  const Subscribed({super.key});

  @override
  ConsumerState<Subscribed> createState() => _SubscribedState();
}

class _SubscribedState extends ConsumerState<Subscribed> with AutomaticKeepAliveClientMixin<Subscribed> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
    final AsyncValue<Map<String, Subscription>> getSubscriptionsValue = ref.watch(subscriptionsProvider);

    return getSubscriptionsValue.when(
      data: (Map<String, Subscription> data) {
        if (data.isEmpty) {
          return NoSubscription();
        }

        // Convert map values to a list for easier and more stable indexed access
        final List<Subscription> subs = data.values.toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Subscribed'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ),
            ],
          ),
          body: GridView.builder(
            itemCount: subs.length, // Use the length of the list
            cacheExtent: cacheExtent,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobileCrossAxisCount,
              mainAxisExtent: subscribedMobileMainAxisExtent,
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  cardSidePadding,
                  cardTopPadding,
                  cardSidePadding,
                  cardTopPadding,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Ensure the map structure for currentPodcast is consistent
                    // with what OpenAirProvider and EpisodesPage expect.
                    // The Subscription.toJson() method already provides 'url' and 'image' keys.
                    final podcastData = subs[index].toJson();
                    
                    // It's good practice to ensure the keys match what other parts of your app expect.
                    // If EpisodesPage or OpenAirProvider expects different keys, transform `podcastData` here.
                    // For example, if it expects 'feedUrl' instead of 'url':
                    // final Map<String, dynamic> podcastDataForProvider = { ...podcastData, 'feedUrl': subs[index].feedUrl };

                    ref.read(openAirProvider.notifier).currentPodcast = podcastData;

                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => EpisodesPage(
                              podcast: subs[index].toJson(),
                              id: subs[index].id,
                            ),
                          ),
                        )
                        .whenComplete(
                          () {
                            // No need to call setState here if the state is managed by Riverpod
                            // and subscriptionsProvider is watching openAirProvider.
                          },
                        );
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: cardImageShadow,
                              blurRadius: blurRadius,
                            )
                          ],
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: CachedNetworkImageProvider(
                              subs[index].imageUrl,
                            ),
                          ),
                        ),
                        height: cardImageHeight,
                        width: cardImageWidth,
                      ),
                      Container(
                        height: cardLabelHeight,
                        width: cardLabelWidth,
                        decoration: BoxDecoration(
                          color: cardLabelBackground,
                          boxShadow: [
                            BoxShadow(
                              color: cardLabelShadow,
                              blurRadius: blurRadius,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(cardLabelPadding),
                          child: Text(
                            subs[index].title,
                            maxLines: cardLabelMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cardLabelTextColor,
                              fontSize: cardLabelFontSize,
                              fontWeight: cardLabelFontWeight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('Error loading subscriptions: $error\n$stackTrace');
        return const NoConnection(); // Or a more specific error widget
      },
      loading: () => Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
