import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts();
  Future<void> createPost(Post post);
  Future<void> syncPendingPosts();
}
