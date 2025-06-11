import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'episode_model.g.dart';

@HiveType(typeId: episodeTypeId)
class Episode extends HiveObject {
  Episode({
    required this.guid,
    required this.image,
    required this.title,
    required this.author,
    required this.datePublished,
    required this.description,
    required this.feedUrl,
    required this.duration,
    required this.size,
    required this.podcastId,
    required this.enclosureLength,
    required this.enclosureUrl,
  });

  @HiveField(0)
  String guid;

  @HiveField(1)
  String image;

  @HiveField(2)
  String title;

  @HiveField(3)
  String author;

  @HiveField(4)
  int datePublished;

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

  @HiveField(10)
  int enclosureLength;

  @HiveField(11)
  String enclosureUrl;

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        guid: json["guid"],
        image: json["feedImage"],
        title: json["title"],
        author: json["author"],
        datePublished: json["datePublished"],
        description: json["description"],
        feedUrl: json["feedUrl"],
        duration: json["duration"],
        size: json["size"],
        podcastId: json["podcastId"],
        enclosureLength: json["enclosureLength"],
        enclosureUrl: json["enclosureUrl"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
        'feedImage': image,
        'title': title,
        'author': author,
        'datePublished': datePublished,
        'description': description,
        'feedUrl': feedUrl,
        'duration': duration,
        'size': size,
        'podcastId': podcastId,
        'enclosureLength': enclosureLength,
        'enclosureUrl': enclosureUrl,
      };
}
