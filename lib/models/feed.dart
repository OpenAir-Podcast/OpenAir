import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'feed.g.dart';

@HiveType(typeId: feedTypeId)
class Feed extends HiveObject {
  Feed({
    required this.guid,
  });

  @HiveField(0)
  String guid;

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        guid: json["guid"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
      };
}
