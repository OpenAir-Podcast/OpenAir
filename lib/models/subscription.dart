import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'subscription.g.dart';

@HiveType(typeId: subscriptionTypeId)
class Subscription extends HiveObject {
  Subscription({
    required this.id,
    required this.feedUrl,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  @HiveField(0)
  int id;

  @HiveField(1)
  String feedUrl;

  @HiveField(2)
  String title;

  @HiveField(3)
  String author;

  @HiveField(4)
  String imageUrl;

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'],
        feedUrl: json['feedId'],
        title: json['title'],
        author: json['author'],
        imageUrl: json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': feedUrl,
        'title': title,
        'author': author,
        'image': imageUrl,
      };

  @override
  String toString() {
    return '''
    id: $id,
    feedUrl: $feedUrl,
    title: $title,
    author: $author,
    imageUrl: $imageUrl,
    ''';
  }
}
