import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/social_post.dart';
import '../models/user.dart';

class SocialService extends ChangeNotifier {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  List<SocialPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SocialPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox<SocialPost>('social_posts');
      _posts = box.values.toList();
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = 'Failed to load posts: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String userId,
    required String userDisplayName,
    String? userPhotoURL,
    required String content,
    List<String> imageUrls = const [],
    required PostType type,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final post = SocialPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userDisplayName: userDisplayName,
        userPhotoURL: userPhotoURL,
        content: content,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        type: type,
        metadata: metadata,
      );

      _posts.insert(0, post);
      await _savePost(post);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create post: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      if (post.isLikedBy(userId)) {
        post.likes.remove(userId);
      } else {
        post.likes.add(userId);
      }

      await _savePost(post);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to like post: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userDisplayName,
    String? userPhotoURL,
    required String content,
  }) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userDisplayName: userDisplayName,
        userPhotoURL: userPhotoURL,
        content: content,
        createdAt: DateTime.now(),
      );

      _posts[postIndex].comments.add(comment);
      await _savePost(_posts[postIndex]);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add comment: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId, String userId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      if (post.userId != userId) {
        _errorMessage = 'You can only delete your own posts';
        notifyListeners();
        return;
      }

      _posts.removeAt(postIndex);
      await _removePost(postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete post: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteComment(String postId, String commentId, String userId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      final commentIndex = post.comments.indexWhere((comment) => comment.id == commentId);
      if (commentIndex == -1) return;

      final comment = post.comments[commentIndex];
      if (comment.userId != userId && post.userId != userId) {
        _errorMessage = 'You can only delete your own comments';
        notifyListeners();
        return;
      }

      post.comments.removeAt(commentIndex);
      await _savePost(post);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete comment: ${e.toString()}';
      notifyListeners();
    }
  }

  List<SocialPost> getPostsByUser(String userId) {
    return _posts.where((post) => post.userId == userId).toList();
  }

  List<SocialPost> getPostsByType(PostType type) {
    return _posts.where((post) => post.type == type).toList();
  }

  Future<void> _savePost(SocialPost post) async {
    final box = await Hive.openBox<SocialPost>('social_posts');
    await box.put(post.id, post);
  }

  Future<void> _removePost(String postId) async {
    final box = await Hive.openBox<SocialPost>('social_posts');
    await box.delete(postId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sample data for demonstration
  Future<void> loadSamplePosts() async {
    if (_posts.isNotEmpty) return;

    final samplePosts = [
      SocialPost(
        id: '1',
        userId: 'sample_user_1',
        userDisplayName: 'John Trainer',
        content: 'Just finished an amazing leg day workout! 💪 Remember, consistency is key!',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: ['user_2', 'user_3'],
        comments: [
          Comment(
            id: '1',
            userId: 'user_2',
            userDisplayName: 'Sarah',
            content: 'Great motivation! 🔥',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        type: PostType.workout,
      ),
      SocialPost(
        id: '2',
        userId: 'sample_user_2',
        userDisplayName: 'Mike Progress',
        content: 'Check out my 3-month transformation! Hard work pays off! 📈',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: ['user_1', 'user_3', 'user_4'],
        comments: [],
        type: PostType.progress,
      ),
      SocialPost(
        id: '3',
        userId: 'sample_user_3',
        userDisplayName: 'Lisa Equipment',
        content: 'New bench press machine arrived at our gym! Can\'t wait to try it out! 🏋️',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: ['user_1'],
        comments: [],
        type: PostType.equipment,
      ),
    ];

    for (final post in samplePosts) {
      await _savePost(post);
    }

    _posts = samplePosts;
    notifyListeners();
  }
}