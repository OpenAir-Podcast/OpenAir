class AlternateEnclosureSource {
  final String uri;
  final String? contentType;

  AlternateEnclosureSource({required this.uri, this.contentType});

  factory AlternateEnclosureSource.fromJson(Map<String, dynamic> json) {
    return AlternateEnclosureSource(
      uri: json['uri'] as String,
      contentType: json['contentType'] as String?,
    );
  }
}

class AlternateEnclosure {
  final String type;
  final int? length;
  final int? bitrate;
  final String? rel;
  final bool? default_;
  final List<AlternateEnclosureSource> sources;

  AlternateEnclosure({
    required this.type,
    this.length,
    this.bitrate,
    this.rel,
    this.default_,
    this.sources = const [],
  });

  factory AlternateEnclosure.fromJson(Map<String, dynamic> json) {
    return AlternateEnclosure(
      type: json['type'] as String,
      length: (json['length'] as num?)?.toInt(),
      bitrate: (json['bitrate'] as num?)?.toInt(),
      rel: json['rel'] as String?,
      default_: json['default'] as bool?,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) =>
                  AlternateEnclosureSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isVideo => type.startsWith('video/');
  bool get isAudio => type.startsWith('audio/');
  bool get isHighBitrate => (bitrate ?? 0) >= 256;

  String get formatLabel {
    if (isVideo) return 'Video';
    if (isHighBitrate) return 'HD Audio';
    if (rel == 'podcast') return 'Podcast';
    return type.split('/').last.toUpperCase();
  }
}
