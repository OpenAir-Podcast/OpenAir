class Trailer {
  final String? display;
  final String? url;
  final int? pubDate;
  final int? length;
  final String? type;
  final int? season;

  Trailer({
    this.display,
    this.url,
    this.pubDate,
    this.length,
    this.type,
    this.season,
  });

  factory Trailer.fromJson(Map<String, dynamic> json) {
    return Trailer(
      display: json['display'] as String?,
      url: json['url'] as String?,
      pubDate: (json['pubDate'] as num?)?.toInt(),
      length: (json['length'] as num?)?.toInt(),
      type: json['type'] as String?,
      season: (json['season'] as num?)?.toInt(),
    );
  }
}
