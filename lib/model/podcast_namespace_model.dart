class LockedStatus {
  final bool value;
  final String? owner;

  const LockedStatus({required this.value, this.owner});

  factory LockedStatus.fromJson(Map<String, dynamic> json) => LockedStatus(
        value: json['value'] == true || json['value'] == 'yes',
        owner: json['owner'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        if (owner != null) 'owner': owner,
      };
}

class Location {
  final String display;
  final String? rel;
  final String? geo;
  final String? osm;
  final String? country;

  const Location({
    required this.display,
    this.rel,
    this.geo,
    this.osm,
    this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        display: json['display'] as String? ?? json['text'] as String? ?? '',
        rel: json['rel'] as String?,
        geo: json['geo'] as String?,
        osm: json['osm'] as String?,
        country: json['country'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'display': display,
        if (rel != null) 'rel': rel,
        if (geo != null) 'geo': geo,
        if (osm != null) 'osm': osm,
        if (country != null) 'country': country,
      };
}

class PodcastPlatformId {
  final String platform;
  final String id;
  final String? url;

  const PodcastPlatformId({
    required this.platform,
    required this.id,
    this.url,
  });

  factory PodcastPlatformId.fromJson(Map<String, dynamic> json) => PodcastPlatformId(
        platform: json['platform'] as String? ?? '',
        id: json['id'] as String? ?? '',
        url: json['url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'id': id,
        if (url != null) 'url': url,
      };
}

class RemoteItem {
  final String? feedGuid;
  final String? feedUrl;
  final String? itemGuid;
  final String? medium;
  final String? title;

  const RemoteItem({
    this.feedGuid,
    this.feedUrl,
    this.itemGuid,
    this.medium,
    this.title,
  });

  factory RemoteItem.fromJson(Map<String, dynamic> json) => RemoteItem(
        feedGuid: json['feedGuid'] as String?,
        feedUrl: json['feedUrl'] as String?,
        itemGuid: json['itemGuid'] as String?,
        medium: json['medium'] as String?,
        title: json['title'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (feedGuid != null) 'feedGuid': feedGuid,
        if (feedUrl != null) 'feedUrl': feedUrl,
        if (itemGuid != null) 'itemGuid': itemGuid,
        if (medium != null) 'medium': medium,
        if (title != null) 'title': title,
      };
}

class ContentLink {
  final String href;
  final String? display;

  const ContentLink({required this.href, this.display});

  factory ContentLink.fromJson(Map<String, dynamic> json) => ContentLink(
        href: json['href'] as String? ?? '',
        display: json['display'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'href': href,
        if (display != null) 'display': display,
      };
}

class Block {
  final bool value;
  final String? id;

  const Block({required this.value, this.id});

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        value: json['value'] == true || json['value'] == 'yes',
        id: json['id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        if (id != null) 'id': id,
      };
}

class UpdateFrequency {
  final String display;
  final bool? complete;
  final String? dtstart;
  final String? rrule;

  const UpdateFrequency({
    required this.display,
    this.complete,
    this.dtstart,
    this.rrule,
  });

  factory UpdateFrequency.fromJson(Map<String, dynamic> json) => UpdateFrequency(
        display: json['display'] as String? ?? json['text'] as String? ?? '',
        complete: json['complete'] as bool?,
        dtstart: json['dtstart'] as String?,
        rrule: json['rrule'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'display': display,
        if (complete != null) 'complete': complete,
        if (dtstart != null) 'dtstart': dtstart,
        if (rrule != null) 'rrule': rrule,
      };
}

class License {
  final String value;
  final String? url;
  final String? spdx;

  const License({required this.value, this.url, this.spdx});

  factory License.fromJson(Map<String, dynamic> json) => License(
        value: json['value'] as String? ?? json['text'] as String? ?? '',
        url: json['url'] as String?,
        spdx: json['spdx'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        if (url != null) 'url': url,
        if (spdx != null) 'spdx': spdx,
      };
}

class Credit {
  final String value;
  final String? role;
  final String? scheme;

  const Credit({required this.value, this.role, this.scheme});

  factory Credit.fromJson(Map<String, dynamic> json) => Credit(
        value: json['value'] as String? ?? json['text'] as String? ?? '',
        role: json['role'] as String?,
        scheme: json['scheme'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        if (role != null) 'role': role,
        if (scheme != null) 'scheme': scheme,
      };
}

class Podping {
  final bool usesPodping;

  const Podping({required this.usesPodping});

  factory Podping.fromJson(Map<String, dynamic> json) => Podping(
        usesPodping: json['usesPodping'] == true || json['usesPodping'] == 'true',
      );

  Map<String, dynamic> toJson() => {'usesPodping': usesPodping};
}

class Txt {
  final String value;
  final String? purpose;

  const Txt({required this.value, this.purpose});

  factory Txt.fromJson(Map<String, dynamic> json) => Txt(
        value: json['value'] as String? ?? json['text'] as String? ?? '',
        purpose: json['purpose'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        if (purpose != null) 'purpose': purpose,
      };
}

class Chat {
  final String? server;
  final String? protocol;
  final String? accountId;
  final String? space;

  const Chat({this.server, this.protocol, this.accountId, this.space});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        server: json['server'] as String?,
        protocol: json['protocol'] as String?,
        accountId: json['accountId'] as String?,
        space: json['space'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (server != null) 'server': server,
        if (protocol != null) 'protocol': protocol,
        if (accountId != null) 'accountId': accountId,
        if (space != null) 'space': space,
      };
}

class PodcastImage {
  final String href;
  final String? alt;
  final String? aspectRatio;
  final int? width;
  final int? height;
  final String? type;
  final String? purpose;

  const PodcastImage({
    required this.href,
    this.alt,
    this.aspectRatio,
    this.width,
    this.height,
    this.type,
    this.purpose,
  });

  factory PodcastImage.fromJson(Map<String, dynamic> json) => PodcastImage(
        href: json['href'] as String? ?? '',
        alt: json['alt'] as String?,
        aspectRatio: json['aspectRatio'] as String? ?? json['aspect-ratio'] as String?,
        width: (json['width'] as num?)?.toInt(),
        height: (json['height'] as num?)?.toInt(),
        type: json['type'] as String?,
        purpose: json['purpose'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'href': href,
        if (alt != null) 'alt': alt,
        if (aspectRatio != null) 'aspectRatio': aspectRatio,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (type != null) 'type': type,
        if (purpose != null) 'purpose': purpose,
      };
}

class LiveItemInfo {
  final String? title;
  final String? description;
  final String? image;
  final String? link;
  final String? status;
  final String? start;
  final String? end;
  final String? guid;
  final String? enclosureUrl;

  const LiveItemInfo({
    this.title,
    this.description,
    this.image,
    this.link,
    this.status,
    this.start,
    this.end,
    this.guid,
    this.enclosureUrl,
  });

  factory LiveItemInfo.fromJson(Map<String, dynamic> json) => LiveItemInfo(
        title: json['title'] as String?,
        description: json['description'] as String?,
        image: json['image'] as String?,
        link: json['link'] as String?,
        status: json['status'] as String?,
        start: json['start'] as String?,
        end: json['end'] as String?,
        guid: json['guid'] as String?,
        enclosureUrl: json['enclosureUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
        if (link != null) 'link': link,
        if (status != null) 'status': status,
        if (start != null) 'start': start,
        if (end != null) 'end': end,
        if (guid != null) 'guid': guid,
        if (enclosureUrl != null) 'enclosureUrl': enclosureUrl,
      };
}