import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/desktop/player/banner_audio_player.dart';
import 'package:openair/views/desktop/widgets/podcast_card.dart';

// Create a FutureProvider to fetch the podcast data
final podcastDataByCategoryProvider = FutureProvider.family
    .autoDispose<FetchDataModel, String>((ref, category) async {
  final FetchDataModel? categoryPodcastData = await ref
      .read(openAirProvider)
      .hiveService
      .getCategoryPodcast(category.replaceAll(' ', ''));

  if (categoryPodcastData != null) {
    return categoryPodcastData;
  }

  final data =
      await ref.watch(podcastIndexProvider).getPodcastsByCategory(category);

  return FetchDataModel.fromJson(data);
});

class CategoryPage extends ConsumerWidget {
  const CategoryPage({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late String cat;

    if (Translations.of(context).text('education') == category) {
      cat = 'Education';
    } else if (Translations.of(context).text('health') == category) {
      cat = 'Health';
    } else if (Translations.of(context).text('technology') == category) {
      cat = 'Technology';
    } else if (Translations.of(context).text('sports') == category) {
      cat = 'Sports';
    }
    // For categories page
    else if (Translations.of(context).text('categoryAnimals') == category) {
      cat = 'Animals';
    } else if (Translations.of(context).text('categoryAnimation') == category) {
      cat = 'Animation';
    } else if (Translations.of(context).text('categoryArts') == category) {
      cat = 'Arts';
    } else if (Translations.of(context).text('categoryAstronomy') == category) {
      cat = 'Astronomy';
    } else if (Translations.of(context).text('categoryAutomotive') ==
        category) {
      cat = 'Automotive';
    } else if (Translations.of(context).text('categoryAviation') == category) {
      cat = 'Aviation';
    } else if (Translations.of(context).text('categoryBeauty') == category) {
      cat = 'Beauty';
    } else if (Translations.of(context).text('categoryBooks') == category) {
      cat = 'Books';
    } else if (Translations.of(context).text('categoryBusiness') == category) {
      cat = 'Business';
    } else if (Translations.of(context).text('categoryCareers') == category) {
      cat = 'Careers';
    } else if (Translations.of(context).text('categoryChemistry') == category) {
      cat = 'Chemistry';
    } else if (Translations.of(context).text('categoryChristianity') ==
        category) {
      cat = 'Christianity';
    } else if (Translations.of(context).text('categoryComedy') == category) {
      cat = 'Comedy';
    } else if (Translations.of(context).text('categoryCommentary') ==
        category) {
      cat = 'Commentary';
    } else if (Translations.of(context).text('categoryCourses') == category) {
      cat = 'Courses';
    } else if (Translations.of(context).text('categoryCrafts') == category) {
      cat = 'Crafts';
    } else if (Translations.of(context).text('categoryDaily') == category) {
      cat = 'Daily';
    } else if (Translations.of(context).text('categoryDesign') == category) {
      cat = 'Design';
    } else if (Translations.of(context).text('categoryDrama') == category) {
      cat = 'Drama';
    } else if (Translations.of(context).text('categoryEarth') == category) {
      cat = 'Earth';
    } else if (Translations.of(context).text('categoryEducation') == category) {
      cat = 'Education';
    } else if (Translations.of(context).text('categoryEntertainment') ==
        category) {
      cat = 'Entertainment';
    } else if (Translations.of(context).text('categoryEntrepreneurship') ==
        category) {
      cat = 'Entrepreneurship';
    } else if (Translations.of(context).text('categoryFamily') == category) {
      cat = 'Family';
    } else if (Translations.of(context).text('categoryFashion') == category) {
      cat = 'Fashion';
    } else if (Translations.of(context).text('categoryFiction') == category) {
      cat = 'Fiction';
    } else if (Translations.of(context).text('categoryFitness') == category) {
      cat = 'Fitness';
    } else if (Translations.of(context).text('categoryFood') == category) {
      cat = 'Food';
    } else if (Translations.of(context).text('categoryGames') == category) {
      cat = 'Games';
    } else if (Translations.of(context).text('categoryGarden') == category) {
      cat = 'Garden';
    } else if (Translations.of(context).text('categoryGovernment') ==
        category) {
      cat = 'Government';
    } else if (Translations.of(context).text('categoryHealth') == category) {
      cat = 'Health';
    } else if (Translations.of(context).text('categoryHinduism') == category) {
      cat = 'Hinduism';
    } else if (Translations.of(context).text('categoryHistory') == category) {
      cat = 'History';
    } else if (Translations.of(context).text('categoryHobbies') == category) {
      cat = 'Hobbies';
    } else if (Translations.of(context).text('categoryHome') == category) {
      cat = 'Home';
    } else if (Translations.of(context).text('categoryHowTo') == category) {
      cat = 'How To';
    } else if (Translations.of(context).text('categoryInterviews') ==
        category) {
      cat = 'Interviews';
    } else if (Translations.of(context).text('categoryInvesting') == category) {
      cat = 'Investing';
    } else if (Translations.of(context).text('categoryIslam') == category) {
      cat = 'Islam';
    } else if (Translations.of(context).text('categoryJudaism') == category) {
      cat = 'Judaism';
    } else if (Translations.of(context).text('categoryKids') == category) {
      cat = 'Kids';
    } else if (Translations.of(context).text('categoryLanguage') == category) {
      cat = 'Language';
    } else if (Translations.of(context).text('categoryLearning') == category) {
      cat = 'Learning';
    } else if (Translations.of(context).text('categoryLeisure') == category) {
      cat = 'Leisure';
    } else if (Translations.of(context).text('categoryLife') == category) {
      cat = 'Life';
    } else if (Translations.of(context).text('categoryManagement') ==
        category) {
      cat = 'Management';
    } else if (Translations.of(context).text('categoryManga') == category) {
      cat = 'Manga';
    } else if (Translations.of(context).text('categoryMarketing') == category) {
      cat = 'Marketing';
    } else if (Translations.of(context).text('categoryMathematics') ==
        category) {
      cat = 'Mathematics';
    } else if (Translations.of(context).text('categoryMedicine') == category) {
      cat = 'Medicine';
    } else if (Translations.of(context).text('categoryMental') == category) {
      cat = 'Mental';
    } else if (Translations.of(context).text('categoryMusic') == category) {
      cat = 'Music';
    } else if (Translations.of(context).text('categoryNatural') == category) {
      cat = 'Natural';
    } else if (Translations.of(context).text('categoryNature') == category) {
      cat = 'Nature';
    } else if (Translations.of(context).text('categoryNews') == category) {
      cat = 'News';
    } else if (Translations.of(context).text('categoryNonProfit') == category) {
      cat = 'Non-Profit';
    } else if (Translations.of(context).text('categoryNutrition') == category) {
      cat = 'Nutrition';
    } else if (Translations.of(context).text('categoryParenting') == category) {
      cat = 'Parenting';
    } else if (Translations.of(context).text('categoryPerforming') ==
        category) {
      cat = 'Performing';
    } else if (Translations.of(context).text('categoryPets') == category) {
      cat = 'Pets';
    } else if (Translations.of(context).text('categoryPhysics') == category) {
      cat = 'Physics';
    } else if (Translations.of(context).text('categoryPolitics') == category) {
      cat = 'Politics';
    } else if (Translations.of(context).text('categoryReligion') == category) {
      cat = 'Religion';
    } else if (Translations.of(context).text('categoryScience') == category) {
      cat = 'Science';
    } else if (Translations.of(context).text('categorySelfImprovement') ==
        category) {
      cat = 'Self Improvement';
    } else if (Translations.of(context).text('categorySexuality') == category) {
      cat = 'Sexuality';
    } else if (Translations.of(context).text('categorySocial') == category) {
      cat = 'Social';
    } else if (Translations.of(context).text('categorySpirituality') ==
        category) {
      cat = 'Spirituality';
    } else if (Translations.of(context).text('categorySports') == category) {
      cat = 'Sports';
    } else if (Translations.of(context).text('categoryStandUp') == category) {
      cat = 'Stand-Up';
    } else if (Translations.of(context).text('categoryStories') == category) {
      cat = 'Stories';
    } else if (Translations.of(context).text('categoryVideoGames') ==
        category) {
      cat = 'Video Games';
    } else if (Translations.of(context).text('categoryVisual') == category) {
      cat = 'Visual';
    } else if (Translations.of(context).text('categoryTrueCrime') == category) {
      cat = 'True Crime';
    } else if (Translations.of(context).text('categoryTV') == category) {
      cat = 'TV';
    }

    final podcastDataAsyncValue = ref.watch(podcastDataByCategoryProvider(cat));

    return podcastDataAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(category),
        ),
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
                    ref.invalidate(podcastIndexProvider);
                  },
                  child: Text(Translations.of(context).text('retry')),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(category),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  tooltip: Translations.of(context).text('refresh'),
                  onPressed: () {
                    // TODO Implement refreash mechanic
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: snapshot.count,
              itemBuilder: (context, index) {
                return PodcastCard(
                  podcastItem: snapshot.feeds[index],
                );
              },
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: ref.watch(audioProvider).isPodcastSelected
                ? bannerAudioPlayerHeight
                : 0.0,
            child: ref.watch(audioProvider).isPodcastSelected
                ? const BannerAudioPlayer()
                : const SizedBox(),
          ),
        );
      },
    );
  }
}
