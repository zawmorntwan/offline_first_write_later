import '../../../../core/network/dio_client.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> createPost(PostModel post);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PostModel>> getPosts() async {
    final response = await _dioClient.dio.get('/posts');
    final data = response.data as List;
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    final response = await _dioClient.dio.post(
      '/posts',
      data: post.toJson(),
    );
    return PostModel.fromJson(response.data);
  }
}
