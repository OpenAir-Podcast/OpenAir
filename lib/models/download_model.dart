import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'download_model.g.dart';

@HiveType(typeId: downloadTypeId)
class Download extends HiveObject {
  Download({
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
    required this.downloadDate,
    required this.fileName,
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

  @HiveField(12)
  int downloadDate;

  @HiveField(13)
  String fileName;

  factory Download.fromJson(Map<String, dynamic> json) => Download(
        guid: json["guid"],
        image: json["image"],
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
        downloadDate: json["downloadDate"],
        fileName: json["fileName"],
      );

  Map<String, dynamic> toJson() => {
        'guid': guid,
        'image': image,
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
        'downloadDate': downloadDate,
        'fileName': fileName,
      };
}
