import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/social_service.dart';
import '../../models/social_post.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  late Future<List<SocialPost>> _postsFuture;
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    final socialService = SocialService();
    _postsFuture = socialService.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadPosts();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Create Post Section
          _buildCreatePostSection(),
          
          // Posts Feed
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadPosts();
                });
              },
              child: FutureBuilder<List<SocialPost>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppConstants.defaultSpacing),
                          Text(
                            'Error loading posts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final posts = snapshot.data ?? [];
                  
                  if (posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppConstants.defaultSpacing),
                          Text(
                            'No posts yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share your workout!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(posts[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.greyLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.defaultSpacing),
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Share your workout progress...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.defaultSpacing,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: AppConstants.defaultSpacing),
          ElevatedButton(
            onPressed: _isPosting ? null : _createPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultSpacing,
              ),
            ),
            child: _isPosting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(SocialPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userDisplayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle menu actions
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Text('Block User'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // Post Content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            // Post Type Badge
            if (post.type != PostType.general)
              Container(
                margin: const EdgeInsets.only(top: AppConstants.defaultSpacing),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultSpacing,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPostTypeColor(post.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Text(
                  _getPostTypeText(post.type),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getPostTypeColor(post.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // Post Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _toggleLike(post),
                  icon: Icon(
                    post.isLikedBy('current_user_id') ? Icons.favorite : Icons.favorite_border,
                    color: post.isLikedBy('current_user_id') ? AppColors.error : AppColors.textSecondary,
                    size: 20,
                  ),
                  label: Text(
                    '${post.likeCount}',
                    style: TextStyle(
                      color: post.isLikedBy('current_user_id') ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultSpacing),
                TextButton.icon(
                  onPressed: () => _showComments(post),
                  icon: const Icon(
                    Icons.comment_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  label: Text(
                    '${post.commentCount}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _sharePost(post),
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  label: const Text(
                    'Share',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final socialService = SocialService();
      await socialService.createPostSimple(
        content: _postController.text.trim(),
        type: PostType.general,
      );

      _postController.clear();
      setState(() {
        _loadPosts();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating post: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Future<void> _toggleLike(SocialPost post) async {
    try {
      final socialService = SocialService();
      if (post.isLikedBy('current_user_id')) {
        await socialService.unlikePost(post.id);
      } else {
        await socialService.likePostSimple(post.id);
      }

      setState(() {
        _loadPosts();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showComments(SocialPost post) {
    // TODO: Implement comments screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comments feature coming soon!'),
      ),
    );
  }

  void _sharePost(SocialPost post) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.workout:
        return AppColors.primary;
      case PostType.progress:
        return AppColors.success;
      case PostType.equipment:
        return AppColors.warning;
      case PostType.motivation:
        return AppColors.secondary;
      case PostType.general:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPostTypeText(PostType type) {
    switch (type) {
      case PostType.workout:
        return 'Workout';
      case PostType.progress:
        return 'Progress';
      case PostType.equipment:
        return 'Equipment';
      case PostType.motivation:
        return 'Motivation';
      case PostType.general:
        return 'General';
      default:
        return 'Post';
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
