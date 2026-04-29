import 'package:hive_ce/hive.dart';
import 'package:openair/model/hive_models/completed_episode_model.dart';
import 'package:openair/model/hive_models/download_model.dart';
import 'package:openair/model/hive_models/feed_model.dart';
import 'package:openair/model/hive_models/fetch_data_model.dart';
import 'package:openair/model/hive_models/history_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/model/hive_models/subscription_model.dart';

@GenerateAdapters([
  AdapterSpec<PodcastModel>(),
  AdapterSpec<FeedModel>(),
  AdapterSpec<DownloadModel>(),
  AdapterSpec<HistoryModel>(),
  AdapterSpec<CompletedEpisodeModel>(),
  AdapterSpec<FetchDataModelAdapter>(),
  AdapterSpec<SubscriptionModelAdapter>(),
])
class HiveAdapters {}
