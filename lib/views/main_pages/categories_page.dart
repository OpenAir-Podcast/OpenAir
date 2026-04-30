import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/category.dart';
import 'package:openair/views/main_pages/category_page.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/views/main_pages/trending_page.dart';

final categories = [
  Category(name: 'Animals', icon: Icons.pets_rounded, apiKey: 'animals'),
  Category(
      name: 'Animation', icon: Icons.animation_rounded, apiKey: 'animation'),
  Category(name: 'Arts', icon: Icons.palette_rounded, apiKey: 'arts'),
  Category(
      name: 'Astronomy',
      icon: Icons.rocket_launch_rounded,
      apiKey: 'astronomy'),
  Category(
      name: 'Automotive', icon: Icons.car_rental_rounded, apiKey: 'automotive'),
  Category(
      name: 'Aviation',
      icon: Icons.airplane_ticket_rounded,
      apiKey: 'aviation'),
  Category(
      name: 'Beauty',
      icon: Icons.face_retouching_natural_rounded,
      apiKey: 'beauty'),
  Category(name: 'Books', icon: Icons.book_rounded, apiKey: 'books'),
  Category(
      name: 'Business',
      icon: Icons.business_center_rounded,
      apiKey: 'business'),
  Category(name: 'Careers', icon: Icons.work_rounded, apiKey: 'careers'),
  Category(name: 'Chemistry', icon: Icons.science_rounded, apiKey: 'chemistry'),
  Category(
      name: 'Christianity', icon: Icons.church_rounded, apiKey: 'christianity'),
  Category(
      name: 'Comedy', icon: Icons.theater_comedy_rounded, apiKey: 'comedy'),
  Category(
      name: 'Commentary',
      icon: Icons.record_voice_over_rounded,
      apiKey: 'commentary'),
  Category(name: 'Courses', icon: Icons.menu_book_rounded, apiKey: 'courses'),
  Category(name: 'Crafts', icon: Icons.construction_rounded, apiKey: 'crafts'),
  Category(name: 'Daily', icon: Icons.today_rounded, apiKey: 'daily'),
  Category(
      name: 'Design', icon: Icons.design_services_rounded, apiKey: 'design'),
  Category(name: 'Drama', icon: Icons.theaters_rounded, apiKey: 'drama'),
  Category(name: 'Earth', icon: Icons.public_rounded, apiKey: 'earth'),
  Category(name: 'Education', icon: Icons.school_rounded, apiKey: 'education'),
  Category(
      name: 'Entertainment',
      icon: Icons.emoji_emotions_rounded,
      apiKey: 'entertainment'),
  Category(
      name: 'Entrepreneurship',
      icon: Icons.lightbulb_rounded,
      apiKey: 'entrepreneurship'),
  Category(
      name: 'Family', icon: Icons.family_restroom_rounded, apiKey: 'family'),
  Category(name: 'Fashion', icon: Icons.checkroom_rounded, apiKey: 'fashion'),
  Category(
      name: 'Fiction', icon: Icons.auto_stories_rounded, apiKey: 'fiction'),
  Category(
      name: 'Fitness', icon: Icons.fitness_center_rounded, apiKey: 'fitness'),
  Category(name: 'Food', icon: Icons.restaurant_rounded, apiKey: 'food'),
  Category(name: 'Games', icon: Icons.sports_esports_rounded, apiKey: 'games'),
  Category(name: 'Garden', icon: Icons.grass_rounded, apiKey: 'garden'),
  Category(
      name: 'Government',
      icon: Icons.account_balance_rounded,
      apiKey: 'government'),
  Category(
      name: 'Health', icon: Icons.health_and_safety_rounded, apiKey: 'health'),
  Category(
      name: 'Hinduism', icon: Icons.temple_hindu_rounded, apiKey: 'hinduism'),
  Category(name: 'History', icon: Icons.history_rounded, apiKey: 'history'),
  Category(name: 'Hobbies', icon: Icons.extension_rounded, apiKey: 'hobbies'),
  Category(name: 'Home', icon: Icons.home_rounded, apiKey: 'home'),
  Category(name: 'How-To', icon: Icons.how_to_reg_rounded, apiKey: 'how-to'),
  Category(
      name: 'Interview',
      icon: Icons.record_voice_over_rounded,
      apiKey: 'interview'),
  Category(
      name: 'Investing', icon: Icons.trending_up_rounded, apiKey: 'investing'),
  Category(name: 'Islam', icon: Icons.mosque_rounded, apiKey: 'islam'),
  Category(name: 'Judaism', icon: Icons.star_rounded, apiKey: 'judaism'),
  Category(name: 'Kids', icon: Icons.child_care_rounded, apiKey: 'kids'),
  Category(name: 'Language', icon: Icons.translate_rounded, apiKey: 'language'),
  Category(name: 'Learning', icon: Icons.school_rounded, apiKey: 'learning'),
  Category(
      name: 'Leisure', icon: Icons.beach_access_rounded, apiKey: 'leisure'),
  Category(name: 'Life', icon: Icons.favorite_rounded, apiKey: 'life'),
  Category(
      name: 'Management',
      icon: Icons.manage_accounts_rounded,
      apiKey: 'management'),
  Category(name: 'Manga', icon: Icons.menu_book_rounded, apiKey: 'manga'),
  Category(
      name: 'Marketing', icon: Icons.campaign_rounded, apiKey: 'marketing'),
  Category(
      name: 'Mathematics',
      icon: Icons.calculate_rounded,
      apiKey: 'mathematics'),
  Category(
      name: 'Medicine', icon: Icons.local_hospital_rounded, apiKey: 'medicine'),
  Category(name: 'Mental', icon: Icons.psychology_rounded, apiKey: 'mental'),
  Category(name: 'Music', icon: Icons.music_note_rounded, apiKey: 'music'),
  Category(name: 'Natural', icon: Icons.eco_rounded, apiKey: 'natural'),
  Category(name: 'Nature', icon: Icons.nature_people_rounded, apiKey: 'nature'),
  Category(name: 'News', icon: Icons.newspaper_rounded, apiKey: 'news'),
  Category(
      name: 'Non-Profit',
      icon: Icons.volunteer_activism_rounded,
      apiKey: 'non-profit'),
  Category(
      name: 'Nutrition', icon: Icons.food_bank_rounded, apiKey: 'nutrition'),
  Category(
      name: 'Parenting',
      icon: Icons.supervisor_account_rounded,
      apiKey: 'parenting'),
  Category(
      name: 'Performing',
      icon: Icons.theater_comedy_rounded,
      apiKey: 'performing'),
  Category(name: 'Pets', icon: Icons.pets_rounded, apiKey: 'pets'),
  Category(name: 'Physics', icon: Icons.biotech_rounded, apiKey: 'physics'),
  Category(name: 'Politics', icon: Icons.flag_rounded, apiKey: 'politics'),
  Category(
      name: 'Religion', icon: Icons.temple_hindu_rounded, apiKey: 'religion'),
  Category(name: 'Science', icon: Icons.science_rounded, apiKey: 'science'),
  Category(
      name: 'Self-Improvement',
      icon: Icons.self_improvement_rounded,
      apiKey: 'self-improvement'),
  Category(
      name: 'Sexuality', icon: Icons.transgender_rounded, apiKey: 'sexuality'),
  Category(name: 'Social', icon: Icons.groups_rounded, apiKey: 'social'),
  Category(
      name: 'Spirituality',
      icon: Icons.self_improvement_rounded,
      apiKey: 'spirituality'),
  Category(
      name: 'Sports', icon: Icons.sports_basketball_rounded, apiKey: 'sports'),
  Category(name: 'Stand-Up', icon: Icons.mic_rounded, apiKey: 'stand-up'),
  Category(
      name: 'Stories', icon: Icons.auto_stories_rounded, apiKey: 'stories'),
  Category(
      name: 'Video-Games',
      icon: Icons.videogame_asset_rounded,
      apiKey: 'video-games'),
  Category(
      name: 'Visual', icon: Icons.remove_red_eye_rounded, apiKey: 'visual'),
  Category(name: 'True Crime', icon: Icons.gavel_rounded, apiKey: 'true-crime'),
  Category(name: 'TV', icon: Icons.tv_rounded, apiKey: 'tv'),
];

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final isWide = wideScreenMinWidth < MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: isWide
          ? GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
