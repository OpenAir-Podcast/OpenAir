class Soundbite {
  final int startTime;
  final int duration;
  final String? title;

  Soundbite({
    required this.startTime,
    required this.duration,
    this.title,
  });

  factory Soundbite.fromJson(Map<String, dynamic> json) {
    return Soundbite(
      startTime: (json['startTime'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime,
        'duration': duration,
        if (title != null) 'title': title,
      };
}
