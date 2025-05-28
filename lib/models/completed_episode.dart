import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'completed_episode.g.dart';

@HiveType(typeId: completedEpisodeTypeId)
class CompletedEpisode extends HiveObject {
  CompletedEpisode({
    required this.guid,
  });

  @HiveField(0)
  String guid;

  factory CompletedEpisode.fromJson(Map<String, dynamic> json) =>
      CompletedEpisode(
        guid: json["guid"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
      };
}
