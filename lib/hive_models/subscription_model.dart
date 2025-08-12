import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: subscriptionTypeId)
class SubscriptionModel extends HiveObject {
  SubscriptionModel({
    required this.id,
    required this.feedUrl,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.artwork,
    required this.description,
    required this.episodeCount,
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

  @HiveField(7)
  int episodeCount;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        id: json['id'],
        feedUrl: json['url'],
        title: json['title'],
        author: json['author'],
        imageUrl: json['image'],
        artwork: json['artwork'],
        description: json['description'],
        episodeCount: json['episodeCount'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': feedUrl,
        'title': title,
        'author': author,
        'image': imageUrl,
        'artwork': artwork,
        'description': description,
        'episodeCount': episodeCount,
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
    episodeCount: $episodeCount,
    ''';
  }
}
