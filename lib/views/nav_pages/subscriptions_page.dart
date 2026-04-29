import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/subscription_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';
import 'package:openair/views/nav_pages/inbox_page.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/subscription_card.dart';
import 'package:openair/views/navigation/list_drawer.dart';

final subscriptionsProvider =
    FutureProvider.autoDispose<Map<String, SubscriptionModel>>((ref) async {
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
    final subscriptionsAsync = ref.watch(subscriptionsWithCountsProvider);

    return subscriptionsAsync.when(
      data: (Map<String, dynamic> countsMap) {
        final subscriptionsAsync2 = ref.watch(subscriptionsProvider);

        return subscriptionsAsync2.when(
          data: (Map<String, SubscriptionModel> subsMap) {
            if (subsMap.isEmpty) {
              return const NoSubscriptions(title: 'Subscriptions');
            }

            final List<SubscriptionModel> subs = subsMap.values.toList();
            final totalNew = countsMap.values
                .map((m) => (m as Map)['newEpisodes'] as int? ?? 0)
                .fold(0, (a, b) => a + b);

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    Text(
                      Translations.of(context).text('subscriptions'),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (totalNew > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalNew',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip:
                        Translations.of(context).text('refreshAllPodcasts'),
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () async {
                      await ref
                          .read(openAirProvider)
                          .hiveService
                          .updateSubscriptions();
                      ref.invalidate(subscriptionsWithCountsProvider);
                      ref.invalidate(subscriptionsProvider);
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) async {
                      if (value == 'clear_all') {
                        _showClearAllDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'clear_all',
                        child: Text(
                            Translations.of(context).text('clearAllPodcasts')),
                      ),
                    ],
                  ),
                ],
              ),
              body: GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: subs.length,
                cacheExtent: cacheExtent,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return SubscriptionCard(
                    subs: subs,
                    ref: ref,
                    index: index,
                  );
                },
              ),
              bottomNavigationBar: _buildBottomBar(context, ref),
            );
          },
          error: (error, stackTrace) {
            debugPrint('Error loading subscriptions: $error\n$stackTrace');
            return Scaffold(
              appBar: AppBar(
                  title: Text(Translations.of(context).text('subscriptions'))),
              body: _ErrorView(error: error.toString()),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('Error loading subscriptions: $error\n$stackTrace');
        return Scaffold(
          appBar: AppBar(
              title: Text(Translations.of(context).text('subscriptions'))),
          body: _ErrorView(error: error.toString()),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context, WidgetRef ref) {
    final isPodcastSelected = ref.watch(
      audioProvider.select((p) => p.isPodcastSelected),
    );

    if (!isPodcastSelected) return null;

    return SizedBox(
      height: bannerAudioPlayerHeight,
      child: const BannerAudioPlayer(),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(Translations.of(context).text('clearAllPodcasts')),
        content:
            Text(Translations.of(context).text('areYouSureClearAllPodcasts')),
        actions: [
          TextButton(
            child: Text(Translations.of(context).text('cancel')),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Translations.of(context).text('clear')),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(openAirProvider).hiveService.deleteSubscriptions();

              ref.invalidate(subscriptionsProvider);
              ref.invalidate(subCountProvider);
              ref.invalidate(getSubscribedEpisodesProvider);
              ref.invalidate(feedCountProvider);
              ref.invalidate(getInboxProvider);
              ref.invalidate(inboxCountProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 75, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            Translations.of(context).text('oopsTryAgainLater'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 180,
            height: 40,
            child: Consumer(
              builder: (context, ref, _) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ref.invalidate(subscriptionsWithCountsProvider);
                  ref.invalidate(subscriptionsProvider);
                },
                child: const Text('Retry'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
