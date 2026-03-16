import 'package:flutter/material.dart';
import 'models/post.dart';
import 'services/posts_api.dart';
import 'screens/post_form_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Posts Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PostListPage(),
    );
  }
}

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final PostsApi _api = PostsApi();
  List<Post> _posts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final posts = await _api.fetchPosts();
      setState(() => _posts = posts);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load posts: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _addOrUpdatePost(Post post) {
    final index = _posts.indexWhere((p) => p.id == post.id);
    setState(() {
      if (index >= 0) {
        _posts[index] = post; // edit
      } else {
        _posts.insert(0, post); // new
      }
    });
  }

  void _deletePostLocal(int id) {
    setState(() {
      _posts.removeWhere((p) => p.id == id);
    });
  }

  Future<void> _openForm({Post? post}) async {
    final result = await Navigator.of(context).push<Post>(
      MaterialPageRoute(builder: (_) => PostFormPage(post: post)),
    );

    if (result != null) {
      _addOrUpdatePost(result);
    }
  }

  // Updated delete method with confirmation
  Future<void> _deletePost(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete post "${post.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return; // Cancel deletion if false

    _deletePostLocal(post.id!);
    try {
      await _api.deletePost(post.id!);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Post deleted')));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Manager'),
        actions: [
          Tooltip(
            message: 'Refresh Posts',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPosts,
            ),
          ),
        ],
      ),
      floatingActionButton: Tooltip(
        message: "Create New Post",
        child: FloatingActionButton(
          onPressed: () => _openForm(),
          child: const Icon(Icons.add),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          post.id.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(post.title),
                      subtitle: Text(post.body),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: "Edit Post",
                            child: IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _openForm(post: post),
                            ),
                          ),
                          Tooltip(
                            message: "Delete Post",
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePost(post),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}