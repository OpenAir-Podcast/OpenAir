import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'search_cache_model.g.dart';

@HiveType(typeId: searchCacheTypeId)
class SearchCacheModel extends HiveObject {
  @HiveField(0)
  final String query;

  @HiveField(1)
  final Map<String, dynamic> results;

  @HiveField(2)
  final DateTime timestamp;

  SearchCacheModel({
    required this.query,
    required this.results,
    required this.timestamp,
  });

  bool get isExpired {
    final difference = DateTime.now().difference(timestamp);
    return difference.inHours >= 24;
  }
}
