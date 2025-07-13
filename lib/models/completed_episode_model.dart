import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'completed_episode_model.g.dart';

@HiveType(typeId: completedEpisodeTypeId)
class CompletedEpisodeModel extends HiveObject {
  CompletedEpisodeModel({
    required this.guid,
  });

  @HiveField(0)
  String guid;

  factory CompletedEpisodeModel.fromJson(Map<String, dynamic> json) =>
      CompletedEpisodeModel(
        guid: json["guid"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
      };
}
