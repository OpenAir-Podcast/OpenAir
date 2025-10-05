import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
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

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({
    super.key,
    required this.category,
  });

  final String category;

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    late String cat;

    if (Translations.of(context).text('education') == widget.category) {
      cat = 'Education';
    } else if (Translations.of(context).text('health') == widget.category) {
      cat = 'Health';
    } else if (Translations.of(context).text('technology') == widget.category) {
      cat = 'Technology';
    } else if (Translations.of(context).text('sports') == widget.category) {
      cat = 'Sports';
    }
    // For categories page
    else if (Translations.of(context).text('categoryAnimals') ==
        widget.category) {
      cat = 'Animals';
    } else if (Translations.of(context).text('categoryAnimation') ==
        widget.category) {
      cat = 'Animation';
    } else if (Translations.of(context).text('categoryArts') ==
        widget.category) {
      cat = 'Arts';
    } else if (Translations.of(context).text('categoryAstronomy') ==
        widget.category) {
      cat = 'Astronomy';
    } else if (Translations.of(context).text('categoryAutomotive') ==
        widget.category) {
      cat = 'Automotive';
    } else if (Translations.of(context).text('categoryAviation') ==
        widget.category) {
      cat = 'Aviation';
    } else if (Translations.of(context).text('categoryBeauty') ==
        widget.category) {
      cat = 'Beauty';
    } else if (Translations.of(context).text('categoryBooks') ==
        widget.category) {
      cat = 'Books';
    } else if (Translations.of(context).text('categoryBusiness') ==
        widget.category) {
      cat = 'Business';
    } else if (Translations.of(context).text('categoryCareers') ==
        widget.category) {
      cat = 'Careers';
    } else if (Translations.of(context).text('categoryChemistry') ==
        widget.category) {
      cat = 'Chemistry';
    } else if (Translations.of(context).text('categoryChristianity') ==
        widget.category) {
      cat = 'Christianity';
    } else if (Translations.of(context).text('categoryComedy') ==
        widget.category) {
      cat = 'Comedy';
    } else if (Translations.of(context).text('categoryCommentary') ==
        widget.category) {
      cat = 'Commentary';
    } else if (Translations.of(context).text('categoryCourses') ==
        widget.category) {
      cat = 'Courses';
    } else if (Translations.of(context).text('categoryCrafts') ==
        widget.category) {
      cat = 'Crafts';
    } else if (Translations.of(context).text('categoryDaily') ==
        widget.category) {
      cat = 'Daily';
    } else if (Translations.of(context).text('categoryDesign') ==
        widget.category) {
      cat = 'Design';
    } else if (Translations.of(context).text('categoryDrama') ==
        widget.category) {
      cat = 'Drama';
    } else if (Translations.of(context).text('categoryEarth') ==
        widget.category) {
      cat = 'Earth';
    } else if (Translations.of(context).text('categoryEducation') ==
        widget.category) {
      cat = 'Education';
    } else if (Translations.of(context).text('categoryEntertainment') ==
        widget.category) {
      cat = 'Entertainment';
    } else if (Translations.of(context).text('categoryEntrepreneurship') ==
        widget.category) {
      cat = 'Entrepreneurship';
    } else if (Translations.of(context).text('categoryFamily') ==
        widget.category) {
      cat = 'Family';
    } else if (Translations.of(context).text('categoryFashion') ==
        widget.category) {
      cat = 'Fashion';
    } else if (Translations.of(context).text('categoryFiction') ==
        widget.category) {
      cat = 'Fiction';
    } else if (Translations.of(context).text('categoryFitness') ==
        widget.category) {
      cat = 'Fitness';
    } else if (Translations.of(context).text('categoryFood') ==
        widget.category) {
      cat = 'Food';
    } else if (Translations.of(context).text('categoryGames') ==
        widget.category) {
      cat = 'Games';
    } else if (Translations.of(context).text('categoryGarden') ==
        widget.category) {
      cat = 'Garden';
    } else if (Translations.of(context).text('categoryGovernment') ==
        widget.category) {
      cat = 'Government';
    } else if (Translations.of(context).text('categoryHealth') ==
        widget.category) {
      cat = 'Health';
    } else if (Translations.of(context).text('categoryHinduism') ==
        widget.category) {
      cat = 'Hinduism';
    } else if (Translations.of(context).text('categoryHistory') ==
        widget.category) {
      cat = 'History';
    } else if (Translations.of(context).text('categoryHobbies') ==
        widget.category) {
      cat = 'Hobbies';
    } else if (Translations.of(context).text('categoryHome') ==
        widget.category) {
      cat = 'Home';
    } else if (Translations.of(context).text('categoryHowTo') ==
        widget.category) {
      cat = 'How To';
    } else if (Translations.of(context).text('categoryInterviews') ==
        widget.category) {
      cat = 'Interviews';
    } else if (Translations.of(context).text('categoryInvesting') ==
        widget.category) {
      cat = 'Investing';
    } else if (Translations.of(context).text('categoryIslam') ==
        widget.category) {
      cat = 'Islam';
    } else if (Translations.of(context).text('categoryJudaism') ==
        widget.category) {
      cat = 'Judaism';
    } else if (Translations.of(context).text('categoryKids') ==
        widget.category) {
      cat = 'Kids';
    } else if (Translations.of(context).text('categoryLanguage') ==
        widget.category) {
      cat = 'Language';
    } else if (Translations.of(context).text('categoryLearning') ==
        widget.category) {
      cat = 'Learning';
    } else if (Translations.of(context).text('categoryLeisure') ==
        widget.category) {
      cat = 'Leisure';
    } else if (Translations.of(context).text('categoryLife') ==
        widget.category) {
      cat = 'Life';
    } else if (Translations.of(context).text('categoryManagement') ==
        widget.category) {
      cat = 'Management';
    } else if (Translations.of(context).text('categoryManga') ==
        widget.category) {
      cat = 'Manga';
    } else if (Translations.of(context).text('categoryMarketing') ==
        widget.category) {
      cat = 'Marketing';
    } else if (Translations.of(context).text('categoryMathematics') ==
        widget.category) {
      cat = 'Mathematics';
    } else if (Translations.of(context).text('categoryMedicine') ==
        widget.category) {
      cat = 'Medicine';
    } else if (Translations.of(context).text('categoryMental') ==
        widget.category) {
      cat = 'Mental';
    } else if (Translations.of(context).text('categoryMusic') ==
        widget.category) {
      cat = 'Music';
    } else if (Translations.of(context).text('categoryNatural') ==
        widget.category) {
      cat = 'Natural';
    } else if (Translations.of(context).text('categoryNature') ==
        widget.category) {
      cat = 'Nature';
    } else if (Translations.of(context).text('categoryNews') ==
        widget.category) {
      cat = 'News';
    } else if (Translations.of(context).text('categoryNonProfit') ==
        widget.category) {
      cat = 'Non-Profit';
    } else if (Translations.of(context).text('categoryNutrition') ==
        widget.category) {
      cat = 'Nutrition';
    } else if (Translations.of(context).text('categoryParenting') ==
        widget.category) {
      cat = 'Parenting';
    } else if (Translations.of(context).text('categoryPerforming') ==
        widget.category) {
      cat = 'Performing';
    } else if (Translations.of(context).text('categoryPets') ==
        widget.category) {
      cat = 'Pets';
    } else if (Translations.of(context).text('categoryPhysics') ==
        widget.category) {
      cat = 'Physics';
    } else if (Translations.of(context).text('categoryPolitics') ==
        widget.category) {
      cat = 'Politics';
    } else if (Translations.of(context).text('categoryReligion') ==
        widget.category) {
      cat = 'Religion';
    } else if (Translations.of(context).text('categoryScience') ==
        widget.category) {
      cat = 'Science';
    } else if (Translations.of(context).text('categorySelfImprovement') ==
        widget.category) {
      cat = 'Self Improvement';
    } else if (Translations.of(context).text('categorySexuality') == widget.category) {
      cat = 'Sexuality';
    } else if (Translations.of(context).text('categorySocial') == widget.category) {
      cat = 'Social';
    } else if (Translations.of(context).text('categorySpirituality') == widget.category) {
      cat = 'Spirituality';
    } else if (Translations.of(context).text('categorySports') == widget.category) {
      cat = 'Sports';
    } else if (Translations.of(context).text('categoryStandUp') == widget.category) {
      cat = 'Stand-Up';
    } else if (Translations.of(context).text('categoryStories') == widget.category) {
      cat = 'Stories';
    } else if (Translations.of(context).text('categoryVideoGames') == widget.category) {
      cat = 'Video Games';
    } else if (Translations.of(context).text('categoryVisual') == widget.category) {
      cat = 'Visual';
    } else if (Translations.of(context).text('categoryTrueCrime') == widget.category) {
      cat = 'True Crime';
    } else if (Translations.of(context).text('categoryTV') == widget.category) {
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
          title: Text(widget.category),
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
            title: Text(widget.category),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  tooltip: Translations.of(context).text('refresh'),
                  onPressed: () {
                    ref
                        .watch(hiveServiceProvider)
                        .removeCategory(widget.category);

                    ref.invalidate(
                        podcastDataByCategoryProvider(widget.category));
                    Future.delayed(const Duration(seconds: 1), () async {
                      setState(() {});
                    });
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
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
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
