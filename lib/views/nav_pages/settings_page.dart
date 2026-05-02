import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/views/settings_pages/account_page.dart';
import 'package:openair/views/settings_pages/about_page.dart';
import 'package:openair/views/settings_pages/donate_page.dart';
import 'package:openair/views/settings_pages/automatic_page.dart';
import 'package:openair/views/settings_pages/help_and_feedback_page.dart';
import 'package:openair/views/settings_pages/import_export_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/settings_pages/playback_page.dart';
import 'package:openair/views/settings_pages/synchronization_page.dart';
import 'package:openair/views/settings_pages/user_interface_page.dart';

class Settings extends ConsumerStatefulWidget {
  final Function() functionBuild;

  const Settings({
    super.key,
    required this.functionBuild,
  });

  @override
  ConsumerState createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }

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

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('settings'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('general', context),
          _buildCard(
            Column(
              children: [
                _buildTile(
                  icon: Icons.account_circle_rounded,
                  title: Translations.of(context).text('account'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountPage(),
                      ),
                    );
                  },
                  context: context,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildTile(
                  icon: Icons.display_settings_rounded,
                  title: Translations.of(context).text('userInterface'),
                  subtitle:
                      Translations.of(context).text('userInterfaceSubtitle'),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => const UserInterface(),
                      ),
                    )
                        .then((value) {
                      setState(() {});
                      widget.functionBuild();
                    });
                  },
                  context: context,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildTile(
                  icon: Icons.play_arrow_rounded,
                  title: Translations.of(context).text('playback'),
                  subtitle: Translations.of(context).text('playbackSubtitle'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlaybackPage(),
                      ),
                    );
                  },
                  context: context,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildTile(
                  icon: Icons.autorenew_rounded,
                  title: Translations.of(context).text('automatic'),
                  subtitle: Translations.of(context).text('downloadsSubtitle'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AutomaticPage(),
                      ),
                    );
                  },
                  context: context,
                ),
              ],
            ),
            context,
          ),
          _buildSectionHeader('data', context),
          _buildCard(
            Column(
              children: [
                _buildTile(
                  icon: Icons.cloud_download_outlined,
                  title: Translations.of(context).text('synchronization'),
                  subtitle:
                      Translations.of(context).text('synchronizationSubtitle'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SynchronizationPage(),
                      ),
                    );
                  },
                  context: context,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildTile(
                  icon: Icons.sd_card_rounded,
                  title: Translations.of(context).text('importExport'),
                  subtitle:
                      Translations.of(context).text('importExportSubtitle'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ImportExportPage(),
                      ),
                    );
                  },
                  context: context,
                ),
              ],
            ),
            context,
          ),
          _buildSectionHeader('support', context),
          _buildCard(
            Column(
              children: [
                _buildTile(
                  icon: Icons.notifications_none_rounded,
                  title: Translations.of(context).text('notifications'),
                  subtitle:
                      Translations.of(context).text('notificationsSubtitle'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                  context: context,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildTile(
                  icon: Icons.thumb_up_alt_rounded,
                  title: Translations.of(context).text('donate'),
                  subtitle: Translations.of(context).text('donateSubtitle'),
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DonatePage(),
                      ),
                    );
                  },
                  context: context,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildTile(
                  icon: Icons.help_outline_rounded,
                  title: Translations.of(context).text('helpAndFeedback'),
                  subtitle:
                      Translations.of(context).text('helpAndFeedbackSubtitle'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpAndFeedbackPage(),
                      ),
                    );
                  },
                  context: context,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildTile(
                  icon: Icons.info_outline_rounded,
                  title: Translations.of(context).text('about'),
                  subtitle: Translations.of(context).text('aboutSubtitle'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                  context: context,
                ),
              ],
            ),
            context,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
