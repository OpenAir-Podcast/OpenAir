import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final fyydProvider = Provider((ref) => FyydProvider());

class FyydProvider {
  final String? _accessToken = dotenv.env['FYYD_ACCESS_TOKEN'];
  static const String _baseUrl = 'https://api.fyyd.de/0.2';

  late Dio _dio;

  FyydProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken == null) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Missing FYYD_ACCESS_TOKEN in .env file',
            ),
          );
        }

        options.headers['Authorization'] = 'Bearer $_accessToken';
        options.headers['User-Agent'] =
            'OpenAirPodcastApp/1.0.0 (https://github.com/OpenAir-Podcast/OpenAir)';
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
    ));
  }

  Future<List<dynamic>> searchPodcasts(String query) async {
    try {
      final response = await _dio.get(
        '/search/podcast',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load podcasts');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getFeaturedPodcasts() async {
    try {
      final response = await _dio.get(
        '/feature/podcast/hot',
        queryParameters: {
          'count': 12,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load featured podcasts');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getDiscoveryPodcasts() async {
    try {
      final response = await _dio.get(
        '/feature/podcast/hot',
        queryParameters: {
          'count': 50,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load featured podcasts');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getPodcastXml(String xmlUrl, [BuildContext? context]) async {
    try {
      // Using a new Dio instance to avoid sending fyyd-specific headers
      final dio = Dio();
      final response = await dio.get(
        xmlUrl,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode == 200) {
        return await response.data;
      } else {
        throw Exception('Failed to load podcast XML from $xmlUrl');
      }
    } catch (e) {
      debugPrint('Error loading podcast XML: $e');
      rethrow;
    }
  }
}
