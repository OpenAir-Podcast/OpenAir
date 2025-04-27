import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';

class MainNavBar extends ConsumerWidget {
  const MainNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: ref.watch(openAirProvider).navIndex,
      elevation: 8.0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.travel_explore_rounded),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.my_library_music_rounded),
          label: 'Library',
        ),
      ],
      onTap: (value) {
        switch (value) {
          case 0:
            ref.read(openAirProvider.notifier).setNavIndex(0);
            break;
          case 1:
            ref.read(openAirProvider.notifier).setNavIndex(1);
            break;
          case 2:
            ref.read(openAirProvider.notifier).setNavIndex(2);
            break;
          default:
        }
      },
    );
  }
}
