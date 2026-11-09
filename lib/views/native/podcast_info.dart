import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/person_model.dart';
import 'package:openair/model/podroll_model.dart';
import 'package:openair/model/trailer_model.dart';
import 'package:openair/model/value_model.dart';
import 'package:openair/model/podcast_namespace_model.dart';
import 'package:openair/model/social_interact_model.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/widgets/toggle_banner.dart';
import 'package:url_launcher/url_launcher.dart';

final podcastDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, title) async {
  final podcastIndexService = ref.watch(podcastIndexProvider);
  return await podcastIndexService.getPodcastDetailsByTitle(title);
});

class PodcastInfoPage extends ConsumerWidget {
  const PodcastInfoPage({super.key, required this.podcastInfo});

  final Map podcastInfo;

  List<Person> get _persons {
    final raw = podcastInfo['persons'];
    if (raw is List) {
      return raw
          .map((e) => Person.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<Value> get _values {
    final raw = podcastInfo['value'];
    if (raw is List) {
      return raw
          .map((e) => Value.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<PodrollEntry> get _podroll {
    final raw = podcastInfo['podroll'];
    if (raw is List) {
      return raw
          .map((e) => PodrollEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<Trailer> get _trailers {
    final raw = podcastInfo['trailers'];
    if (raw is List) {
      return raw
          .map((e) => Trailer.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  bool get _locked {
    final raw = podcastInfo['locked'];
    if (raw is bool) return raw;
    if (raw is int) return raw == 1;
    return false;
  }

  String? get _lockOwner => podcastInfo['lockOwner']?.toString();

  String? get _podcastGuid => podcastInfo['podcastGuid']?.toString();

  List<Location> get _locations {
    final raw = podcastInfo['locations'];
    if (raw is List) {
      return raw
          .map((e) => Location.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<PodcastPlatformId> get _podcastIds {
    final raw = podcastInfo['podcastIds'];
    if (raw is List) {
      return raw
          .map((e) => PodcastPlatformId.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<RemoteItem> get _remoteItems {
    final raw = podcastInfo['remoteItems'];
    if (raw is List) {
      return raw
          .map((e) => RemoteItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<LiveItemInfo> get _liveItems {
    final raw = podcastInfo['liveItems'];
    if (raw is List) {
      return raw
          .map((e) => LiveItemInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Chat? get _chat {
    final raw = podcastInfo['chat'];
    if (raw is Map) {
      return Chat.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  RemoteItem? get _publisher {
    final raw = podcastInfo['publisher'];
    if (raw is Map) {
      return RemoteItem.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  List<PodcastImage> get _images {
    final raw = podcastInfo['images'];
    if (raw is List) {
      return raw
          .map((e) => PodcastImage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<ContentLink> get _contentLinks {
    final raw = podcastInfo['contentLinks'];
    if (raw is List) {
      return raw
          .map((e) => ContentLink.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<Block> get _blocks {
    final raw = podcastInfo['blocks'];
    if (raw is List) {
      return raw
          .map((e) => Block.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  UpdateFrequency? get _updateFrequency {
    final raw = podcastInfo['updateFrequency'];
    if (raw is Map) {
      return UpdateFrequency.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  License? get _license {
    final raw = podcastInfo['license'];
    if (raw is Map) {
      return License.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  bool get _podping {
    final raw = podcastInfo['podping'];
    if (raw is bool) return raw;
    return false;
  }

  List<Txt> get _txts {
    final raw = podcastInfo['txts'];
    if (raw is List) {
      return raw.map((e) => Txt.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  List<Credit> get _credits {
    final raw = podcastInfo['credits'];
    if (raw is List) {
      return raw
          .map((e) => Credit.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> get _funding {
    final raw = podcastInfo['funding'];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (raw is Map) {
      return [Map<String, dynamic>.from(raw)];
    }
    return [];
  }

  List<SocialInteract> get _socialInteracts {
    final raw = podcastInfo['socialInteract'] ?? podcastInfo['socialInteracts'];
    if (raw is List) {
      return raw
          .map((e) => SocialInteract.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.isSupported)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          podcastInfo['title'],
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.3),
                      colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Podcast cover with shadow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'podcast_${podcastInfo['title']}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              width: 140,
                              height: 140,
                              memCacheWidth: 280,
                              memCacheHeight: 280,
                              imageUrl: podcastInfo['image'],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 140,
                                height: 140,
                                color: cardImageShadow,
                                child: const Icon(
                                  Icons.error,
                                  size: 48.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Row(
                        children: [
                          // Podcast info
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  podcastInfo['title'],
                                  textAlign: TextAlign.center,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      podcastInfo['author'] ??
                                          Translations.of(context)
                                              .text('unknown'),
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.headphones_outlined,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${podcastInfo['episodeCount']} episodes',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Description section
              if (podcastInfo['description']?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Translations.of(context).text('description'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    podcastInfo['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // People section
              if (_persons.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.people_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'People',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _persons.map((person) {
                      return ListTile(
                        leading: person.img != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: person.img!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => CircleAvatar(
                                    child: Icon(Icons.person_outlined, size: 20),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                child: Icon(Icons.person_outlined, size: 20),
                              ),
                        title: Text(person.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: person.role != null
                            ? Text(person.role!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey))
                            : null,
                        onTap: person.href != null
                            ? () async {
                                if (await canLaunchUrl(
                                    Uri.parse(person.href!))) {
                                  await launchUrl(Uri.parse(person.href!),
                                      mode:
                                          LaunchMode.externalApplication);
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Value section
              if (_values.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.bolt_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Value',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _values.map((v) {
                      return Chip(
                        avatar: const Icon(Icons.bolt, size: 16,
                            color: Color(0xFFF7931A)),
                        label: Text(v.displayName),
                        backgroundColor: const Color(0xFFF7931A)
                            .withValues(alpha: 0.1),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Podroll section
              if (_podroll.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.rss_feed_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Recommendations',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _podroll.map((entry) {
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: entry.imageUrl ?? '',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 44,
                              height: 44,
                              color: cardImageShadow,
                              child:
                                  const Icon(Icons.podcasts, size: 24),
                            ),
                          ),
                        ),
                        title: Text(entry.title ?? 'Unknown',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: entry.author != null
                            ? Text(entry.author!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey))
                            : null,
                        trailing: entry.feedUrl != null
                            ? IconButton(
                                icon: const Icon(Icons.download_outlined),
                                tooltip: 'Import to OpenAir',
                                onPressed: () async {
                                  final success = await ref
                                      .read(audioProvider)
                                      .addPodcastByRssUrl(
                                          entry.feedUrl!, context);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(success
                                            ? 'Imported ${entry.title ?? 'podcast'}'
                                            : 'Failed to import podcast'),
                                      ),
                                    );
                                  }
                                },
                              )
                            : null,
                        onTap: entry.feedUrl != null
                            ? () async {
                                if (await canLaunchUrl(
                                    Uri.parse(entry.feedUrl!))) {
                                  await launchUrl(
                                      Uri.parse(entry.feedUrl!),
                                      mode: LaunchMode
                                          .externalApplication);
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Trailers section
              if (_trailers.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.movie_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Trailers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _trailers.map((t) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primary
                              .withValues(alpha: 0.1),
                          child: Icon(Icons.play_arrow_rounded,
                              color: colorScheme.primary),
                        ),
                        title: Text(t.display ?? 'Trailer',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: t.season != null
                            ? Text('Season ${t.season}',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey))
                            : null,
                        onTap: t.url != null
                            ? () async {
                                if (await canLaunchUrl(
                                    Uri.parse(t.url!))) {
                                  await launchUrl(Uri.parse(t.url!),
                                      mode: LaunchMode
                                          .externalApplication);
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Locked section
              if (_locked || _lockOwner != null) ...[
                Row(
                  children: [
                    Icon(Icons.lock_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Locked',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    _locked
                        ? 'Yes${_lockOwner != null ? ' (owner: $_lockOwner)' : ''}'
                        : 'No',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Podcast GUID section
              if (_podcastGuid != null && _podcastGuid!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.fingerprint_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Podcast GUID',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: SelectableText(
                    _podcastGuid!,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Locations section
              if (_locations.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Locations',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _locations
                        .map((l) => ListTile(
                              title: Text(l.display),
                              subtitle: Text([
                                if (l.rel != null) l.rel,
                                if (l.country != null) l.country,
                                if (l.geo != null) l.geo,
                                if (l.osm != null) 'OSM: ${l.osm}',
                              ].join(' • ')),
                              trailing: l.geo != null
                                  ? IconButton(
                                      icon: const Icon(Icons.map_outlined),
                                      onPressed: () async {
                                        final uri = Uri.parse(
                                            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(l.geo!)}');
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri,
                                              mode: LaunchMode.externalApplication);
                                        }
                                      },
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Platform IDs section
              if (_podcastIds.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.badge_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Platform IDs',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _podcastIds
                        .map((p) => ListTile(
                              title: Text(p.platform),
                              subtitle: Text(p.id),
                              trailing: p.url != null
                                  ? IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () async {
                                        if (await canLaunchUrl(
                                            Uri.parse(p.url!))) {
                                          await launchUrl(Uri.parse(p.url!),
                                              mode: LaunchMode
                                                  .externalApplication);
                                        }
                                      },
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Content Links section
              if (_contentLinks.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.link_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Content Links',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _contentLinks
                        .map((c) => ListTile(
                              title: Text(c.display ?? c.href),
                              onTap: () async {
                                if (await canLaunchUrl(Uri.parse(c.href))) {
                                  await launchUrl(Uri.parse(c.href),
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Remote Items section
              if (_remoteItems.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.rss_feed_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Remote Items',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _remoteItems
                        .map((r) => ListTile(
                              title: Text(r.title ?? r.feedUrl ?? 'Remote'),
                              subtitle: r.medium != null ? Text(r.medium!) : null,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Live Items section
              if (_liveItems.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.live_tv_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Live Items',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _liveItems
                        .map((l) => ListTile(
                              leading: l.image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: l.image!,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            const Icon(Icons.live_tv_outlined),
                                      ),
                                    )
                                  : null,
                              title: Text(l.title ?? 'Live'),
                              subtitle: Text([
                                if (l.description != null) l.description,
                                if (l.status != null) l.status,
                                if (l.start != null) 'Start: ${l.start}',
                                if (l.end != null) 'End: ${l.end}',
                                if (l.link != null) l.link,
                              ].join(' • ')),
                              trailing: l.enclosureUrl != null
                                  ? IconButton(
                                      icon: const Icon(Icons.play_arrow_rounded),
                                      tooltip: 'Listen live',
                                      onPressed: () {
                                        ref.read(audioProvider).playLiveStream(
                                            l.enclosureUrl!, l.title ?? 'Live');
                                      },
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Blocks section
              if (_blocks.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.block_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Blocks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _blocks
                        .map((b) => Text(
                              '${b.id ?? 'global'}: ${b.value ? 'blocked' : 'allowed'}'))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Update Frequency section
              if (_updateFrequency != null) ...[
                Row(
                  children: [
                    Icon(Icons.update_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Update Frequency',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(_updateFrequency!.display),
                ),
                const SizedBox(height: 32),
              ],

              // License section
              if (_license != null) ...[
                Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'License',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(_license!.value),
                ),
                const SizedBox(height: 32),
              ],

              // Podping section
              if (_podping) ...[
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Podping',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text('Uses Podping notifications'),
                ),
                const SizedBox(height: 32),
              ],

              // Txts section
              if (_txts.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.text_snippet_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Txt',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _txts
                        .map((t) => ListTile(
                              title: Text(t.value),
                              subtitle: t.purpose != null ? Text(t.purpose!) : null,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Credits section
              if (_credits.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Credits',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _credits
                        .map((c) => ListTile(
                              title: Text(c.value),
                              subtitle: Text([
                                if (c.role != null) c.role,
                                if (c.scheme != null) c.scheme,
                              ].join(' • ')),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Funding section
              if (_funding.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.favorite_border_rounded,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Funding',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _funding.map((f) {
                      final url = f['url']?.toString();
                      return ListTile(
                        title: Text(f['text']?.toString() ?? 'Support'),
                        onTap: url != null
                            ? () async {
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Social Interact section
              if (_socialInteracts.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.forum_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Social',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _socialInteracts
                        .map((si) => ListTile(
                              title: Text(si.displayLabel),
                              trailing: si.isSupported
                                  ? IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () async {
                                        if (si.uri != null &&
                                            await canLaunchUrl(
                                                Uri.parse(si.uri!))) {
                                          await launchUrl(Uri.parse(si.uri!),
                                              mode: LaunchMode
                                                  .externalApplication);
                                        }
                                      },
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Chat section
              if (_chat != null) ...[
                Row(
                  children: [
                    Icon(Icons.chat_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Chat',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${_chat!.protocol ?? ''} ${_chat!.server ?? ''}'.trim(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Publisher section
              if (_publisher != null) ...[
                Row(
                  children: [
                    Icon(Icons.campaign_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Publisher',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    title: Text(_publisher!.title ?? _publisher!.feedUrl ?? 'Publisher'),
                    subtitle: _publisher!.medium != null ? Text(_publisher!.medium!) : null,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Images section
              if (_images.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.image_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Images',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _images.map((img) {
                      return ListTile(
                        leading: img.href.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: img.href,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.image_outlined),
                              )
                            : null,
                        title: Text(img.purpose ?? img.type ?? 'Image'),
                        subtitle: Text([
                          if (img.alt != null) img.alt,
                          if (img.width != null && img.height != null)
                            '${img.width}x${img.height}',
                        ].join(' • ')),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Value Time Splits section
              if (_values.any((v) => v.valueTimeSplits.isNotEmpty)) ...[
                Row(
                  children: [
                    Icon(Icons.timeline_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Value Time Splits',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: _values
                        .expand((v) => v.valueTimeSplits)
                        .map((ts) => ListTile(
                              title: Text(
                                  'Start ${ts.startTime ?? 0}s, ${ts.duration ?? 0}s'),
                              subtitle: ts.remoteItem != null
                                  ? Text(ts.remoteItem!['title']?.toString() ??
                                      'Remote item')
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Details section
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Translations.of(context).text('details'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      Icons.link_outlined,
                      Translations.of(context).text('link'),
                      podcastInfo['link'] ?? podcastInfo['url'] ?? '',
                      theme,
                      isLink: true,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.language_outlined,
                      Translations.of(context).text('language'),
                      podcastInfo['language'] ?? 'Unknown',
                      theme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.category_outlined,
                      Translations.of(context).text('medium'),
                      podcastInfo['medium'] ?? 'Unknown',
                      theme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.label_outlined,
                      Translations.of(context).text('categories'),
                      (podcastInfo['categories'] as Map?)?.values.join(', ') ??
                          'None',
                      theme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _buildDetailRow(
                      context,
                      Icons.update_outlined,
                      Translations.of(context).text('lastUpdate'),
                      DateTime.fromMillisecondsSinceEpoch(
                              podcastInfo['lastUpdateTime'] * 1000)
                          .toString()
                          .split(' ')[0],
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ToggleBanner(),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isLink)
                  GestureDetector(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse(value),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
