import 'package:hive_ce/hive.dart';
import 'package:openair/models/completed_episode_model.dart';
import 'package:openair/models/download_model.dart';
import 'package:openair/models/episode_model.dart';
import 'package:openair/models/feed_model.dart';
import 'package:openair/models/fetch_data_model.dart';
import 'package:openair/models/history_model.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/models/settings_model.dart';
import 'package:openair/models/podcast_model.dart';
import 'package:openair/models/subscription_model.dart';

part 'hive_registrar.g.dart';

@GenerateAdapters([
  AdapterSpec<PodcastModel>(),
  AdapterSpec<EpisodeModel>(),
  AdapterSpec<FeedModel>(),
  AdapterSpec<QueueModel>(),
  AdapterSpec<DownloadModel>(),
  AdapterSpec<HistoryModel>(),
  AdapterSpec<CompletedEpisodeModel>(),
  AdapterSpec<SettingsModel>(),
  AdapterSpec<FetchDataModelAdapter>(),
  AdapterSpec<SubscriptionModelAdapter>(),
])
class HiveAdapters {}
