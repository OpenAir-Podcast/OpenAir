import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'download.g.dart';

@HiveType(typeId: downloadTypeId)
class Download extends HiveObject {
  Download({
    required this.guid,
  });

  @HiveField(0)
  String guid;

  factory Download.fromJson(Map<String, dynamic> json) => Download(
        guid: json["guid"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
      };
}
