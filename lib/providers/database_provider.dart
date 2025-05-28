import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

class DatabaseService {
  late Database _database;

  Future<void> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // Define the directory path for 'OpenAir'
    final dbDirectoryPath = join(documentsDirectory.path, 'OpenAir');
    final dbPath = join(dbDirectoryPath, 'openair_db.db');

    // Create the directory if it doesn't exist
    final dbDirectory = Directory(dbDirectoryPath);

    if (!await dbDirectory.exists()) {
      await dbDirectory.create(
          recursive:
              true); // recursive: true creates parent directories if needed
    }

    final db = sqlite3.open(dbPath);
    _database = db;
    _onCreate();
  }

  // todo: Figure out how to add images to the database
  void _onCreate() {
    _database.execute('''
      CREATE TABLE IF NOT EXISTS Subscriptions (
        id INTEGER PRIMARY KEY,
        feedUrl TEXT NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        imageUrl TEXT NOT NULL
      );
    ''');

    _database.execute('''
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
        podcastId TEXT NOT NULL
      );
    ''');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS Feed (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
    ''');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS Queue (
        guid TEXT PRIMARY KEY NOT NULL,
        pos INTEGER NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
    ''');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS Downloads (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
        );
    ''');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS History (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
        );
    ''');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS CompletedEpisodes (
        guid TEXT PRIMARY KEY NOT NULL,
        FOREIGN KEY (guid) REFERENCES Episodes(guid)
      );
      ''');
  }

  // Podcast Operations:
  void subscribe({
    required int id,
    required String feedUrl,
    required String title,
    required String author,
    required String imageUrl,
  }) {
    _database.execute('''
      INSERT INTO Subscriptions
      (id, feedUrl, title, author, imageUrl)
      VALUES (
      $id,
      "$feedUrl",
      "$title",
      "$author",
      "$imageUrl"
      );
      ''');
  }

  void unsubscribe({required int id}) {
    _database.execute('''
        DELETE FROM Subscriptions
        WHERE id = '$id';
        ''');
  }

  ResultSet getSubscriptions() {
    return _database.select('''
        SELECT *
        FROM Subscriptions;
        ''');
  }

  ResultSet getSubscription({required int id}) {
    return _database.select('''
        SELECT *
        FROM Subscriptions
        WHERE id = '$id';
        ''');
  }

  void deleteSubscriptions() {
    _database.execute('''
        DELETE FROM Subscriptions;
        ''');
  }

  void deleteSubscription({required int id}) {
    _database.execute('''
        DELETE FROM Subscriptions
        WHERE id = '$id';
        ''');
  }

  // Episode Operations:
  void insertEpisode({
    required String guid,
    required String title,
    required String description,
    required String feedUrl,
    required String imageUrl,
    required String author,
    required String duration,
    required String datePublished,
    required String size,
    required String podcastId,
  }) {
    _database.execute('''
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

  void deleteEpisode({required String guid}) {
    _database.execute('''
      DELETE FROM Episodes
      WHERE guid = $guid;
    ''');
  }

  ResultSet? getEpisodesForPodcast({required String podcastId}) {
    return _database.select('''
      SELECT *
      FROM Episodes
      WHERE podcastId = $podcastId;
    ''');
  }

  ResultSet? getEpisode({required String guid}) {
    return _database.select('''
      SELECT *
      FROM Episodes
      WHERE guid = $guid;
    ''');
  }

  // Feed Operations:
  void addToFeed({required String episodeGuid}) {
    _database.execute('''
      INSERT INTO Feed (guid)
      VALUES ('$episodeGuid');
    ''');
  }

  ResultSet? getFeed() {
    return _database.select('''
      SELECT *
      FROM Feed;
    ''');
  }

  void deleteFeed() {
    _database.execute('''
      DELETE FROM Feed;
    ''');
  }

  void deleteFromFeed({required String episodeGuid}) {
    _database.execute('''
      DELETE FROM Feed
      WHERE guid = '$episodeGuid';
    ''');
  }

  // Queue Operations:
  void addToQueue({required String episodeGuid, required int pos}) {
    _database.execute('''
      INSERT INTO Queue (guid, pos)
      VALUES ('$episodeGuid', $pos);
    ''');
  }

  ResultSet? getQueue() {
    return _database.select('''
      SELECT *
      FROM Queue
      ORDER BY pos ASC;
    ''');
  }

  void removeFromQueue({required String guid}) {
    _database.execute('''
      DELETE FROM Queue
      WHERE guid = '$guid';
    ''');
  }

  void clearQueue() {
    _database.execute('''
      DELETE FROM Queue;
    ''');
  }

  // TODO: Implement a reorderQueue method that tightly couple the pos together
  // This should get the fetch the list then sort it in ASC order
  void reorderQueue() {}

  // Download Operations:
  void addToDownloadedEpisodes({required String guid}) {
    _database.execute('''
      INSERT INTO Downloads (guid)
      VALUES ('$guid');
    ''');
  }

  ResultSet? getDownloadedEpisodes() {
    return _database.select('''
      SELECT *
      FROM Downloads;
    ''');
  }

  void deleteDownloadedEpisodes() {
    _database.execute('''
      DELETE FROM Downloads;
    ''');
  }

  void deleteDownloadedEpisode({required String episodeGuid}) {
    _database.execute('''
      DELETE FROM Downloads
      WHERE guid = '$episodeGuid';
    ''');
  }

  // History Operations:
  void addToHistory({required String episodeGuid}) {
    _database.execute('''
      INSERT INTO History (guid)
      VALUES ('$episodeGuid');
    ''');
  }

  ResultSet? getHistory() {
    return _database.select('''
      SELECT *
      FROM History;
    ''');
  }

  void deleteHistory() async {
    _database.execute('''
      DELETE FROM History;
    ''');
  }

  void deleteFromHistory({required String episodeGuid}) {
    _database.execute('''
      DELETE FROM History
      WHERE guid = '$episodeGuid';
    ''');
  }

  // Completed Episodes Operations:
  void markEpisodeAsCompleted({required String episodeGuid}) {
    _database.execute('''
      INSERT INTO CompletedEpisodes (guid)
      VALUES ('$episodeGuid');
    ''');
  }

  ResultSet? getCompletedEpisodes() {
    return _database.select('''
      SELECT *
      FROM CompletedEpisodes;
    ''');
  }

  void deleteCompletedEpisodes() {
    _database.execute('''
      DELETE FROM CompletedEpisodes;
    ''');
  }
}
