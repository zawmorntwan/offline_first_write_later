import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../data/datasources/post_local_data_source.dart';
import '../../data/datasources/post_remote_data_source.dart';
import '../../data/repositories/post_repository_impl.dart';

final loggerProvider = Provider<Logger>((ref) => Logger());

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final postLocalDataSourceProvider = Provider<PostLocalDataSource>((ref) {
  return PostLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return PostRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    ref.watch(postLocalDataSourceProvider),
    ref.watch(postRemoteDataSourceProvider),
    ref.watch(loggerProvider),
  );
});

final postListProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPosts();
});
