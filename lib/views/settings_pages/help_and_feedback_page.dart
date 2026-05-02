import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndFeedbackPage extends ConsumerStatefulWidget {
  const HelpAndFeedbackPage({super.key});

  @override
  ConsumerState<HelpAndFeedbackPage> createState() =>
      HelpAndFeedbackPageState();
}

class HelpAndFeedbackPageState extends ConsumerState<HelpAndFeedbackPage> {
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Future<void> Function() onTap,
    required BuildContext context,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
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

  Future<void> _launchExternalUrl(String url, BuildContext context) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        final message =
            '${Translations.of(context).text('oopsAnErrorOccurred')} '
            '${Translations.of(context).text('oopsTryAgainLater')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('helpAndFeedback'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
            child: Text(
              Translations.of(context).text('helpAndFeedbackDescription'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    height: 1.5,
                  ),
            ),
          ),
          _buildCard(
            Column(
              children: [
                _buildActionTile(
                  icon: Icons.forum_rounded,
                  title: Translations.of(context).text('joinOurDiscord'),
                  onTap: () async {
                    final url = dotenv.env['DISCORD_URL'];
                    if (url != null && context.mounted) {
                      await _launchExternalUrl(url, context);
                    }
                  },
                  context: context,
                  iconColor: const Color(0xFF5865F2),
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildActionTile(
                  icon: Icons.bug_report_rounded,
                  title: Translations.of(context).text('reportABug'),
                  onTap: () async {
                    final url = dotenv.env['GITHUB_ISSUES_URL'];
                    if (url != null && context.mounted) {
                      await _launchExternalUrl(url, context);
                    }
                  },
                  context: context,
                  iconColor: Colors.redAccent,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildActionTile(
                  icon: Icons.lightbulb_rounded,
                  title: Translations.of(context).text('suggestAFeature'),
                  onTap: () async {
                    final url = dotenv.env['GITHUB_DISCUSSION_URL'];
                    if (url != null && context.mounted) {
                      await _launchExternalUrl(url, context);
                    }
                  },
                  context: context,
                  iconColor: Colors.orange,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildActionTile(
                  icon: Icons.gavel_rounded,
                  title: Translations.of(context).text('privacyPolicy'),
                  onTap: () async {
                    final url = dotenv.env['PRIVACY_POLICY'];
                    if (url != null && context.mounted) {
                      await _launchExternalUrl(url, context);
                    }
                  },
                  context: context,
                  iconColor: Colors.teal,
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
