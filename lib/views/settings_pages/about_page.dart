import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/env.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:openair/views/settings_pages/licenses_page.dart';
import 'package:url_launcher/url_launcher.dart';

final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => AboutPageState();
}

class AboutPageState extends ConsumerState<AboutPage> {
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
    String? subtitle,
    required VoidCallback onTap,
    required BuildContext context,
    Color? iconColor,
    Widget? trailing,
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
              if (trailing != null) trailing,
              if (trailing == null)
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

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Translations.of(context).text('oopsAnErrorOccurred')} '
              '${Translations.of(context).text('oopsTryAgainLater')}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appInfoAsync = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('about'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: appInfoAsync.when(
        data: (data) {
          return ListView(
            children: [
              const SizedBox(height: 24),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/icons/icon_512.png',
                    width: 192,
                    height: 192,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'OpenAir',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'v${data.version}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  Translations.of(context).text('aboutDescription'),
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
              const SizedBox(height: 24),
              _buildCard(
                Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.code_rounded,
                      title: Translations.of(context).text('sourceCode'),
                      onTap: () async {
                        final url = Env.githubUrl;
                        await _launchUrl(url);
                      },
                      context: context,
                      iconColor: Colors.grey[700],
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildActionTile(
                      icon: Icons.gavel_rounded,
                      title: Translations.of(context).text('licenses'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LicensesPage(),
                          ),
                        );
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildActionTile(
                      icon: Icons.shield_rounded,
                      title: Translations.of(context).text('privacyPolicy'),
                      onTap: () async {
                        final url = Env.privacyPolicy;
                        await _launchUrl(url);
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
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              Translations.of(context).text('oopsAnErrorOccurred'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
