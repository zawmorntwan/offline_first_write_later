import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/post.dart';
import '../providers/post_providers.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _body = '';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: 5,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a body' : null,
                onSaved: (value) => _body = value!,
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _savePost,
                      child: const Text('Save Offline'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });

      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch, // Use timestamp as temporary ID
        title: _title,
        body: _body,
        userId: 1, // Default user ID for JSONPlaceholder
        isSynced: false,
      );

      try {
        await ref.read(postRepositoryProvider).createPost(newPost);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post saved locally. Will sync when online.')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save post: $e')),
          );
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}
