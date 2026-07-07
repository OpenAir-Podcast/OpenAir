class Chapter {
  final int start;
  final String title;
  final String? image;
  final String? url;
  final bool toc;

  const Chapter({
    required this.start,
    required this.title,
    this.image,
    this.url,
    this.toc = true,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      start: (json['start'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      image: json['image'] as String?,
      url: json['url'] as String?,
      toc: json['toc'] as bool? ?? true,
    );
  }
}

class ChaptersData {
  final String? version;
  final List<Chapter> chapters;

  const ChaptersData({
    this.version,
    required this.chapters,
  });

  factory ChaptersData.fromJson(Map<String, dynamic> json) {
    final list = (json['chapters'] as List<dynamic>?)
            ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ChaptersData(
      version: json['version'] as String?,
      chapters: list,
    );
  }

  Chapter? chapterAt(int seconds) {
    Chapter? result;
    for (final ch in chapters) {
      if (ch.start <= seconds) {
        result = ch;
      } else {
        break;
      }
    }
    return result;
  }

  double progressFor(int seconds, int duration) {
    if (duration <= 0) return 0;
    return seconds / duration;
  }
}
