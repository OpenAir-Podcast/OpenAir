import 'package:hive_ce/hive.dart';

class BookmarkService {
  static const String _boxName = 'bookmarks';

  Future<Box> _box() async => Hive.openBox(_boxName);

  String _key(String episodeGuid, int positionMs) =>
      '$episodeGuid::$positionMs';

  Future<void> addBookmark({
    required String episodeGuid,
    required String episodeTitle,
    required Duration position,
    String? note,
  }) async {
    final box = await _box();
    final key = _key(episodeGuid, position.inMilliseconds);
    await box.put(key, {
      'episodeGuid': episodeGuid,
      'episodeTitle': episodeTitle,
      'positionMs': position.inMilliseconds,
      'note': note,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getBookmarks(String episodeGuid) async {
    final box = await _box();
    final result = <Map<String, dynamic>>[];
    for (final k in box.keys) {
      final v = box.get(k);
      if (v is Map && v['episodeGuid'] == episodeGuid) {
        result.add(Map<String, dynamic>.from(v)..['key'] = k);
      }
    }
    result.sort((a, b) =>
        (a['positionMs'] as int).compareTo(b['positionMs'] as int));
    return result;
  }

  Future<void> removeBookmark(dynamic key) async {
    final box = await _box();
    await box.delete(key);
  }
}