import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'feed_model.g.dart';

@HiveType(typeId: feedTypeId)
class FeedModel extends HiveObject {
  FeedModel({
    required this.guid,
  });

  @HiveField(0)
  String guid;

  factory FeedModel.fromJson(Map<String, dynamic> json) => FeedModel(
        guid: json["guid"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
      };
}
