import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

class PodcastNamespaceParser {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> parseFeed(String feedUrl) async {
    final result = <String, dynamic>{
      'feed': <String, dynamic>{},
      'items': <String, Map<String, dynamic>>{},
    };

    if (feedUrl.isEmpty) return result;

    try {
      final response = await _dio.get<String>(feedUrl);
      final xmlString = response.data;
      if (xmlString == null || xmlString.isEmpty) return result;

      final document = XmlDocument.parse(xmlString);
      final channel = document.descendants
          .whereType<XmlElement>()
          .firstWhere((e) => e.name.local == 'channel',
              orElse: () => document.rootElement);

      // Feed-level fields
      final feed = result['feed'] as Map<String, dynamic>;
      for (final child in channel.children.whereType<XmlElement>()) {
        if (child.name.local == 'item' ||
            child.name.local == 'liveItem') {
          continue;
        }
        _applyFeedTag(feed, child);
      }

      // Items
      final items = result['items'] as Map<String, Map<String, dynamic>>;
      for (final item in channel.children.whereType<XmlElement>()) {
        if (item.name.local != 'item' &&
            item.name.local != 'liveItem') {
          continue;
        }
        final guid = _childText(item, 'guid') ?? _attr(item, 'guid');
        if (guid == null || guid.isEmpty) continue;
        final parsed = <String, dynamic>{};
        for (final child in item.children.whereType<XmlElement>()) {
          _applyItemTag(parsed, child);
        }
        // liveItem extras
        if (item.name.local == 'liveItem') {
          parsed['liveStatus'] = item.getAttribute('status');
          parsed['liveStart'] = item.getAttribute('start');
          parsed['liveEnd'] = item.getAttribute('end');
          parsed['isLiveItem'] = true;
        }
        items[guid] = parsed;
      }
    } catch (e) {
      debugPrint('PodcastNamespaceParser error: $e');
    }

    return result;
  }

