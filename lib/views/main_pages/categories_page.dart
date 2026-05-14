import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/model/category.dart';
import 'package:openair/views/main_pages/category_page.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/views/main_pages/trending_page.dart';

List<Category> getCategories(BuildContext context) => [
      Category(
          name: Translations.of(context).text('animals'),
          icon: Icons.pets_rounded,
          apiKey: 'animals'),
      Category(
          name: Translations.of(context).text('animation'),
          icon: Icons.animation_rounded,
          apiKey: 'animation'),
      Category(
          name: Translations.of(context).text('arts'),
          icon: Icons.palette_rounded,
          apiKey: 'arts'),
      Category(
          name: Translations.of(context).text('astronomy'),
          icon: Icons.rocket_launch_rounded,
          apiKey: 'astronomy'),
      Category(
          name: Translations.of(context).text('automotive'),
          icon: Icons.car_rental_rounded,
          apiKey: 'automotive'),
      Category(
          name: Translations.of(context).text('aviation'),
          icon: Icons.airplane_ticket_rounded,
          apiKey: 'aviation'),
      Category(
          name: Translations.of(context).text('beauty'),
          icon: Icons.face_retouching_natural_rounded,
          apiKey: 'beauty'),
      Category(
          name: Translations.of(context).text('books'),
          icon: Icons.book_rounded,
          apiKey: 'books'),
      Category(
          name: Translations.of(context).text('business'),
          icon: Icons.business_center_rounded,
          apiKey: 'business'),
      Category(
          name: Translations.of(context).text('careers'),
          icon: Icons.work_rounded,
          apiKey: 'careers'),
      Category(
          name: Translations.of(context).text('chemistry'),
          icon: Icons.science_rounded,
          apiKey: 'chemistry'),
      Category(
          name: Translations.of(context).text('christianity'),
          icon: Icons.church_rounded,
          apiKey: 'christianity'),
      Category(
          name: Translations.of(context).text('comedy'),
          icon: Icons.theater_comedy_rounded,
          apiKey: 'comedy'),
      Category(
          name: Translations.of(context).text('commentary'),
          icon: Icons.record_voice_over_rounded,
          apiKey: 'commentary'),
      Category(
          name: Translations.of(context).text('courses'),
          icon: Icons.menu_book_rounded,
          apiKey: 'courses'),
      Category(
          name: Translations.of(context).text('crafts'),
          icon: Icons.construction_rounded,
          apiKey: 'crafts'),
      Category(
          name: Translations.of(context).text('daily'),
          icon: Icons.today_rounded,
          apiKey: 'daily'),
      Category(
          name: Translations.of(context).text('design'),
          icon: Icons.design_services_rounded,
          apiKey: 'design'),
      Category(
          name: Translations.of(context).text('drama'),
          icon: Icons.theaters_rounded,
          apiKey: 'drama'),
      Category(
          name: Translations.of(context).text('earth'),
          icon: Icons.public_rounded,
          apiKey: 'earth'),
      Category(
          name: Translations.of(context).text('education'),
          icon: Icons.school_rounded,
          apiKey: 'education'),
      Category(
          name: Translations.of(context).text('entertainment'),
          icon: Icons.emoji_emotions_rounded,
          apiKey: 'entertainment'),
      Category(
          name: Translations.of(context).text('entrepreneurship'),
          icon: Icons.lightbulb_rounded,
          apiKey: 'entrepreneurship'),
      Category(
          name: Translations.of(context).text('family'),
          icon: Icons.family_restroom_rounded,
          apiKey: 'family'),
      Category(
          name: Translations.of(context).text('fashion'),
          icon: Icons.checkroom_rounded,
          apiKey: 'fashion'),
      Category(
          name: Translations.of(context).text('fiction'),
          icon: Icons.auto_stories_rounded,
          apiKey: 'fiction'),
      Category(
          name: Translations.of(context).text('fitness'),
          icon: Icons.fitness_center_rounded,
          apiKey: 'fitness'),
      Category(
          name: Translations.of(context).text('food'),
          icon: Icons.restaurant_rounded,
          apiKey: 'food'),
      Category(
          name: Translations.of(context).text('games'),
          icon: Icons.sports_esports_rounded,
          apiKey: 'games'),
      Category(
          name: Translations.of(context).text('garden'),
          icon: Icons.grass_rounded,
          apiKey: 'garden'),
      Category(
          name: Translations.of(context).text('government'),
          icon: Icons.account_balance_rounded,
          apiKey: 'government'),
      Category(
          name: Translations.of(context).text('health'),
          icon: Icons.health_and_safety_rounded,
          apiKey: 'health'),
      Category(
          name: Translations.of(context).text('hinduism'),
          icon: Icons.temple_hindu_rounded,
          apiKey: 'hinduism'),
      Category(
          name: Translations.of(context).text('history'),
          icon: Icons.history_rounded,
          apiKey: 'history'),
      Category(
          name: Translations.of(context).text('hobbies'),
          icon: Icons.extension_rounded,
          apiKey: 'hobbies'),
      Category(
          name: Translations.of(context).text('home'),
          icon: Icons.home_rounded,
          apiKey: 'home'),
      Category(
          name: Translations.of(context).text('howTo'),
          icon: Icons.how_to_reg_rounded,
          apiKey: 'how to'),
      Category(
          name: Translations.of(context).text('interview'),
          icon: Icons.record_voice_over_rounded,
          apiKey: 'interview'),
      Category(
          name: Translations.of(context).text('investing'),
          icon: Icons.trending_up_rounded,
          apiKey: 'investing'),
      Category(
          name: Translations.of(context).text('islam'),
          icon: Icons.mosque_rounded,
          apiKey: 'islam'),
      Category(
          name: Translations.of(context).text('judaism'),
          icon: Icons.star_rounded,
          apiKey: 'judaism'),
      Category(
          name: Translations.of(context).text('kids'),
          icon: Icons.child_care_rounded,
          apiKey: 'kids'),
      Category(
          name: Translations.of(context).text('language'),
          icon: Icons.translate_rounded,
          apiKey: 'language'),
      Category(
          name: Translations.of(context).text('learning'),
          icon: Icons.school_rounded,
          apiKey: 'learning'),
      Category(
          name: Translations.of(context).text('leisure'),
          icon: Icons.beach_access_rounded,
          apiKey: 'leisure'),
      Category(
          name: Translations.of(context).text('life'),
          icon: Icons.favorite_rounded,
          apiKey: 'life'),
      Category(
          name: Translations.of(context).text('management'),
          icon: Icons.manage_accounts_rounded,
          apiKey: 'management'),
      Category(
          name: Translations.of(context).text('manga'),
          icon: Icons.menu_book_rounded,
          apiKey: 'manga'),
      Category(
          name: Translations.of(context).text('marketing'),
          icon: Icons.campaign_rounded,
          apiKey: 'marketing'),
      Category(
          name: Translations.of(context).text('mathematics'),
          icon: Icons.calculate_rounded,
          apiKey: 'mathematics'),
      Category(
          name: Translations.of(context).text('medicine'),
          icon: Icons.local_hospital_rounded,
          apiKey: 'medicine'),
      Category(
          name: Translations.of(context).text('mental'),
          icon: Icons.psychology_rounded,
          apiKey: 'mental'),
      Category(
          name: Translations.of(context).text('music'),
          icon: Icons.music_note_rounded,
          apiKey: 'music'),
      Category(
          name: Translations.of(context).text('natural'),
          icon: Icons.eco_rounded,
          apiKey: 'natural'),
      Category(
          name: Translations.of(context).text('nature'),
          icon: Icons.nature_people_rounded,
          apiKey: 'nature'),
      Category(
          name: Translations.of(context).text('news'),
          icon: Icons.newspaper_rounded,
          apiKey: 'news'),
      Category(
          name: Translations.of(context).text('nonProfit'),
          icon: Icons.volunteer_activism_rounded,
          apiKey: 'non-profit'),
      Category(
          name: Translations.of(context).text('nutrition'),
          icon: Icons.food_bank_rounded,
          apiKey: 'nutrition'),
      Category(
          name: Translations.of(context).text('parenting'),
          icon: Icons.supervisor_account_rounded,
          apiKey: 'parenting'),
      Category(
          name: Translations.of(context).text('performing'),
          icon: Icons.theater_comedy_rounded,
          apiKey: 'performing'),
      Category(
          name: Translations.of(context).text('pets'),
          icon: Icons.pets_rounded,
          apiKey: 'pets'),
      Category(
          name: Translations.of(context).text('physics'),
          icon: Icons.biotech_rounded,
          apiKey: 'physics'),
      Category(
          name: Translations.of(context).text('politics'),
          icon: Icons.flag_rounded,
          apiKey: 'politics'),
      Category(
          name: Translations.of(context).text('religion'),
          icon: Icons.temple_hindu_rounded,
          apiKey: 'religion'),
      Category(
          name: Translations.of(context).text('science'),
          icon: Icons.science_rounded,
          apiKey: 'science'),
      Category(
          name: Translations.of(context).text('selfImprovement'),
          icon: Icons.self_improvement_rounded,
          apiKey: 'self improvement'),
      Category(
          name: Translations.of(context).text('social'),
          icon: Icons.groups_rounded,
          apiKey: 'social'),
      Category(
          name: Translations.of(context).text('spirituality'),
          icon: Icons.self_improvement_rounded,
          apiKey: 'spirituality'),
      Category(
          name: Translations.of(context).text('sports'),
          icon: Icons.sports_basketball_rounded,
          apiKey: 'sports'),
      Category(
          name: Translations.of(context).text('standUp'),
          icon: Icons.mic_rounded,
          apiKey: 'stand-up'),
      Category(
          name: Translations.of(context).text('stories'),
          icon: Icons.auto_stories_rounded,
          apiKey: 'stories'),
      Category(
          name: Translations.of(context).text('videoGames'),
          icon: Icons.videogame_asset_rounded,
          apiKey: 'video games'),
      Category(
          name: Translations.of(context).text('visual'),
          icon: Icons.remove_red_eye_rounded,
          apiKey: 'visual'),
      Category(
          name: Translations.of(context).text('trueCrime'),
          icon: Icons.gavel_rounded,
          apiKey: 'true crime'),
      Category(
          name: Translations.of(context).text('tv'),
          icon: Icons.tv_rounded,
          apiKey: 'tv'),
    ];

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Ensure rebuild on language change
    final connectionAsync = ref.watch(connectionCheckProvider);

    return connectionAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCategoryGrid(context),
      data: (isConnected) =>
          isConnected ? _buildCategoryGrid(context) : const NoConnection(),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final isWide = !Platform.isAndroid && !Platform.isIOS;
    final isWide = wideScreenMinWidth < MediaQuery.sizeOf(context).width;
    final categories = getCategories(context);

    return Scaffold(
      body: isWide
          ? GridView.builder(
              padding: EdgeInsets.all(isWide ? 24 : 12),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2.5,
                crossAxisSpacing: isWide ? 16 : 12,
                mainAxisSpacing: isWide ? 16 : 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryCard(
                  category: category,
                  onTap: () => _navigateToCategory(context, category),
                );
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryListTile(
                  category: category,
                  onTap: () => _navigateToCategory(context, category),
                );
              },
            ),
    );
  }

  void _navigateToCategory(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          category: category.name,
          apiKey: category.apiKey,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: Theme.of(context).colorScheme.primary,
                size: 32.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryListTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                category.icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
