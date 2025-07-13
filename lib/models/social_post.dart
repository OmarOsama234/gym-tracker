import 'package:hive/hive.dart';

part 'social_post.g.dart';

@HiveType(typeId: 3)
class SocialPost extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String userDisplayName;

  @HiveField(3)
  String? userPhotoURL;

  @HiveField(4)
  String content;

  @HiveField(5)
  List<String> imageUrls;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  List<String> likes;

  @HiveField(8)
  List<Comment> comments;

  @HiveField(9)
  PostType type;

  @HiveField(10)
  Map<String, dynamic> metadata;

  SocialPost({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoURL,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
    required this.type,
    this.metadata = const {},
  });

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  int get likeCount => likes.length;
  int get commentCount => comments.length;

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      userId: json['userId'],
      userDisplayName: json['userDisplayName'],
      userPhotoURL: json['userPhotoURL'],
      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e))
          .toList(),
      type: PostType.values[json['type']],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoURL': userPhotoURL,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments.map((e) => e.toJson()).toList(),
      'type': type.index,
      'metadata': metadata,
    };
  }
}

@HiveType(typeId: 4)
class Comment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String userDisplayName;

  @HiveField(3)
  String? userPhotoURL;

  @HiveField(4)
  String content;

  @HiveField(5)
  DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoURL,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      userDisplayName: json['userDisplayName'],
      userPhotoURL: json['userPhotoURL'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoURL': userPhotoURL,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 5)
enum PostType {
  @HiveField(0)
  workout,
  @HiveField(1)
  progress,
  @HiveField(2)
  motivation,
  @HiveField(3)
  equipment,
  @HiveField(4)
  general,
}

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.workout:
        return 'Workout';
      case PostType.progress:
        return 'Progress';
      case PostType.motivation:
        return 'Motivation';
      case PostType.equipment:
        return 'Equipment';
      case PostType.general:
        return 'General';
    }
  }

  String get emoji {
    switch (this) {
      case PostType.workout:
        return '💪';
      case PostType.progress:
        return '📈';
      case PostType.motivation:
        return '🔥';
      case PostType.equipment:
        return '🏋️';
      case PostType.general:
        return '💬';
    }
  }
}