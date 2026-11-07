class SocialInteract {
  final String? uri;
  final String? protocol;
  final String? accountId;
  final String? accountUrl;
  final int? priority;

  SocialInteract({
    this.uri,
    this.protocol,
    this.accountId,
    this.accountUrl,
    this.priority,
  });

  factory SocialInteract.fromJson(Map<String, dynamic> json) {
    return SocialInteract(
      uri: json['uri'] as String?,
      protocol: json['protocol'] as String?,
      accountId: json['accountId'] as String?,
      accountUrl: json['accountUrl'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
    );
  }

  bool get isDisabled => protocol == 'disabled';
  bool get isSupported => !isDisabled && uri != null && uri!.isNotEmpty;

  String get displayLabel {
    switch (protocol) {
      case 'activitypub':
        return 'Comments';
      case 'twitter':
        return 'X/Twitter';
      case 'discord':
        return 'Discord';
      case 'telegram':
        return 'Telegram';
      case 'mastodon':
        return 'Mastodon';
      default:
        return protocol ?? 'Social';
    }
  }
}
