import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:openair/model/transcript_model.dart';

class TranscriptService {
  final Dio _dio = Dio();

  Future<List<TranscriptCue>> fetch(String url) async {
    if (url.isEmpty) return [];
    try {
      final response = await _dio.get<String>(url);
      final body = response.data ?? '';
      if (body.trim().startsWith('{')) {
        try {
          final json = jsonDecode(body);
          return _parseJson(json);
        } catch (_) {}
      }
      if (body.contains('WEBVTT')) {
        return _parseVtt(body);
      }
      return _parseSrt(body);
    } catch (e) {
      debugPrint('TranscriptService error: $e');
      return [];
    }
  }

  List<TranscriptCue> _parseJson(dynamic json) {
    final cues = <TranscriptCue>[];
    List<dynamic>? segments;
    if (json is Map<String, dynamic>) {
      if (json['segments'] is List) { segments = json['segments'] as List; }
      else if (json['cues'] is List) { segments = json['cues'] as List; }
      else if (json['transcript'] is List) { segments = json['transcript'] as List; }
    } else if (json is List) {
      segments = json;
    }
    if (segments == null) return cues;
    for (final s in segments) {
      if (s is! Map<String, dynamic>) continue;
      final start = _secondsToDuration((s['startTime'] ?? s['start'] ?? s['begin'] ?? 0));
      final end = _secondsToDuration((s['endTime'] ?? s['end'] ?? s['finish'] ?? (start.inSeconds + 5)));
      final text = (s['body'] ?? s['text'] ?? s['content'] ?? '').toString();
      if (text.trim().isEmpty) continue;
      cues.add(TranscriptCue(start: start, end: end, text: text.trim()));
    }
    return cues;
  }

  Duration _secondsToDuration(dynamic v) {
    if (v is num) {
      if (v > 1000) return Duration(milliseconds: v.toInt());
      return Duration(seconds: v.toInt(), milliseconds: ((v - v.toInt()) * 1000).round());
    }
    final s = v.toString();
    return _parseTimestamp(s) ?? Duration.zero;
  }

  List<TranscriptCue> _parseVtt(String body) {
    final cues = <TranscriptCue>[];
    final lines = body.split('\n');
    final timeRegex = RegExp(r'(\d{1,2}:)?\d{2}:\d{2}\.\d{3}\s*-->\s*(\d{1,2}:)?\d{2}:\d{2}\.\d{3}');
    int i = 0;
    while (i < lines.length) {
      final match = timeRegex.firstMatch(lines[i]);
      if (match != null) {
        final parts = lines[i].split('-->');
        final start = _parseTimestamp(parts[0].trim());
        final end = _parseTimestamp(parts[1].trim().split(RegExp(r'\s')).first);
        if (start != null && end != null) {
          final textLines = <String>[];
          i++;
          while (i < lines.length && lines[i].trim().isNotEmpty) {
            textLines.add(lines[i].trim());
            i++;
          }
          final text = textLines.join(' ');
          if (text.isNotEmpty) {
            cues.add(TranscriptCue(start: start, end: end, text: text));
          }
        }
      }
      i++;
    }
    return cues;
  }

  List<TranscriptCue> _parseSrt(String body) {
    final cues = <TranscriptCue>[];
    final blocks = body.split(RegExp(r'\n\s*\n'));
    final timeRegex = RegExp(r'(\d{1,2}:)?\d{2}:\d{2},\d{3}\s*-->\s*(\d{1,2}:)?\d{2}:\d{2},\d{3}');
    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 2) continue;
      final timeLineIndex = lines.indexWhere((l) => timeRegex.hasMatch(l));
      if (timeLineIndex == -1) continue;
      final parts = lines[timeLineIndex].split('-->');
      final start = _parseTimestamp(parts[0].trim().replaceAll(',', '.'));
      final end = _parseTimestamp(parts[1].trim().split(RegExp(r'\s')).first.replaceAll(',', '.'));
      if (start == null || end == null) continue;
      final text = lines.sublist(timeLineIndex + 1).join(' ').trim();
      if (text.isNotEmpty) {
        cues.add(TranscriptCue(start: start, end: end, text: text));
      }
    }
    return cues;
  }

  Duration? _parseTimestamp(String value) {
    final cleaned = value.trim();
    final parts = cleaned.split(':');
    try {
      if (parts.length == 3) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final secParts = parts[2].split('.');
        final s = int.parse(secParts[0]);
        final ms = secParts.length > 1 ? int.parse(secParts[1].padRight(3, '0').substring(0, 3)) : 0;
        return Duration(hours: h, minutes: m, seconds: s, milliseconds: ms);
      } else if (parts.length == 2) {
        final m = int.parse(parts[0]);
        final secParts = parts[1].split('.');
        final s = int.parse(secParts[0]);
        final ms = secParts.length > 1 ? int.parse(secParts[1].padRight(3, '0').substring(0, 3)) : 0;
        return Duration(minutes: m, seconds: s, milliseconds: ms);
      }
    } catch (_) {}
    return null;
  }
}