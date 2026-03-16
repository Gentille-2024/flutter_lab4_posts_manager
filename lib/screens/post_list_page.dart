import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/posts_api.dart';
import 'post_detail_page.dart';
import 'post_form_page.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final PostsApi _api = PostsApi();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() {
    setState(() {
      _postsFuture = _api.fetchPosts();
    });
  }

  Future<void> _openCreatePostForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PostFormPage(),
      ),
    );

    if (!mounted) return;

    if (created == true) {
      _refreshPosts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
    }
  }

  Future<void> _openEditPostForm(Post post) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PostFormPage(post: post),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      _refreshPosts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );
    }
  }

  Future<void> _openPostDetail(Post post) async {
    final didChange = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PostDetailPage(
          post: post,
          onEdit: () => _openEditPostForm(post),
          onDeleted: _refreshPosts,
        ),
      ),
    );

    if (!mounted) return;

    if (didChange == true) {
      _refreshPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Posts Manager'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPosts,
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to load posts.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPosts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              _refreshPosts();
              await _postsFuture;
            },

            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),

              itemBuilder: (context, index) {
                final post = posts[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '#${(index + 1).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  title: Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.blue,
                  ),

                  onTap: () => _openPostDetail(post),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePostForm,
        backgroundColor: Colors.blue,
        tooltip: 'Create Post',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}