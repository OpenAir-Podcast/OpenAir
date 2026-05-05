import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/fetch_data_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/main_pages/discovery_page.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/main_pages/fyyd_search_page.dart';
import 'package:openair/views/main_pages/podcast_index_search_page.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/widgets/loading_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

final podcastDataFeaturedProvider = FutureProvider<List<dynamic>>((ref) async {
  final podcastIndexService = ref.read(fyydProvider);
  return await podcastIndexService.getFeaturedPodcasts();
});

class AddPodcastPage extends ConsumerStatefulWidget {
  const AddPodcastPage({super.key});

  @override
  ConsumerState createState() => _AddPodcastPageState();
}

class _AddPodcastPageState extends ConsumerState<AddPodcastPage> {
  TextEditingController textInputControl = TextEditingController();

  @override
  void dispose() {
    textInputControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastDataAsyncValue = ref.watch(podcastDataFeaturedProvider);
    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('addPodcast')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                maxLength: 256,
                controller: textInputControl,
                keyboardType: TextInputType.webSearch,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                        if (!Platform.isAndroid && !Platform.isIOS) {
                          ref
                              .read(notificationServiceProvider)
                              .showNotification(
                                'OpenAir ${Translations.of(context).text('notification')}',
                                Translations.of(context)
                                    .text('noPodcastsFound'),
                              );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                Translations.of(context)
                                    .text('noPodcastsFound'),
                              ),
                            ),
                          );
                        }
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
                      if (!Platform.isAndroid && !Platform.isIOS) {
                        ref.read(notificationServiceProvider).showNotification(
                              'OpenAir ${Translations.of(context).text('notification')}',
                              Translations.of(context)
                                  .text('failedToFindPodcasts'),
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              Translations.of(context)
                                  .text('failedToFindPodcasts'),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              SizedBox(height: 15),
              getConnectionStatusValue.when(
                error: (error, stackTrace) {
                  debugPrint('Error fetching connection status: $error');
                  return const SizedBox.shrink();
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                data: (data) {
                  if (data == false) {
                    return const NoConnection();
                  }

                  return podcastDataAsyncValue.when(
                    error: (error, stackTrace) {
                      debugPrint('Error fetching podcast data: $error');
                      return const SizedBox.shrink();
                    },
                    loading: () {
                      return SizedBox(
                        height: 336,
                        child: GridView.builder(
                          itemCount: 12,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                    data: (snapshot) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 336,
                            child: GridView.builder(
                              itemCount: 12,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
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
                                        .getPodcastXml(
                                            snapshot[index]['xmlURL']);

                                    var rssFeed = RssFeed.parse(xmlString);

                                    SubscriptionModel podcast =
                                        SubscriptionModel(
                                      id: snapshot[index]['id'],
                                      feedUrl: snapshot[index]['xmlURL'],
                                      title: rssFeed.title!,
                                      description: rssFeed.description!,
                                      author: rssFeed.author ?? 'unknown',
                                      imageUrl: snapshot[index]['imgURL'],
                                      episodeCount: rssFeed.items!.length,
                                      artwork: snapshot[index]['imgURL'],
                                      updatedAt: DateTime.now(),
                                    );

                                    ref.read(audioProvider).currentPodcast =
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
                                      errorWidget: (context, url, error) =>
                                          LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            color: Colors.brown,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.error,
                                              // Set size relative to the current container dimensions
                                              size: (constraints.maxWidth <
                                                          constraints.maxHeight
                                                      ? constraints.maxWidth
                                                      : constraints.maxHeight) *
                                                  0.5,
                                            ),
                                          );
                                        },
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
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    Translations.of(context).text('discoveryPoweredByFyyd'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController textInputControl =
                        TextEditingController();

                    return AlertDialog(
                      title: Text(
                        Translations.of(context).text('addPodcastByRssUrl'),
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextField(
                          maxLength: 256,
                          autofocus: true,
                          controller: textInputControl,
                          keyboardType: TextInputType.url,
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
                              icon: const Icon(Icons.clear_rounded),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            Translations.of(context).text('cancel'),
                          ),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            if (textInputControl.text.isEmpty) {
                              return;
                            }

                            bool i = await ref
                                .watch(audioProvider)
                                .addPodcastByRssUrl(
                                    textInputControl.text, context);

                            if (context.mounted) {
                              if (i == true) {
                                if (!Platform.isAndroid && !Platform.isIOS) {
                                  ref
                                      .read(notificationServiceProvider)
                                      .showNotification(
                                        'OpenAir ${Translations.of(context).text('notification')}',
                                        Translations.of(context)
                                            .text('subscribed'),
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Translations.of(context)
                                            .text('subscribed'),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                if (!Platform.isAndroid && !Platform.isIOS) {
                                  ref
                                      .read(notificationServiceProvider)
                                      .showNotification(
                                        'OpenAir ${Translations.of(context).text('notification')}',
                                        Translations.of(context)
                                            .text('errorAddingPodcast'),
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
                            }
                          },
                          child: Text(
                            Translations.of(context).text('add'),
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController textInputControl =
                        TextEditingController();

                    return AlertDialog(
                      title: Text(
                        Translations.of(context).text('searchPodcastIndex'),
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextField(
                          maxLength: 256,
                          autofocus: true,
                          controller: textInputControl,
                          keyboardType: TextInputType.url,
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
                              icon: const Icon(Icons.clear_rounded),
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
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              Translations.of(context).text('cancel'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
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
                                    builder: (context) =>
                                        PodcastIndexSearchPage(
                                      podcasts: podcasts,
                                      searchWord: textInputControl.text,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              Translations.of(context).text('search'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () async {
                  bool i = await ref
                      .watch(audioProvider)
                      .importPodcastFromOpml(context);

                  if (context.mounted) {
                    if (i == true) {
                      if (!Platform.isAndroid && !Platform.isIOS) {
                        ref.read(notificationServiceProvider).showNotification(
                              'OpenAir ${Translations.of(context).text('notification')}',
                              Translations.of(context)
                                  .text('importedPodcastsFromOpml'),
                            );
                      } else {
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
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
            ? bannerAudioPlayerHeight
            : 0.0,
        child: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
            ? const BannerAudioPlayer()
            : const SizedBox.shrink(),
      ),
    );
  }
}
