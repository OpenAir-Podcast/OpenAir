import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';

final podcastIndexProvider = Provider(
  (ref) => PodcastIndexProvider(ref),
);

class PodcastIndexProvider {
  final String? podcastIndexApi = dotenv.env['PODCAST_INDEX_API_KEY'];
  final String? podcastIndexSecret = dotenv.env['PODCAST_INDEX_API_SECRET'];
  final String? podcastIndexUserAgent = dotenv.env['PODCAST_USER_AGENT'];

  late int unixTime;
  late String newUnixTime;

  late Digest digest;
  late Map<String, String> headers;
  late Dio _dio;

  final Ref ref;

  PodcastIndexProvider(this.ref) {
    unixTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    newUnixTime = unixTime.toString();

    final firstChunk = utf8.encode(podcastIndexApi!);
    final secondChunk = utf8.encode(podcastIndexSecret!);
    final thirdChunk = utf8.encode(newUnixTime);

    final output = AccumulatorSink<Digest>();
    final ByteConversionSink input = sha1.startChunkedConversion(output);
    input.add(firstChunk);
    input.add(secondChunk);
    input.add(thirdChunk);
    input.close();

    digest = output.events.single;

    headers = {
      "X-Auth-Date": newUnixTime,
      "X-Auth-Key": podcastIndexApi!,
      "Authorization": digest.toString(),
      "User-Agent": podcastIndexUserAgent!,
    };

    _dio = Dio(BaseOptions(headers: headers));
  }

  Future<Response<T>> _retry<T>(
    Future<Response<T>> Function() requestFactory, {
    int retries = 4,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await requestFactory();
      } on DioException catch (e) {
        attempt++;
        if (attempt > retries) {
          debugPrint('DioError after $retries retries: ${e.message}');
          rethrow;
        }

        debugPrint(
            'DioError attempt $attempt, retrying in $delay: ${e.message}');

        await Future.delayed(delay);
        // Exponential backoff for subsequent retries
        delay *= 2;
      }
    }
  }

  /// This method is used to get the list of podcasts from the API.
  ///
  /// The API uses a combination of the API key, secret key, and a Unix
  /// timestamp to generate a SHA1 hash. The hash is then used to authenticate
  /// the request.
  ///
  /// The API key is hard-coded in the app, and the secret key is stored in the
  /// [ApiKeys] class. The Unix timestamp is generated by the app when the
  /// request is made.
  ///
  /// The request is made to the API, and the response is parsed as JSON. The
  /// response is then returned as a [Map<String, dynamic>].

  Future<Map<String, dynamic>> getEpisodesByFeedUrl(
      String podcastFeedUrl) async {
    String cat = podcastFeedUrl.replaceAll(' ', '%20');

    String url =
        'https://api.podcastindex.org/api/1.0/episodes/byfeedurl?url=$cat&pretty';

    final response = await _retry(() => _dio.get(url));
    return response.data;
  }

  Future<int> getPodcastEpisodeCountByPodcastId(int podcastId) async {
    String url =
        'https://api.podcastindex.org/api/1.0/podcasts/byfeedid?id=$podcastId&pretty';

    final response = await _retry(() => _dio.get(url));
    return response.data['feed']['episodeCount'];
  }

  Future<int> getPodcastEpisodeCountByTitle(String name) async {
    String cat = name
        .replaceAll(' ', '+')
        .replaceAll('/', '%2F')
        .replaceAll('&', '%26')
        .replaceAll('(', '%28')
        .replaceAll(')', '%29')
        .trim();

    String url = 'https://api.podcastindex.org/api/1.0/search/bytitle?q=$cat';
    String fullUrl = '$url&pretty';

    final response = await _retry(() => _dio.get(fullUrl));
    final feeds = response.data['feeds'];

    if (feeds is List && feeds.isNotEmpty) {
      // The 'feeds' key returns a list of feeds.
      // We'll assume the first one is the one we want.
      final count = feeds.first['episodeCount'];
      return count;
    } else {
      // Return 0 or throw an exception if no feeds are found.
      return 0;
    }
  }

  Future<Map<String, dynamic>> getPodcastsByCategory(String category) async {
    String cat = category.replaceAll(' ', '%20').toLowerCase();

    String url =
        'https://api.podcastindex.org/api/1.0/recent/feeds?cat=$cat&lang=en&pretty';

    final response = await _retry(() => _dio.get(url));
    ref
        .read(hiveServiceProvider)
        .putCategoryPodcast(category.replaceAll(' ', ''), response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> getTrendingPodcasts() async {
    String url =
        'https://api.podcastindex.org/api/1.0/podcasts/trending?max=${ref.read(openAirProvider).config.max}&lang=en&pretty';

    final response = await _retry(() => _dio.get(url));
    ref.read(hiveServiceProvider).putTrendingPodcast(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> getTopPodcasts() async {
    const url =
        'https://api.podcastindex.org/api/1.0/recent/feeds?lang=en&pretty';

    final response = await _retry(() => _dio.get(url));
    ref.read(hiveServiceProvider).putTopFeaturedPodcast(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> getEducationPodcasts() async {
    const url =
        'https://api.podcastindex.org/api/1.0/recent/feeds?cat=education&lang=en&pretty';

    final response = await _retry(() => _dio.get(url));
    ref
        .read(hiveServiceProvider)
        .putCategoryPodcast('Education', response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> getHealthPodcasts() async {
    const url =
        'https://api.podcastindex.org/api/1.0/recent/feeds?cat=health&lang=en&pretty';

    final response = await _retry(() => _dio.get(url));
    ref.read(hiveServiceProvider).putCategoryPodcast('Health', response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> getTechnologyPodcasts() async {
    const url =
        'https://api.podcastindex.org/api/1.0/recent/feeds?cat=technology&lang=en&pretty';

    final response = await _retry(() => _dio.get(url));
    ref
        .read(hiveServiceProvider)
        .putCategoryPodcast('Technology', response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> getSportsPodcasts() async {
    const url =
        'https://api.podcastindex.org/api/1.0/recent/feeds?cat=sports&lang=en&pretty';

    final response = await _retry(() => _dio.get(url));
    ref.read(hiveServiceProvider).putCategoryPodcast('Sports', response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> searchPodcasts(String title) async {
    String cat = title
        .replaceAll(' ', '+')
        .replaceAll('/', '%2F')
        .replaceAll('&', '%26')
        .replaceAll('(', '%28')
        .replaceAll(')', '%29')
        .trim();

    String url =
        'https://api.podcastindex.org/api/1.0/search/byterm?max=${ref.read(openAirProvider).config.max}&q=$cat';
    String fullUrl = '$url&pretty';
    debugPrint(fullUrl);

    final response = await _retry(() => _dio.get(fullUrl));
    return response.data;
  }
}
