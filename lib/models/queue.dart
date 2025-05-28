import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'queue.g.dart';

@HiveType(typeId: queueTypeId)
class Queue extends HiveObject {
  Queue({
    required this.guid,
    required this.pos,
  });

  @HiveField(0)
  String guid;

  @HiveField(1)
  int pos;

  factory Queue.fromJson(Map<String, dynamic> json) => Queue(
        guid: json["guid"],
        pos: json["pos"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
        'pos': pos,
      };
}
