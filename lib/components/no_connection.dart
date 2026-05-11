import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';

class NoConnection extends ConsumerWidget {
  const NoConnection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.wifi_off_rounded,
            size: 60.0,
            color: colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          Translations.of(context).text('oopsAnErrorOccurred'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            Translations.of(context).text('pleaseConnectToNetwork'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        FilledButton.icon(
          onPressed: () async {
            ref.read(openAirProvider).getConnectionStatusTriggered();
          },
          icon: const Icon(Icons.refresh_rounded),
          label: Text(Translations.of(context).text('retry')),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
