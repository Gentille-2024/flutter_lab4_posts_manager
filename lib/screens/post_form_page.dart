import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/posts_api.dart';

class PostFormPage extends StatefulWidget {
  const PostFormPage({super.key, this.post});
  final Post? post;

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();
  final PostsApi _api = PostsApi();

  late final TextEditingController _idController;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _loading = false;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _idController =
        TextEditingController(text: widget.post?.id?.toString() ?? '');
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final post = Post(
      id: _isEditing
          ? widget.post?.id
          : int.tryParse(_idController.text.trim()) ?? 0,
      userId: widget.post?.userId ?? 1,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );

    try {
      Post savedPost;
      if (_isEditing) {
        savedPost = await _api.updatePost(post);
      } else {
        savedPost = await _api.createPost(post);
      }

      if (!mounted) return;
      Navigator.of(context).pop(savedPost); // return post to list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save post: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = _isEditing ? Colors.orange : Colors.blue;
    final Color buttonColor = _isEditing ? Colors.orangeAccent : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Post' : 'Create Post'),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Post ID',
                  labelStyle:
                      TextStyle(color: _isEditing ? Colors.orange : Colors.blue),
                ),
                readOnly: _isEditing,
                validator: (value) {
                  if (!_isEditing) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ID is required';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'ID must be a number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle:
                      TextStyle(color: _isEditing ? Colors.orange : Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                  labelStyle:
                      TextStyle(color: _isEditing ? Colors.orange : Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Body is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Create Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}