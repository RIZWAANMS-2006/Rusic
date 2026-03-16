import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../ui/media_ui.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;

  DatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('rusic_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      // Initialize FFI for desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';

    await db.execute('''
CREATE TABLE online_songs (
  id $idType,
  url $textType UNIQUE,
  title $textType,
  artist $textNullable,
  album $textNullable
)
''');

    await db.execute('''
CREATE TABLE favorites (
  id $idType,
  url $textType UNIQUE
)
''');
  }

  Future<void> cacheOnlineSongs(List<OnlineSong> songs) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('online_songs');
      for (final song in songs) {
        await txn.insert('online_songs', {
          'url': song.url,
          'title': song.title,
          'artist': song.artist,
          'album': song.album,
        });
      }
    });
  }

  Future<List<OnlineSong>> getCachedOnlineSongs() async {
    final db = await database;
    final maps = await db.query('online_songs');
    return maps.map((map) {
      return OnlineSong(
        title: map['title'] as String,
        url: map['url'] as String,
        artist: map['artist'] as String?,
        album: map['album'] as String?,
      );
    }).toList();
  }

  Future<void> toggleFavorite(String url) async {
    final db = await database;
    final isFav = await isFavorite(url);
    if (isFav) {
      await db.delete('favorites', where: 'url = ?', whereArgs: [url]);
    } else {
      await db.insert('favorites', {
        'url': url,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<bool> isFavorite(String url) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'url = ?',
      whereArgs: [url],
    );
    return maps.isNotEmpty;
  }
}
