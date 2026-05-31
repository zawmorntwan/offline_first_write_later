import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/post.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
abstract class PostModel with _$PostModel {
  const factory PostModel({
    required int id,
    required String title,
    required String body,
    required int userId,
    @JsonKey(name: 'is_synced')
    @Default(1)
    int isSynced, // 1 for true, 0 for false in SQLite
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  const PostModel._();

  factory PostModel.fromEntity(Post entity) {
    return PostModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      userId: entity.userId,
      isSynced: entity.isSynced ? 1 : 0,
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      title: title,
      body: body,
      userId: userId,
      isSynced: isSynced == 1,
    );
  }
}
