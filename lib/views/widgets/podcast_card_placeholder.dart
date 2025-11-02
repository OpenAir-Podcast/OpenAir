import 'package:flutter/material.dart';
import 'package:openair/config/config.dart';
import 'package:shimmer/shimmer.dart';

class PodcastCardPlaceholder extends StatelessWidget {
  const PodcastCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2.0,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: highlightColor!,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 56,
                width: 56,
                color: highlightColor2,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: highlightColor2,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 12,
                      width: 100,
                      color: highlightColor2,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 24,
                width: 24,
                color: highlightColor2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
