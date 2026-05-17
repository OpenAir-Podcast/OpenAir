import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/drawer_counts.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/nav_pages/add_podcast_page.dart';
import 'package:openair/views/nav_pages/downloads_page.dart';
import 'package:openair/views/nav_pages/favorites_page.dart';
import 'package:openair/views/nav_pages/feeds_page.dart';
import 'package:openair/views/nav_pages/history_page.dart';
import 'package:openair/views/nav_pages/inbox_page.dart';
import 'package:openair/views/nav_pages/log_in_page.dart';
import 'package:openair/views/nav_pages/queue_page.dart';
import 'package:openair/views/nav_pages/settings_page.dart';
import 'package:openair/views/nav_pages/subscriptions_page.dart';
import 'package:openair/views/main_pages/featured_page.dart';
import 'package:openair/views/navigation/list_drawer.dart';
import 'package:openair/views/player/main_player.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/controllers/subscription_controller.dart';

final getSessionProvider = StreamProvider.autoDispose((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.client.auth.onAuthStateChange;
});

class WideDrawer extends ConsumerStatefulWidget {
  final Function(Widget) onPageSelected;
  final Function() rebuildDrawer;

  const WideDrawer({
    super.key,
    required this.onPageSelected,
    required this.rebuildDrawer,
  });

  @override
  ConsumerState<WideDrawer> createState() => _WideDrawerState();
}

class _WideDrawerState extends ConsumerState<WideDrawer> {
  void returnFromSignin() {
    debugPrint('Returned from SignIn');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final drawerCounts = ref.watch(drawerCountsProvider);
    final session = ref.watch(getSessionProvider);
    final supabaseService = ref.watch(supabaseServiceProvider);
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          _buildHeader(theme, session, supabaseService),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: Translations.of(context).text('home'),
                  onTap: () => widget.onPageSelected(const FeaturedPage()),
                ),
                const SizedBox(height: 2),
                Consumer(
                  builder: (context, ref, _) {
                    final isPodcastPlaying =
                        ref.watch(audioProvider.select((p) => p.isPodcastSelected));
                    return isPodcastPlaying
                        ? _NavItem(
                            icon: Icons.play_circle_rounded,
                            label: Translations.of(context).text('nowPlaying'),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MainPlayer(),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                if (ref.watch(audioProvider.select((p) => p.isPodcastSelected)))
                  const SizedBox(height: 2),
                _CountNavItem(
                  icon: Icons.subscriptions_rounded,
                  label: Translations.of(context).text('subscriptions'),
                  counts: drawerCounts,
                  selector: (c) => c.subscriptions,
                  onTap: () => widget.onPageSelected(SubscriptionsPage()),
                ),
                const SizedBox(height: 2),
                _CountNavItem(
                  icon: Icons.feed_rounded,
                  label: Translations.of(context).text('feeds'),
                  counts: drawerCounts,
                  selector: (c) => c.feeds,
                  onTap: () {
                    ref.invalidate(getSubscribedEpisodesProvider);
                    widget.onPageSelected(FeedsPage());
                  },
                ),
                const SizedBox(height: 2),
                _CountNavItem(
                  icon: Icons.inbox_rounded,
                  label: Translations.of(context).text('inbox'),
                  counts: drawerCounts,
                  selector: (c) => c.inbox,
                  onTap: () => widget.onPageSelected(InboxPage()),
                ),
                const SizedBox(height: 2),
                _CountNavItem(
                  icon: Icons.queue_music_rounded,
                  label: Translations.of(context).text('queue'),
                  counts: drawerCounts,
                  selector: (c) => c.queue,
                  onTap: () {
                    ref.invalidate(sortedProvider);
                    widget.onPageSelected(QueuePage());
                  },
                ),
                const SizedBox(height: 2),
                _CountNavItem(
                  icon: Icons.download_rounded,
                  label: Translations.of(context).text('downloads'),
                  counts: drawerCounts,
                  selector: (c) => c.downloads,
                  onTap: () => widget.onPageSelected(DownloadsPage()),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  label: Translations.of(context).text('favorites'),
                  iconColor: Colors.redAccent,
                  onTap: () => widget.onPageSelected(FavoritesPage()),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: Translations.of(context).text('history'),
                  onTap: () => widget.onPageSelected(HistoryPage()),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.add_rounded,
                  label: Translations.of(context).text('addPodcast'),
                  onTap: () => widget.onPageSelected(AddPodcastPage()),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: _NavItem(
              icon: Icons.settings_rounded,
              label: Translations.of(context).text('settings'),
              onTap: () {
                widget.onPageSelected(
                  Settings(
                    functionBuild: () {
                      widget.rebuildDrawer();
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, AsyncValue<dynamic> session, dynamic supabaseService) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/icons/icon.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'OpenAir',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (context) {
                final currentUser = supabaseService.client.auth.currentUser;
                return FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (currentUser == null) {
                      widget.onPageSelected(const LogIn());
                    } else {
                      await ref
                          .read(subscriptionControllerProvider)
                          .clearAllSubscriptions();
                      ref.invalidate(drawerCountsProvider);
                      await supabaseService.signOut();
                    }
                  },
                  child: Text(
                    currentUser == null
                        ? Translations.of(context).text('signIn')
                        : Translations.of(context).text('logout'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        hoverColor: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: iconColor ?? theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final AsyncValue<DrawerCounts> counts;
  final String Function(DrawerCounts) selector;
  final VoidCallback onTap;

  const _CountNavItem({
    required this.icon,
    required this.label,
    required this.counts,
    required this.selector,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return counts.when(
      loading: () => _LoadingItem(icon: icon, label: label, theme: theme),
      error: (error, _) =>
          _ErrorItem(icon: icon, label: label, theme: theme, onTap: onTap),
      data: (data) {
        final count = selector(data);
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            hoverColor: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon,
                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (count.isNotEmpty && count != '0')
                    Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        count,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _LoadingItem({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

class _ErrorItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ErrorItem({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        hoverColor: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.error_outline,
                  size: 16, color: theme.colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }
}
