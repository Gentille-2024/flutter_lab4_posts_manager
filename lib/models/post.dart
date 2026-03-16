class Post {
  int? id;
  int? userId;
  String title;
  String body;

  Post({
    this.id,
    this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int?,
        userId: json['userId'] as int?,
        title: json['title'] as String,
        body: json['body'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };
}