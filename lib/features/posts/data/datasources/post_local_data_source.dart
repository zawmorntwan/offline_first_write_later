import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<List<PostModel>> getPosts();
  Future<List<PostModel>> getPendingPosts();
  Future<void> cachePosts(List<PostModel> posts);
  Future<void> insertPost(PostModel post);
  Future<void> updatePostSyncStatus(int id, bool isSynced);
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final AppDatabase _appDatabase;

  PostLocalDataSourceImpl(this._appDatabase);

  @override
  Future<List<PostModel>> getPosts() async {
    final db = await _appDatabase.database;
    final maps = await db.query('posts', orderBy: 'id DESC');
    return maps.map((map) {
      // Need to convert map to mutable copy to change types if necessary, 
      // but json_serializable can usually handle standard map from sqflite.
      return PostModel.fromJson(map);
    }).toList();
  }

  @override
  Future<List<PostModel>> getPendingPosts() async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'posts',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => PostModel.fromJson(map)).toList();
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    final db = await _appDatabase.database;
    final batch = db.batch();
    
    // For simplicity, we could clear and insert, or insert with replace.
    // In a real app we'd upsert.
    for (var post in posts) {
      batch.insert(
        'posts',
        post.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  @override
  Future<void> insertPost(PostModel post) async {
    final db = await _appDatabase.database;
    await db.insert(
      'posts',
      post.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updatePostSyncStatus(int id, bool isSynced) async {
    final db = await _appDatabase.database;
    await db.update(
      'posts',
      {'is_synced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
