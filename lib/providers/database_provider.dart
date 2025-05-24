import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

class DatabaseService {
  Database? _database;

  void database() async => _database = await initDatabase();

  Future<Database> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, 'openair_db');
    final db = sqlite3.open(dbPath);
    _onCreate();
    return db;
  }

  // todo: Figure out how to add images to the database
  void _onCreate() {
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Podcasts (
        id INTEGER PRIMARY KEY,
        feedUrl TEXT NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        isSubscribed BOOLEAN NOT NULL DEFAULT (0),
      );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Episodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        podcastGuid TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        feedUrl TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        author TEXT NOT NULL,
        duration TEXT NOT NULL,
        datePublished TEXT NOT NULL,
        size TEXT,
      );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS CompletedEpisodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guid TEXT NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
      ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Queue (
        guid TEXT PRIMARY KEY,
        index INTEGER NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
    ''');
  }

  // Podcast Operations:
  void insertPodcast(
      String guid, String feedUrl, String title, String imageUrl) async {
    _database!.execute('''
      INSERT INTO Podcasts
      (guid, feedUrl, title, imageUrl, isSubscribed)
      VALUES (
      $guid,
      '$feedUrl',
      '$title,
      '$imageUrl',
      False
      );
      ''');
  }

  void subscribePodcast(int guid) async {
    _database!.execute('''
        UPDATE Podcasts
        SET isSubscribed = True
        WHERE guid = '$guid';
        ''');
  }

  void unsubscribePodcast(int guid) async {
    _database!.execute('''
        UPDATE Podcasts
        SET isSubscribed = False
        WHERE guid = '$guid';
        ''');
  }

  Future<ResultSet> getSubscribedPodcasts() async {
    return _database!.select('''
        SELECT *
        FROM Podcasts
        WHERE isSubscribe = True;
        ''');
  }

  Future<ResultSet> getAllPodcasts(String feedUrl) async {
    return _database!.select('''
        SELECT *
        FROM Podcasts;
        ''');
  }

  // Episode Operations:
  void insertEpisode(
    String podcastGuid,
    String title,
    String description,
    String feedUrl,
    String imageUrl,
    String author,
    String duration,
    String datePublished,
    String size,
  ) async {
    _database!.execute('''
      INSERT INTO Episodes (podcastGuid, title, description, feedUrl, imageUrl, author, duration, datePublished, size)
      VALUES (
      $podcastGuid,
      $title,
      $description,
      $feedUrl,
      $imageUrl,
      $author,
      $duration,
      $datePublished,
      $size,
      );
    ''');
  }

  Future<ResultSet?> getEpisodesForPodcast(String podcastFeedUrl) async {
    return _database!.select('''
    ''');
  }

  void markEpisodeAsDownloaded(int episodeId) async {}

  void markEpisodeAsNotDownloaded(int episodeId) async {}

  Future<ResultSet?> getEpisode(int episodeId) async {
    return null;
  }

  // Queue Operations:
  void addToQueue(int episodeId) async {}

  Future<ResultSet?> getQueue() async {
    return null;
  }

  void removeFromQueue(int queueItemId) async {}

  Future<void> clearQueue() async {}

  Future<void> reorderQueue(List<int> episodeIds) async {}
}
