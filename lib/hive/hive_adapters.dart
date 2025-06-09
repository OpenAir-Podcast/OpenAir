import 'dart:collection';

import 'package:hive_ce/hive.dart';
import 'package:openair/models/completed_episode.dart';
import 'package:openair/models/download.dart';
import 'package:openair/models/episode.dart';
import 'package:openair/models/feed.dart';
import 'package:openair/models/history.dart';
import 'package:openair/models/settings.dart';
import 'package:openair/models/subscription.dart';

@GenerateAdapters([
  AdapterSpec<Subscription>(),
  AdapterSpec<Episode>(),
  AdapterSpec<Feed>(),
  AdapterSpec<Queue>(),
  AdapterSpec<Download>(),
  AdapterSpec<History>(),
  AdapterSpec<CompletedEpisode>(),
  AdapterSpec<Settings>(),
])
class HiveAdapters {}