  void _applyFeedTag(Map<String, dynamic> feed, XmlElement el) {
    switch (el.name.local) {
      case 'locked':
        feed['locked'] = (el.innerText.trim().toLowerCase() == 'yes');
        final owner = el.getAttribute('owner');
        if (owner != null) feed['lockOwner'] = owner;
        break;
      case 'guid':
        feed['podcastGuid'] = el.innerText.trim();
        break;
      case 'medium':
        feed['medium'] = el.innerText.trim();
        break;
      case 'funding':
        feed.putIfAbsent('funding', () => <Map<String, dynamic>>[]);
        (feed['funding'] as List).add({
          'url': el.getAttribute('url'),
          'text': el.innerText.trim(),
        });
        break;
      case 'person':
        feed.putIfAbsent('persons', () => <Map<String, dynamic>>[]);
        (feed['persons'] as List).add({
          'name': el.innerText.trim(),
          'role': el.getAttribute('role'),
          'group': el.getAttribute('group'),
          'img': el.getAttribute('img'),
          'href': el.getAttribute('href'),
        });
        break;
      case 'location':
        feed.putIfAbsent('locations', () => <Map<String, dynamic>>[]);
        (feed['locations'] as List).add({
          'display': el.innerText.trim(),
          'rel': el.getAttribute('rel'),
          'geo': el.getAttribute('geo'),
          'osm': el.getAttribute('osm'),
          'country': el.getAttribute('country'),
        });
        break;
      case 'license':
        feed['license'] = {
          'value': el.innerText.trim(),
          'url': el.getAttribute('url'),
          'spdx': el.getAttribute('spdx'),
        };
        break;
      case 'value':
        feed.putIfAbsent('value', () => <Map<String, dynamic>>[]);
        (feed['value'] as List).add(_parseValue(el));
        break;
      case 'block':
        feed.putIfAbsent('blocks', () => <Map<String, dynamic>>[]);
        (feed['blocks'] as List).add({
          'value': el.innerText.trim().toLowerCase() == 'yes',
          'id': el.getAttribute('id'),
        });
        break;
      case 'txt':
        feed.putIfAbsent('txts', () => <Map<String, dynamic>>[]);
        (feed['txts'] as List).add({
          'value': el.innerText.trim(),
          'purpose': el.getAttribute('purpose'),
        });
        break;
      case 'podping':
        feed['podping'] = el.getAttribute('usesPodping') == 'true';
        break;
      case 'updateFrequency':
        feed['updateFrequency'] = {
          'display': el.innerText.trim(),
          'complete': el.getAttribute('complete') == 'true',
          'dtstart': el.getAttribute('dtstart'),
          'rrule': el.getAttribute('rrule'),
        };
        break;
      case 'remoteItem':
        feed.putIfAbsent('remoteItems', () => <Map<String, dynamic>>[]);
        (feed['remoteItems'] as List).add(_parseRemoteItem(el));
        break;
      case 'podroll':
        final items = <Map<String, dynamic>>[];
        for (final ri in el.children.whereType<XmlElement>()) {
          if (ri.name.local == 'remoteItem') items.add(_parseRemoteItem(ri));
        }
        feed['podroll'] = items;
        break;
      case 'contentLink':
        feed.putIfAbsent('contentLinks', () => <Map<String, dynamic>>[]);
        (feed['contentLinks'] as List).add({
          'href': el.getAttribute('href'),
          'display': el.innerText.trim(),
        });
        break;
      case 'id':
        feed.putIfAbsent('podcastIds', () => <Map<String, dynamic>>[]);
        (feed['podcastIds'] as List).add({
          'platform': el.getAttribute('platform'),
          'id': el.getAttribute('id'),
          'url': el.getAttribute('url'),
        });
        break;
      case 'trailer':
        feed.putIfAbsent('trailers', () => <Map<String, dynamic>>[]);
        (feed['trailers'] as List).add({
          'display': el.innerText.trim(),
          'url': el.getAttribute('url'),
          'pubDate': el.getAttribute('pubdate'),
          'length': int.tryParse(el.getAttribute('length') ?? ''),
          'type': el.getAttribute('type'),
          'season': int.tryParse(el.getAttribute('season') ?? ''),
        });
        break;
      case 'liveItem':
        feed.putIfAbsent('liveItems', () => <Map<String, dynamic>>[]);
        (feed['liveItems'] as List).add({
          'title': _childText(el, 'title'),
          'status': el.getAttribute('status'),
          'start': el.getAttribute('start'),
          'end': el.getAttribute('end'),
          'guid': _childText(el, 'guid'),
        });
        break;
      case 'chat':
        feed['chat'] = {
          'server': el.getAttribute('server'),
          'protocol': el.getAttribute('protocol'),
          'accountId': el.getAttribute('accountId'),
          'space': el.getAttribute('space'),
        };
        break;
      case 'publisher':
        final ri = el.children.whereType<XmlElement>().firstWhere(
            (e) => e.name.local == 'remoteItem',
            orElse: () => el);
        feed['publisher'] = _parseRemoteItem(ri);
        break;
      case 'credit':
        feed.putIfAbsent('credits', () => <Map<String, dynamic>>[]);
        (feed['credits'] as List).add({
          'value': el.innerText.trim(),
          'role': el.getAttribute('role'),
          'scheme': el.getAttribute('scheme'),
        });
        break;
      default:
        break;
    }
  }

