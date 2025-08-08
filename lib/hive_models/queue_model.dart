import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';
import 'package:openair/hive_models/podcast_model.dart';

part 'queue_model.g.dart';

@HiveType(typeId: queueTypeId)
class QueueModel extends HiveObject {
  QueueModel({
    required this.guid,
    required this.image,
    required this.title,
    required this.author,
    required this.datePublished,
    required this.description,
    required this.feedUrl,
    required this.duration,
    required this.downloadSize,
    required this.enclosureType,
    required this.podcast,
    required this.enclosureLength,
    required this.enclosureUrl,
    required this.pos,
    required this.podcastCurrentPositionInMilliseconds,
    required this.currentPlaybackPositionString,
    required this.currentPlaybackRemainingTimeString,
    this.playerPosition,
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
  Duration duration;

  @HiveField(8)
  String downloadSize;

  @HiveField(9)
  PodcastModel? podcast;

  @HiveField(10)
  int enclosureLength;

  @HiveField(11)
  String enclosureUrl;

  @HiveField(12)
  int pos;

  @HiveField(13)
  double podcastCurrentPositionInMilliseconds;

  @HiveField(14)
  String currentPlaybackPositionString;

  @HiveField(15)
  String currentPlaybackRemainingTimeString;

  @HiveField(16)
  String? enclosureType;

  @HiveField(17)
  Duration? playerPosition;

  factory QueueModel.fromJson(Map<String, dynamic> json) => QueueModel(
        guid: json['guid'],
        image: json['image'],
        title: json['title'],
        author: json['author'],
        datePublished: json['datePublished'],
        description: json['description'],
        feedUrl: json['feedUrl'],
        duration: json['duration'],
        downloadSize: json['downloadSize'],
        enclosureType: json['enclosureType'],
        podcast: json['podcast'],
        enclosureLength: json['enclosureLength'],
        enclosureUrl: json['enclosureUrl'],
        pos: json['pos'],
        podcastCurrentPositionInMilliseconds:
            json['podcastCurrentPositionInMilliseconds'],
        currentPlaybackPositionString: json['currentPlaybackPositionString'],
        currentPlaybackRemainingTimeString:
            json['currentPlaybackRemainingTimeString'],
        playerPosition: json['playerPosition'],
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
        'downloadSize': downloadSize,
        'enclosureType': enclosureType,
        'podcast': podcast,
        'enclosureLength': enclosureLength,
        'enclosureUrl': enclosureUrl,
        'pos': pos,
        'podcastCurrentPositionInMilliseconds':
            podcastCurrentPositionInMilliseconds,
        'currentPlaybackPositionString': currentPlaybackPositionString,
        'currentPlaybackRemainingTimeString':
            currentPlaybackRemainingTimeString,
        'playerPosition': playerPosition,
      };
}
