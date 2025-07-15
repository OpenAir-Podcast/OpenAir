import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';
import 'package:openair/models/podcast_model.dart';

part 'fetch_data_model.g.dart';

@HiveType(typeId: fetchDataTypeId)
class FetchDataModel extends HiveObject {
  FetchDataModel({
    required this.count,
    required this.feeds,
    required this.status,
    required this.max,
    required this.since,
    required this.description,
  });

  @HiveField(0)
  String status;

  @HiveField(1)
  List<PodcastModel> feeds;

  @HiveField(2)
  int count;

  @HiveField(3)
  int? max;

  @HiveField(4)
  int since;

  @HiveField(5)
  String description;

  factory FetchDataModel.fromJson(Map<String, dynamic> json) {
    List<PodcastModel> feeds = [];

    if (json['feeds'] != null) {
      feeds =
          (json['feeds'] as List).map((i) => PodcastModel.fromJson(i)).toList();
    }

    final int maxTmp = json['max'].runtimeType == int
        ? json['max']
        : json['max'] == null
            ? -1
            : int.parse(json['max']);

    final int sinceTmp = json['since'] ?? -1;

    return FetchDataModel(
      count: json['count'],
      feeds: feeds,
      status: json['status'],
      max: maxTmp,
      since: sinceTmp,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'feeds': feeds,
        'status': status,
        'max': max,
        'since': since,
        'description': description,
      };

  @override
  String toString() {
    return '''
    count: $count,
    feeds: $feeds,
    status: $status,
    max: $max,
    since: $since,
    description: $description,
    ''';
  }
}
