import 'package:logger/logger.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_data_source.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostLocalDataSource _localDataSource;
  final PostRemoteDataSource _remoteDataSource;
  final Logger _logger;

  PostRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._logger,
  );

  @override
  Future<List<Post>> getPosts() async {
    // 1. Trigger background fetch to update local cache
    _fetchRemoteAndCache();

    // 2. Immediately return local data (offline-first)
    final localPosts = await _localDataSource.getPosts();
    return localPosts.map((model) => model.toEntity()).toList();
  }

  Future<void> _fetchRemoteAndCache() async {
    try {
      final remotePosts = await _remoteDataSource.getPosts();
      // Ensure we don't overwrite pending offline posts by marking fetched as synced
      final syncedPosts = remotePosts.map((p) => p.copyWith(isSynced: 1)).toList();
      await _localDataSource.cachePosts(syncedPosts);
    } catch (e) {
      _logger.e('Failed to fetch remote posts: $e');
    }
  }

  @override
  Future<void> createPost(Post post) async {
    // 1. Save locally with isSynced = false
    final postModel = PostModel.fromEntity(post).copyWith(isSynced: 0);
    await _localDataSource.insertPost(postModel);

    // 2. Attempt to sync
    syncPendingPosts();
  }

  @override
  Future<void> syncPendingPosts() async {
    try {
      final pendingPosts = await _localDataSource.getPendingPosts();
      for (final post in pendingPosts) {
        try {
          // JSONPlaceholder returns the created object with a new ID.
          // In a real scenario, we'd update the local ID with the remote ID.
          await _remoteDataSource.createPost(post);
          
          // If successful, mark as synced
          await _localDataSource.updatePostSyncStatus(post.id, true);
          _logger.i('Successfully synced post ${post.id}');
        } catch (e) {
          _logger.e('Failed to sync post ${post.id}: $e');
        }
      }
    } catch (e) {
      _logger.e('Error during sync process: $e');
    }
  }
}
