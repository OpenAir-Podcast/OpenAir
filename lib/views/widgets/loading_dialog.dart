import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const double size = 150;
    final theme = Theme.of(context);

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      content: SizedBox(
        height: size,
        width: size,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 35),
              Text(
                "Searching...",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
