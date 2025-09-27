import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';

import 'package:openair/views/desktop/player/banner_audio_player.dart';
import 'package:openair/views/desktop/settings_pages/notifications_page.dart';
import 'package:openair/views/desktop/widgets/subscription_card.dart';
import 'package:openair/views/mobile/nav_pages/feeds_page.dart';
import 'package:openair/views/mobile/navigation/app_drawer.dart';

final subscriptionsProvider = FutureProvider.autoDispose((ref) async {
  // Watch hiveServiceProvider as subscription data comes from Hive
  ref.watch(openAirProvider).hiveService;
  return await ref.read(openAirProvider).getSubscriptions();
});

class SubscriptionsPage extends ConsumerStatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  ConsumerState<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends ConsumerState<SubscriptionsPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<String, SubscriptionModel>> getSubscriptionsValue =
        ref.watch(subscriptionsProvider);

    return getSubscriptionsValue.when(
      data: (Map<String, SubscriptionModel> data) {
        if (data.isEmpty) {
          return NoSubscriptions(title: 'Subscriptions');
        }

        final List<SubscriptionModel> subs = data.values.toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('subscriptions')),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO Add search functionality here
                  // This is to search for podcast that the user has already sub to.
                },
                icon: const Icon(Icons.search),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width - 100,
                        58,
                        0,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'refresh_all',
                          child: Text(
                            Translations.of(context).text('refreshAllPodcasts'),
                          ),
                          onTap: () async {
                            await ref
                                .read(openAirProvider)
                                .hiveService
                                .updateSubscriptions();

                            ref.invalidate(getSubscriptionsCountProvider);
                            ref.invalidate(subscriptionsProvider);
                          },
                        ),
                        PopupMenuItem(
                          value: 'clear_all',
                          child: Text(
                            Translations.of(context).text('clearAllPodcasts'),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) =>
                                  AlertDialog(
                                title: Text(
                                  Translations.of(context).text(
                                    'clearAllPodcasts',
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                content: Text(
                                  Translations.of(context).text(
                                    'areYouSureClearAllPodcasts',
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(Translations.of(context)
                                        .text('cancel')),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      Translations.of(context).text('clear'),
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();
                                      await ref
                                          .read(openAirProvider)
                                          .hiveService
                                          .deleteSubscriptions();

                                      ref.invalidate(subscriptionsProvider);
                                      ref.invalidate(
                                          getSubscriptionsCountProvider);

                                      ref.invalidate(feedCountProvider);
                                      ref.invalidate(getFeedsProvider);

                                      if (context.mounted) {
                                        if (!Platform.isAndroid &&
                                            !Platform.isIOS) {
                                          ref
                                              .read(notificationServiceProvider)
                                              .showNotification(
                                                'OpenAir ${Translations.of(context).text('notification')}',
                                                Translations.of(context)
                                                    .text('allPodcastsCleared'),
                                              );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                Translations.of(context)
                                                    .text('allPodcastsCleared'),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ),
            ],
          ),
          body: GridView.builder(
            itemCount: subs.length,
            cacheExtent: cacheExtent,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisExtent: subscribedDesktopMainAxisExtent,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return SubscriptionCard(
                subs: subs,
                ref: ref,
                index: index,
              );
            },
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
      },
      error: (error, stackTrace) {
        debugPrint('Error loading subscriptions: $error\n$stackTrace');
        return Scaffold(
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
                  Translations.of(context).text('oopsTryAgainLater'),
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
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
                      ref.invalidate(subscriptionsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        color: Brightness.dark == Theme.of(context).brightness
            ? Colors.black
            : Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
