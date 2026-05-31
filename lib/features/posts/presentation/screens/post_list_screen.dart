import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/post_providers.dart';

class PostListScreen extends ConsumerStatefulWidget {
  const PostListScreen({super.key});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  @override
  void initState() {
    super.initState();
    // Attempt to sync pending posts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postRepositoryProvider).syncPendingPosts().then((_) {
        // Refresh the list after sync attempt
        ref.invalidate(postListProvider);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsAsyncValue = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await ref.read(postRepositoryProvider).syncPendingPosts();
              ref.invalidate(postListProvider);
            },
          )
        ],
      ),
      body: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(postRepositoryProvider).syncPendingPosts();
              ref.invalidate(postListProvider);
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: post.isSynced
                      ? const Icon(Icons.cloud_done, color: Colors.green)
                      : const Icon(Icons.cloud_upload, color: Colors.orange),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-post').then((_) {
            // Refresh list when returning from Add Screen
            ref.invalidate(postListProvider);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