  void _applyItemTag(Map<String, dynamic> item, XmlElement el) {
    switch (el.name.local) {
      case 'transcript':
        item.putIfAbsent('transcripts', () => <Map<String, dynamic>>[]);
        (item['transcripts'] as List).add({
          'url': el.getAttribute('url'),
          'type': el.getAttribute('type'),
          'language': el.getAttribute('language'),
          'rel': el.getAttribute('rel'),
        });
        break;
      case 'funding':
        item.putIfAbsent('funding', () => <Map<String, dynamic>>[]);
        (item['funding'] as List).add({
          'url': el.getAttribute('url'),
          'text': el.innerText.trim(),
        });
        break;
      case 'chapters':
        item['chaptersUrl'] = el.getAttribute('url');
        item['chaptersType'] = el.getAttribute('type');
        break;
      case 'soundbite':
        item.putIfAbsent('soundbites', () => <Map<String, dynamic>>[]);
        (item['soundbites'] as List).add({
          'startTime': int.tryParse(el.getAttribute('startTime') ?? ''),
          'duration': int.tryParse(el.getAttribute('duration') ?? ''),
          'title': el.innerText.trim(),
        });
        break;
      case 'person':
        item.putIfAbsent('persons', () => <Map<String, dynamic>>[]);
        (item['persons'] as List).add({
          'name': el.innerText.trim(),
          'role': el.getAttribute('role'),
          'group': el.getAttribute('group'),
          'img': el.getAttribute('img'),
          'href': el.getAttribute('href'),
        });
        break;
      case 'location':
        item.putIfAbsent('locations', () => <Map<String, dynamic>>[]);
        (item['locations'] as List).add({
          'display': el.innerText.trim(),
          'rel': el.getAttribute('rel'),
          'geo': el.getAttribute('geo'),
          'osm': el.getAttribute('osm'),
          'country': el.getAttribute('country'),
        });
        break;
      case 'season':
        item['season'] = int.tryParse(el.innerText.trim()) ??
            int.tryParse(el.getAttribute('value') ?? '');
        break;
      case 'episode':
        item['episode'] = int.tryParse(el.innerText.trim()) ??
            int.tryParse(el.getAttribute('value') ?? '');
        break;
      case 'license':
        item['license'] = {
          'value': el.innerText.trim(),
          'url': el.getAttribute('url'),
          'spdx': el.getAttribute('spdx'),
        };
        break;
      case 'alternateEnclosure':
        item.putIfAbsent('alternateEnclosure', () => <Map<String, dynamic>>[]);
        (item['alternateEnclosure'] as List).add({
          'type': el.getAttribute('type'),
          'length': int.tryParse(el.getAttribute('length') ?? ''),
          'bitrate': int.tryParse(el.getAttribute('bitrate') ?? ''),
          'rel': el.getAttribute('rel'),
          'default': el.getAttribute('default') == 'true',
        });
        break;
      case 'value':
        item.putIfAbsent('value', () => <Map<String, dynamic>>[]);
        (item['value'] as List).add(_parseValue(el));
        break;
      case 'contentLink':
        item.putIfAbsent('contentLinks', () => <Map<String, dynamic>>[]);
        (item['contentLinks'] as List).add({
          'href': el.getAttribute('href'),
          'display': el.innerText.trim(),
        });
        break;
      case 'socialInteract':
        item.putIfAbsent('socialInteract', () => <Map<String, dynamic>>[]);
        (item['socialInteract'] as List).add({
          'uri': el.getAttribute('uri'),
          'protocol': el.getAttribute('protocol'),
          'accountId': el.getAttribute('accountId'),
          'accountUrl': el.getAttribute('accountUrl'),
          'priority': int.tryParse(el.getAttribute('priority') ?? ''),
        });
        break;
      case 'txt':
        item.putIfAbsent('txts', () => <Map<String, dynamic>>[]);
        (item['txts'] as List).add({
          'value': el.innerText.trim(),
          'purpose': el.getAttribute('purpose'),
        });
        break;
      case 'block':
        item.putIfAbsent('blocks', () => <Map<String, dynamic>>[]);
        (item['blocks'] as List).add({
          'value': el.innerText.trim().toLowerCase() == 'yes',
          'id': el.getAttribute('id'),
        });
        break;
      case 'credit':
        item.putIfAbsent('credits', () => <Map<String, dynamic>>[]);
        (item['credits'] as List).add({
          'value': el.innerText.trim(),
          'role': el.getAttribute('role'),
          'scheme': el.getAttribute('scheme'),
        });
        break;
      default:
        break;
    }
  }

  Map<String, dynamic> _parseValue(XmlElement el) {
    final recipients = <Map<String, dynamic>>[];
    for (final r in el.descendants.whereType<XmlElement>()) {
      if (r.name.local == 'valueRecipient') {
        recipients.add({
          'name': r.getAttribute('name'),
          'customKey': r.getAttribute('customKey'),
          'customValue': r.getAttribute('customValue'),
          'type': r.getAttribute('type'),
          'address': r.getAttribute('address'),
          'split': int.tryParse(r.getAttribute('split') ?? '') ?? 0,
          'fee': r.getAttribute('fee') == 'true',
        });
      }
    }
    return {
      'type': el.getAttribute('type'),
      'method': el.getAttribute('method'),
      'suggested': double.tryParse(el.getAttribute('suggested') ?? ''),
      'valueRecipients': recipients,
    };
  }

  Map<String, dynamic> _parseRemoteItem(XmlElement el) {
    return {
      'feedGuid': el.getAttribute('feedGuid'),
      'feedUrl': el.getAttribute('feedUrl'),
      'itemGuid': el.getAttribute('itemGuid'),
      'medium': el.getAttribute('medium'),
      'title': el.getAttribute('title') ?? el.innerText.trim(),
    };
  }

  String? _childText(XmlElement parent, String name) {
    for (final c in parent.children.whereType<XmlElement>()) {
      if (c.name.local == name) return c.innerText.trim();
    }
    return null;
  }

  String? _attr(XmlElement el, String name) => el.getAttribute(name);
}
