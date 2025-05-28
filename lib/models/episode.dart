import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'episode.g.dart';

@HiveType(typeId: episodeTypeId)
class Episode extends HiveObject {
  Episode({
    required this.guid,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.datePublished,
    required this.description,
    required this.feedUrl,
    required this.duration,
    required this.size,
    required this.podcastId,
  });

  @HiveField(0)
  String guid;

  @HiveField(1)
  String imageUrl;

  @HiveField(2)
  String title;

  @HiveField(3)
  String author;

  @HiveField(4)
  String datePublished;

  @HiveField(5)
  String description;

  @HiveField(6)
  String feedUrl;

  @HiveField(7)
  String duration;

  @HiveField(8)
  String size;

  @HiveField(9)
  String podcastId;

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        guid: json["guid"],
        imageUrl: json["imageUrl"],
        title: json["title"],
        author: json["author"],
        datePublished: json["datePublished"],
        description: json["description"],
        feedUrl: json["feedUrl"],
        duration: json["duration"],
        size: json["size"],
        podcastId: json["podcastId"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
        'imageUrl': imageUrl,
        'title': title,
        'author': author,
        'datePublished': datePublished,
        'description': description,
        'feedUrl': feedUrl,
        'duration': duration,
        'size': size,
        'podcastId': podcastId,
      };
}
