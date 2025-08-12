import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'podcast_model.g.dart';

@HiveType(typeId: podcastTypeId)
class PodcastModel extends HiveObject {
  PodcastModel({
    required this.id,
    required this.feedUrl,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.artwork,
    required this.description,
  });

  @HiveField(0)
  int id;

  @HiveField(1)
  String feedUrl;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? author;

  @HiveField(4)
  String imageUrl;

  @HiveField(5)
  String artwork;

  @HiveField(6)
  String description;

  factory PodcastModel.fromJson(Map<String, dynamic> json) => PodcastModel(
        id: json['id'],
        feedUrl: json['url'] ?? json['feedUrl'],
        title: json['title'],
        author: json['author'] ?? json['subtitle'],
        imageUrl: json['image'] ?? json['imgURL'],
        artwork: json['artwork'] ?? json['image'] ?? json['imgURL'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': feedUrl,
        'title': title,
        'author': author,
        'image': imageUrl,
        'artwork': artwork,
        'description': description,
      };

  @override
  String toString() {
    return '''
    id: $id,
    feedUrl: $feedUrl,
    title: $title,
    author: $author,
    imageUrl: $imageUrl,
    artwork: $artwork,
    description: $description,
    ''';
  }
}
