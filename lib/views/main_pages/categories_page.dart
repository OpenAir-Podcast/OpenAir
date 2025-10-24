import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/category_page.dart';
import 'package:openair/components/no_connection.dart';

final getConnectionStatusProvider = FutureProvider<bool>((ref) async {
  final podcastIndexService = ref.read(openAirProvider);
  return await podcastIndexService.getConnectionStatus();
});

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
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
  Widget build(BuildContext context) {
    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    final List<String> sortedCategories = [
      Translations.of(context).text('categoryAnimals'),
      Translations.of(context).text('categoryAnimation'),
      Translations.of(context).text('categoryArts'),
      Translations.of(context).text('categoryAstronomy'),
      Translations.of(context).text('categoryAutomotive'),
      Translations.of(context).text('categoryAviation'),
      Translations.of(context).text('categoryBeauty'),
      Translations.of(context).text('categoryBooks'),
      Translations.of(context).text('categoryBusiness'),
      Translations.of(context).text('categoryCareers'),
      Translations.of(context).text('categoryChemistry'),
      Translations.of(context).text('categoryChristianity'),
      Translations.of(context).text('categoryComedy'),
      Translations.of(context).text('categoryCommentary'),
      Translations.of(context).text('categoryCourses'),
      Translations.of(context).text('categoryCrafts'),
      Translations.of(context).text('categoryDaily'),
      Translations.of(context).text('categoryDesign'),
      Translations.of(context).text('categoryDrama'),
      Translations.of(context).text('categoryEarth'),
      Translations.of(context).text('categoryEducation'),
      Translations.of(context).text('categoryEntertainment'),
      Translations.of(context).text('categoryEntrepreneurship'),
      Translations.of(context).text('categoryFamily'),
      Translations.of(context).text('categoryFashion'),
      Translations.of(context).text('categoryFiction'),
      Translations.of(context).text('categoryFitness'),
      Translations.of(context).text('categoryFood'),
      Translations.of(context).text('categoryGames'),
      Translations.of(context).text('categoryGarden'),
      Translations.of(context).text('categoryGovernment'),
      Translations.of(context).text('categoryHealth'),
      Translations.of(context).text('categoryHinduism'),
      Translations.of(context).text('categoryHistory'),
      Translations.of(context).text('categoryHobbies'),
      Translations.of(context).text('categoryHome'),
      Translations.of(context).text('categoryHowTo'),
      Translations.of(context).text('categoryInterviews'),
      Translations.of(context).text('categoryInvesting'),
      Translations.of(context).text('categoryIslam'),
      Translations.of(context).text('categoryJudaism'),
      Translations.of(context).text('categoryKids'),
      Translations.of(context).text('categoryLanguage'),
      Translations.of(context).text('categoryLearning'),
      Translations.of(context).text('categoryLeisure'),
      Translations.of(context).text('categoryLife'),
      Translations.of(context).text('categoryManagement'),
      Translations.of(context).text('categoryManga'),
      Translations.of(context).text('categoryMarketing'),
      Translations.of(context).text('categoryMathematics'),
      Translations.of(context).text('categoryMedicine'),
      Translations.of(context).text('categoryMental'),
      Translations.of(context).text('categoryMusic'),
      Translations.of(context).text('categoryNatural'),
      Translations.of(context).text('categoryNature'),
      Translations.of(context).text('categoryNews'),
      Translations.of(context).text('categoryNonProfit'),
      Translations.of(context).text('categoryNutrition'),
      Translations.of(context).text('categoryParenting'),
      Translations.of(context).text('categoryPerforming'),
      Translations.of(context).text('categoryPets'),
      Translations.of(context).text('categoryPhysics'),
      Translations.of(context).text('categoryPolitics'),
      Translations.of(context).text('categoryReligion'),
      Translations.of(context).text('categoryScience'),
      Translations.of(context).text('categorySelfImprovement'),
      Translations.of(context).text('categorySexuality'),
      Translations.of(context).text('categorySocial'),
      Translations.of(context).text('categorySpirituality'),
      Translations.of(context).text('categorySports'),
      Translations.of(context).text('categoryStandUp'),
      Translations.of(context).text('categoryStories'),
      Translations.of(context).text('categoryVideoGames'),
      Translations.of(context).text('categoryVisual'),
      Translations.of(context).text('categoryTrueCrime'),
      Translations.of(context).text('categoryTV'),
    ];

    return getConnectionStatusValue.when(
      data: (data) {
        if (data == false) {
          return NoConnection();
        }

        if (MediaQuery.sizeOf(context).width > wideScreenMinWidth) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(
                          category: sortedCategories[index],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sortedIcons[index],
                          size: 48.0,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          sortedCategories[index],
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 4.0),
                  child: ListTile(
                    title: Text(
                      sortedCategories[index],
                    ),
                    leading: Icon(
                      sortedIcons[index],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryPage(
                            category: sortedCategories[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
      error: (error, stackTrace) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 75.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 20.0),
              Text(
                Translations.of(context).text('oopsAnErrorOccurred'),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Translations.of(context).text('oopsTryAgainLater'),
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 180.0,
                height: 40.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    ref.invalidate(getConnectionStatusProvider);
                  },
                  child: Text(Translations.of(context).text('retey')),
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
