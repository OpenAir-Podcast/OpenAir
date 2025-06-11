import 'dart:collection';

import 'package:hive_ce/hive.dart';
import 'package:openair/models/completed_episode_model.dart';
import 'package:openair/models/download_model.dart';
import 'package:openair/models/episode_model.dart';
import 'package:openair/models/feed_model.dart';
import 'package:openair/models/history_model.dart';
import 'package:openair/models/settings_model.dart';
import 'package:openair/models/subscription_model.dart';

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
