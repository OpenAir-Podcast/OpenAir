import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

class DatabaseService {
  Database? _database;

  Future<void> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, 'openair_db');
    final db = sqlite3.open(dbPath);
    _database = db;
    _onCreate();
  }

  // todo: Figure out how to add images to the database
  void _onCreate() {
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Subscriptions (
        id INTEGER PRIMARY KEY,
        feedUrl TEXT NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        imageUrl TEXT NOT NULL
      );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Episodes (
        guid TEXT PRIMARY KEY NOT NULL,
        imageUrl TEXT NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        datePublished TEXT NOT NULL,
        description TEXT NOT NULL,
        feedUrl TEXT NOT NULL,
        duration TEXT NOT NULL,
        size TEXT,
        podcastId TEXT NOT NULL,
      );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Feed (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Queue (
        guid TEXT PRIMARY KEY NOT NULL,
        pos INTEGER NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS Downloads (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
        );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS History (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
        );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS CompletedEpisodes (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
      ''');
  }

  // Podcast Operations:
  void subscribePodcast(
      String id, String feedUrl, String title, String author, String imageUrl) {
    _database!.execute('''
      INSERT INTO Subscriptions
      (id, feedUrl, title, author, imageUrl)
      VALUES (
      $id,
      '$feedUrl',
      '$title,
      '$author',
      '$imageUrl'
      );
      ''');
  }

  void unsubscribePodcast(String podcastGuid) {
    _database!.execute('''
        DELETE FROM Subscriptions
        WHERE id = '$podcastGuid';
        ''');
  }

  ResultSet getSubscribedPodcasts() {
    return _database!.select('''
        SELECT *
        FROM Subscriptions;
        ''');
  }

  void deleteSubscribedPodcasts() {
    _database!.execute('''
        DELETE FROM Subscriptions;
        ''');
  }

  void deleteSubscribedPodcast(int id) {
    _database!.execute('''
        DELETE FROM Subscriptions
        WHERE id = $id;
        ''');
  }

  // Episode Operations:
  void insertEpisode(
    String guid,
    String title,
    String description,
    String feedUrl,
    String imageUrl,
    String author,
    String duration,
    String datePublished,
    String size,
    String podcastId,
  ) {
    _database!.execute('''
      INSERT INTO Episodes (
      guid,
      title,
      description,
      feedUrl,
      imageUrl,
      author,
      duration,
      datePublished,
      size,
      podcastId)
      VALUES (
      $guid,
      $title,
      $description,
      $feedUrl,
      $imageUrl,
      $author,
      $duration,
      $datePublished,
      $size,
      $podcastId
      );
    ''');
  }

  void deleteEpisode(String guid) {
    _database!.execute('''
      DELETE FROM Episodes
      WHERE guid = $guid;
    ''');
  }

  ResultSet? getEpisodesForPodcast(String podcastId) {
    return _database!.select('''
      SELECT *
      FROM Episodes
      WHERE podcastId = $podcastId;
    ''');
  }

  ResultSet? getEpisode(String guid) {
    return _database!.select('''
      SELECT *
      FROM Episodes
      WHERE guid = $guid;
    ''');
  }

  // Feed Operations:
  void addToFeed(String episodeGuid) {
    _database!.execute('''
      INSERT INTO Feed (guid)
      VALUES ('$episodeGuid');
    ''');
  }

  ResultSet? getFeed() {
    return _database!.select('''
      SELECT *
      FROM Feed;
    ''');
  }

  void deleteFeed() {
    _database!.execute('''
      DELETE FROM Feed;
    ''');
  }

  void deleteFromFeed(String episodeGuid) {
    _database!.execute('''
      DELETE FROM Feed
      WHERE guid = '$episodeGuid';
    ''');
  }

  // Queue Operations:
  void addToQueue(String episodeGuid, int pos) {
    _database!.execute('''
      INSERT INTO Queue (guid, pos)
      VALUES ('$episodeGuid', $pos);
    ''');
  }

  ResultSet? getQueue() {
    return _database!.select('''
      SELECT *
      FROM Queue
      ORDER BY pos ASC;
    ''');
  }

  void removeFromQueue(String episodeGuid) {
    _database!.execute('''
      DELETE FROM Queue
      WHERE guid = '$episodeGuid';
    ''');
  }

  void clearQueue() {
    _database!.execute('''
      DELETE FROM Queue;
    ''');
  }

  // TODO: Implement a reorderQueue method that tightly couple the pos together
  // This should get the fetch the list then sort it in ASC order
  void reorderQueue() {}

  // Download Operations:
  void addToDownloadedEpisodes(String episodeGuid) {
    _database!.execute('''
      INSERT INTO Downloads (guid)
      VALUES ('$episodeGuid');
    ''');
  }

  ResultSet? getDownloadedEpisodes() {
    return _database!.select('''
      SELECT *
      FROM Downloads;
    ''');
  }

  void deleteDownloadedEpisodes() {
    _database!.execute('''
      DELETE FROM Downloads;
    ''');
  }

  void deleteDownloadedEpisode(String episodeGuid) {
    _database!.execute('''
      DELETE FROM Downloads
      WHERE guid = '$episodeGuid';
    ''');
  }

  // History Operations:
  void addToHistory(String episodeGuid) {
    _database!.execute('''
      INSERT INTO History (guid)
      VALUES ('$episodeGuid');
    ''');
  }

  ResultSet? getHistory() {
    return _database!.select('''
      SELECT *
      FROM History;
    ''');
  }

  void deleteHistory() async {
    _database!.execute('''
      DELETE FROM History;
    ''');
  }

  void deleteFromHistory(String episodeGuid) {
    _database!.execute('''
      DELETE FROM History
      WHERE guid = '$episodeGuid';
    ''');
  }

  // Completed Episodes Operations:
  void markEpisodeAsCompleted(String episodeGuid) {
    _database!.execute('''
      INSERT INTO CompletedEpisodes (guid)
      VALUES ('$episodeGuid');
    ''');
  }

  ResultSet? getCompletedEpisodes() {
    return _database!.select('''
      SELECT *
      FROM CompletedEpisodes;
    ''');
  }

  void deleteCompletedEpisodes() {
    _database!.execute('''
      DELETE FROM CompletedEpisodes;
    ''');
  }
}
