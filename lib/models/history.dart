import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'history.g.dart';

@HiveType(typeId: historyTypeId)
class History extends HiveObject {
  History({
    required this.guid,
  });

  @HiveField(0)
  String guid;

  factory History.fromJson(Map<String, dynamic> json) => History(
        guid: json["guid"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
      };
}
