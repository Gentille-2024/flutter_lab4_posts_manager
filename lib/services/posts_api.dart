import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostsApi {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  PostsApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Post>> fetchPosts() async {
    final response = await _client.get(Uri.parse('$_baseUrl/posts'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception('Failed to load posts');
  }

  Future<Post> createPost(Post post) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create post');
  }

  Future<Post> updatePost(Post post) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/posts/${post.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update post');
  }

  Future<void> deletePost(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}