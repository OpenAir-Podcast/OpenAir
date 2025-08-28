import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/main_pages/discovery_page.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';
import 'package:openair/views/mobile/main_pages/fyyd_search_page.dart';
import 'package:openair/views/mobile/main_pages/podcast_index_search_page.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/loading_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

final podcastDataFeaturedProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.read(fyydProvider);
  return await apiService.getFeaturedPodcasts();
});

class AddPodcastPage extends ConsumerStatefulWidget {
  const AddPodcastPage({super.key});

  @override
  ConsumerState createState() => _AddPodcastPageState();
}

class _AddPodcastPageState extends ConsumerState<AddPodcastPage> {
  TextEditingController textInputControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final podcastDataAsyncValue = ref.watch(podcastDataFeaturedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('addPodcast')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              maxLength: 256,
              controller: textInputControl,
              keyboardType: TextInputType.webSearch,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                icon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelText: Translations.of(context).text('searchPodcastFyyd'),
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      textInputControl.text = '';
                      textInputControl.clear();
                    });
                  },
                  icon: Icon(Icons.clear_rounded),
                ),
              ),
              autofocus: true,
              onSubmitted: (value) async {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => LoadingDialog(),
                );

                try {
                  List podcasts =
                      await ref.read(fyydProvider).searchPodcasts(value);

                  if (podcasts.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              Translations.of(context).text('noPodcastsFound')),
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      Navigator.pop(context);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FyydSearchPage(
                            podcasts: podcasts,
                            searchWord: value,
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  debugPrint('Failed to find podcasts: $e');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          Translations.of(context).text('failedToFindPodcasts'),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            SizedBox(height: 15),
            podcastDataAsyncValue.when(
              loading: () {
                return SizedBox(
                  height: 336,
                  child: GridView.builder(
                    itemCount: 12,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisExtent: 100.0,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Theme.of(context).cardColor,
                        highlightColor: highlightColor!,
                        child: Container(
                          color: highlightColor,
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, stackTrace) {
                debugPrint('$error');

                return Center(
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
                        Translations.of(context).text('oopsAnErrorOccurred'),
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Translations.of(context).text('oopsTryAgainLater'),
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
                          child: Text(
                            Translations.of(context).text('retry'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              data: (snapshot) {
                return Column(
                  children: [
                    SizedBox(
                      height: 336,
                      child: GridView.builder(
                        itemCount: 12,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisExtent: 100.0,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              final xmlString = await ref
                                  .watch(fyydProvider)
                                  .getPodcastXml(snapshot[index]['xmlURL']);

                              var rssFeed = RssFeed.parse(xmlString);

                              SubscriptionModel podcast = SubscriptionModel(
                                id: snapshot[index]['id'],
                                feedUrl: snapshot[index]['xmlURL'],
                                title: rssFeed.title!,
                                description: rssFeed.description!,
                                author: rssFeed.author ?? 'unkown',
                                imageUrl: snapshot[index]['imgURL'],
                                episodeCount: rssFeed.items!.length,
                                artwork: snapshot[index]['imgURL'],
                              );

                              ref.read(auidoProvider).currentPodcast =
                                  PodcastModel.fromJson(podcast.toJson());

                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EpisodesPage(
                                        podcast: PodcastModel.fromJson(
                                            podcast.toJson())),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: cardImageShadow,
                                    blurRadius: blurRadius,
                                  )
                                ],
                              ),
                              height: cardImageHeight,
                              width: cardImageWidth,
                              child: CachedNetworkImage(
                                memCacheHeight: cardImageHeight.ceil(),
                                memCacheWidth: cardImageWidth.ceil(),
                                imageUrl: snapshot[index]['imgURL'],
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 120.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            Row(
              children: [
                Text(
                  Translations.of(context).text('discoveryPoweredByFyyd'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Translations.of(context).text('discoverMore'),
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.blue,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscoveryPage(
                          podcastDataAsyncValue: podcastDataAsyncValue),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            ListTile(
              leading: Icon(
                Icons.rss_feed_rounded,
                size: 36.0,
              ),
              title: Text(
                Translations.of(context).text('addPodcastByRssUrl'),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () => showDialog(
                context: context,
                builder: (context) {
                  TextEditingController textInputControl =
                      TextEditingController();

                  return AlertDialog(
                    title: Text(
                      Translations.of(context).text('addPodcastByRssUrl'),
                      textAlign: TextAlign.start,
                    ),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextField(
                        maxLength: 256,
                        autofocus: true,
                        controller: textInputControl,
                        keyboardType: TextInputType.url,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.link_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          labelText: Translations.of(context).text('rssUrl'),
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                textInputControl.text = '';
                                textInputControl.clear();
                              });
                            },
                            icon: Icon(Icons.clear_rounded),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            Translations.of(context).text('cancel'),
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            if (textInputControl.text.isEmpty) {
                              return;
                            }

                            bool i = await ref
                                .watch(auidoProvider)
                                .addPodcastByRssUrl(textInputControl.text);

                            if (context.mounted) {
                              if (i == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      Translations.of(context)
                                          .text('subscribed'),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      Translations.of(context)
                                          .text('errorAddingPodcast'),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            Translations.of(context).text('add'),
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.search_rounded,
                size: 36.0,
              ),
              title: Text(
                Translations.of(context).text('searchPodcastIndex'),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () => showDialog(
                context: context,
                builder: (context) {
                  TextEditingController textInputControl =
                      TextEditingController();

                  return AlertDialog(
                    title: Text(
                      Translations.of(context).text('searchPodcastIndex'),
                      textAlign: TextAlign.start,
                    ),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextField(
                        maxLength: 256,
                        autofocus: true,
                        controller: textInputControl,
                        keyboardType: TextInputType.url,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.title_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          labelText: Translations.of(context).text('title'),
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                textInputControl.text = '';
                                textInputControl.clear();
                              });
                            },
                            icon: Icon(Icons.clear_rounded),
                          ),
                        ),
                        onSubmitted: (value) async {
                          // Navigator.pop(context);

                          if (textInputControl.text.isEmpty) {
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) => LoadingDialog(),
                          );

                          final podcast = await ref
                              .watch(podcastIndexProvider)
                              .searchPodcasts(textInputControl.text);

                          FetchDataModel podcasts =
                              FetchDataModel.fromJson(podcast);

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PodcastIndexSearchPage(
                                  podcasts: podcasts,
                                  searchWord: textInputControl.text,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            Translations.of(context).text('cancel'),
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () async {
                            // Navigator.pop(context);

                            if (textInputControl.text.isEmpty) {
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) =>
                                  LoadingDialog(),
                            );

                            final podcast = await ref
                                .watch(podcastIndexProvider)
                                .searchPodcasts(textInputControl.text);

                            FetchDataModel podcasts =
                                FetchDataModel.fromJson(podcast);

                            if (context.mounted) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PodcastIndexSearchPage(
                                    podcasts: podcasts,
                                    searchWord: textInputControl.text,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            Translations.of(context).text('search'),
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.file_download_outlined,
                size: 36.0,
              ),
              title: Text(
                Translations.of(context).text('importPodcastListOpml'),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () async {
                bool i = await ref.watch(auidoProvider).importPodcastFromOpml();

                if (context.mounted) {
                  if (i == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          Translations.of(context)
                              .text('importedPodcastsFromOpml'),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(auidoProvider.select((p) => p.isPodcastSelected))
            ? 80.0
            : 0.0,
        child: ref.watch(auidoProvider.select((p) => p.isPodcastSelected))
            ? const BannerAudioPlayer()
            : const SizedBox.shrink(),
      ),
    );
  }
}
