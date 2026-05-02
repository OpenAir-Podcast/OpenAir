import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

final FutureProvider<Map?> notificationsSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getNotificationsSettings();
});

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => NotificationsPageState();
}

class NotificationsPageState extends ConsumerState<NotificationsPage> {
  Widget _buildCard(Widget child, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildToggleTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    required BuildContext context,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).colorScheme.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _saveNotificationsSettings(Map data, BuildContext context) {
    ref.watch(openAirProvider).hiveService.saveNotificationsSettings(data);
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('notifications'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: notifications.when(
        data: (data) {
          final notificationsData = data!;

          final receiveNotificationsForNewEpisodes =
              notificationsData['receiveNotificationsForNewEpisodes'] ?? true;
          final receiveNotificationsWhenPlaying =
              notificationsData['receiveNotificationsWhenPlaying'] ?? true;
          final receiveNotificationsWhenDownloading =
              notificationsData['receiveNotificationsWhenDownloading'] ?? true;

          return ListView(
            children: [
              SizedBox(height: 16),
              _buildCard(
                Column(
                  children: [
                    _buildToggleTile(
                      icon: Icons.auto_awesome_rounded,
                      label: Translations.of(context)
                          .text('receiveNotificationsForNewEpisodes'),
                      subtitle: Translations.of(context)
                          .text('receiveNotificationsForNewEpisodesSubtitle'),
                      value: receiveNotificationsForNewEpisodes,
                      onChanged: (value) {
                        notificationsData[
                            'receiveNotificationsForNewEpisodes'] = value;
                        receiveNotificationsForNewEpisodesConfig = value;
                        _saveNotificationsSettings(notificationsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      icon: Icons.play_circle_outline_rounded,
                      label: Translations.of(context)
                          .text('receiveNotificationsWhenPlaying'),
                      subtitle: Translations.of(context)
                          .text('receiveNotificationsWhenPlayingSubtitle'),
                      value: receiveNotificationsWhenPlaying,
                      onChanged: (value) {
                        notificationsData['receiveNotificationsWhenPlaying'] =
                            value;
                        receiveNotificationsWhenPlayConfig = value;
                        _saveNotificationsSettings(notificationsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      icon: Icons.download_rounded,
                      label: Translations.of(context)
                          .text('receiveNotificationsWhenDownloading'),
                      subtitle: Translations.of(context)
                          .text('receiveNotificationsWhenDownloadingSubtitle'),
                      value: receiveNotificationsWhenDownloading,
                      onChanged: (value) {
                        notificationsData[
                            'receiveNotificationsWhenDownloading'] = value;
                        receiveNotificationsWhenDownloadConfig = value;
                        _saveNotificationsSettings(notificationsData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(Translations.of(context).text('oopsAnErrorOccurred')),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
