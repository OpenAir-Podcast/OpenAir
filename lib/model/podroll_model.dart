class PodrollEntry {
  final String? feedGuid;
  final String? feedUrl;
  final String? title;
  final String? author;
  final String? imageUrl;
  final String? description;

  PodrollEntry({
    this.feedGuid,
    this.feedUrl,
    this.title,
    this.author,
    this.imageUrl,
    this.description,
  });

  factory PodrollEntry.fromJson(Map<String, dynamic> json) {
    return PodrollEntry(
      feedGuid: json['feedGuid'] as String?,
      feedUrl: json['feedUrl'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );
  }
}
