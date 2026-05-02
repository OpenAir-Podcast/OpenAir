import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class DonatePage extends ConsumerStatefulWidget {
  const DonatePage({super.key});

  @override
  ConsumerState<DonatePage> createState() => DonatePageState();
}

class DonatePageState extends ConsumerState<DonatePage> {
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

  Widget _buildDonateTile({
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

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      await launchUrl(Uri.parse(url));
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
          Translations.of(context).text('donate'),
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
              Translations.of(context).text('donateDescription'),
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
                _buildDonateTile(
                  icon: Icons.paypal_rounded,
                  title: Translations.of(context).text('donateWithPayPal'),
                  onTap: () async {
                    final url = dotenv.env['PAYPAL_URL'];
                    if (url != null && context.mounted) {
                      await _launchUrl(url, context);
                    }
                  },
                  context: context,
                  iconColor: const Color(0xFF003087),
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildDonateTile(
                  icon: Icons.coffee_rounded,
                  title: Translations.of(context).text('buyMeACoffee'),
                  onTap: () async {
                    final url = dotenv.env['BUY_ME_A_COFFEE_URL'];
                    if (url != null && context.mounted) {
                      await _launchUrl(url, context);
                    }
                  },
                  context: context,
                  iconColor: Colors.orange,
                ),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                _buildDonateTile(
                  icon: Icons.local_drink_outlined,
                  title: Translations.of(context).text('donateWithKofi'),
                  onTap: () async {
                    final url = dotenv.env['DONATE_WITH_KOFI_URL'];
                    if (url != null && context.mounted) {
                      await _launchUrl(url, context);
                    }
                  },
                  context: context,
                  iconColor: const Color(0xFFFF5E5B),
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
