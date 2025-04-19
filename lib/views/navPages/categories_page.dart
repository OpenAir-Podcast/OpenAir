import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesPage extends ConsumerWidget {
  CategoriesPage({super.key});

  final List<String> sortedCategories = [
    'Animals',
    'Animation',
    'Arts',
    'Astronomy',
    'Automotive',
    'Aviation',
    'Beauty',
    'Books',
    'Business',
    'Careers',
    'Chemistry',
    'Christianity',
    'Comedy',
    'Commentary',
    'Courses',
    'Crafts',
    'Daily',
    'Design',
    'Drama',
    'Earth',
    'Education',
    'Entertainment',
    'Entrepreneurship',
    'Family',
    'Fashion',
    'Fiction',
    'Fitness',
    'Food',
    'Games',
    'Garden',
    'Government',
    'Health',
    'Hinduism',
    'History',
    'Hobbies',
    'Home',
    'How-To',
    'Inprov',
    'Interview',
    'Investing',
    'Islam',
    'Judaism',
    'Kids',
    'Language',
    'Learning',
    'Leisure',
    'Life',
    'Management',
    'Manga',
    'Marketing',
    'Mathematics',
    'Medicine',
    'Mental',
    'Music',
    'Natural',
    'Nature',
    'News',
    'Non-Profit',
    'Nutrition',
    'Parenting',
    'Performing',
    'Pets',
    'Physics',
    'Politics',
    'Religion',
    'Science',
    'Self-Improvement',
    'Sexuality',
    'Social',
    'Spirituality',
    'Sports',
    'Stand-Up',
    'Stories',
    'Video-Games',
    'Visual',
    'True Crime',
    'TV',
  ];

  final List<IconData> sortedIcons = [
    Icons.pets_rounded, // Animals
    Icons.animation_rounded, // Animation
    Icons.palette_rounded, // Arts
    Icons.rocket_launch_rounded, // Astronomy
    Icons.car_rental_rounded, // Automotive
    Icons.airplane_ticket_rounded, // Aviation
    Icons.face_retouching_natural_rounded, // Beauty
    Icons.book_rounded, // Books
    Icons.business_center_rounded, // Business
    Icons.work_rounded, // Careers
    Icons.science_rounded, // Chemistry
    Icons.church_rounded, // Christianity
    Icons.theater_comedy_rounded, // Comedy
    Icons.record_voice_over_rounded, // Commentary
    Icons.menu_book_rounded, // Courses
    Icons.construction_rounded, // Crafts
    Icons.today_rounded, // Daily
    Icons.design_services_rounded, // Design
    Icons.theaters_rounded, // Drama
    Icons.public_rounded, // Earth
    Icons.school_rounded, // Education
    Icons.emoji_emotions_rounded, // Entertainment
    Icons.lightbulb_rounded, // Entrepreneurship
    Icons.family_restroom_rounded, // Family
    Icons.checkroom_rounded, // Fashion
    Icons.auto_stories_rounded, // Fiction
    Icons.fitness_center_rounded, // Fitness
    Icons.restaurant_rounded, // Food
    Icons.sports_esports_rounded, // Games
    Icons.grass_rounded, // Garden
    Icons.account_balance_rounded, // Government
    Icons.health_and_safety_rounded, // Health
    Icons.temple_hindu_rounded, // Hinduism
    Icons.history_rounded, // History
    Icons.extension_rounded, // Hobbies
    Icons.home_rounded, // Home
    Icons.how_to_reg_rounded, // How-To
    Icons.mic_rounded, // Inprov
    Icons.record_voice_over_rounded, // Interview
    Icons.trending_up_rounded, // Investing
    Icons.mosque_rounded, // Islam
    Icons.star_rounded, // Judaism
    Icons.child_care_rounded, // Kids
    Icons.translate_rounded, // Language
    Icons.school_rounded, // Learning
    Icons.beach_access_rounded, // Leisure
    Icons.favorite_rounded, // Life
    Icons.manage_accounts_rounded, // Management
    Icons.menu_book_rounded, // Manga
    Icons.campaign_rounded, // Marketing
    Icons.calculate_rounded, // Mathematics
    Icons.local_hospital_rounded, // Medicine
    Icons.psychology_rounded, // Mental
    Icons.music_note_rounded, // Music
    Icons.eco_rounded, // Natural
    Icons.nature_people_rounded, // Nature
    Icons.newspaper_rounded, // News
    Icons.volunteer_activism_rounded, // Non-Profit
    Icons.food_bank_rounded, // Nutrition
    Icons.supervisor_account_rounded, // Parenting
    Icons.theater_comedy_rounded, // Performing
    Icons.pets_rounded, // Pets
    Icons.biotech_rounded, // Physics
    Icons.flag_rounded, // Politics
    Icons.temple_hindu_rounded, // Religion
    Icons.science_rounded, // Science
    Icons.self_improvement_rounded, // Self-Improvement
    Icons.transgender_rounded, // Sexuality
    Icons.groups_rounded, // Social
    Icons.self_improvement_rounded, // Spirituality
    Icons.sports_basketball_rounded, // Sports
    Icons.mic_rounded, // Stand-Up
    Icons.auto_stories_rounded, // Stories
    Icons.videogame_asset_rounded, // Video-Games
    Icons.remove_red_eye_rounded, // Visual
    Icons.gavel_rounded, // True Crime
    Icons.tv_rounded // TV
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 10.0, 4.0, 4.0),
          child: ListTile(
            title: Text(
              sortedCategories[index],
            ),
            leading: Icon(
              sortedIcons[index],
            ),
            onTap: () {
              // TODO: Handle tap on category
            },
          ),
        );
      },
    );
  }
}
