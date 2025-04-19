import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/views/navPages/categories_page.dart';
import 'package:openair/views/navPages/featured_page.dart';
import 'package:openair/views/navPages/trending_page.dart';
import 'package:openair/views/navigation/app_drawer.dart';
import 'package:openair/views/navigation/main_app_bar.dart';

class MobileScaffold extends ConsumerWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: mainAppBar(ref),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            const FeaturedPage(),
            const TrendingPage(),
            CategoriesPage(),
          ],
        ),
      ),
    );
  }
}
