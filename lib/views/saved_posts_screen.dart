import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/post.dart';
import '../widgets/video_background.dart';
import 'post_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'assets/backdrop2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Saved Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Posts')),
              const PopupMenuItem(value: 'Community', child: Text('Community Posts')),
              const PopupMenuItem(value: 'Reddit', child: Text('Reddit Posts')),
            ],
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final savedPosts = appState.savedPosts;
          
          if (savedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Saved Posts',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save posts from the community feed to view them here later',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Apply filters
          List<Post> filteredPosts = savedPosts;
          
          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            filteredPosts = filteredPosts.where((post) =>
              post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              post.author.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }
          
          // Apply type filter
          if (_selectedFilter != 'All') {
            filteredPosts = filteredPosts.where((post) {
              if (_selectedFilter == 'Reddit') {
                return post.postType == 'reddit';
              } else if (_selectedFilter == 'Community') {
                return post.postType == 'community';
              }
              return true;
            }).toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              
              // For Reddit posts, show as simple links
              if (post.postType == 'reddit' && post.redditUrl != null) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.link, color: Colors.orange),
                    title: Text(
                      post.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Reddit Link',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.orange),
                      onPressed: () => appState.unsavePost(post),
                    ),
                    onTap: () async {
                      final url = Uri.parse(post.redditUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                );
              }
              
              // For community posts, show as regular posts
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      post.author.isNotEmpty ? post.author[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.content),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${post.postType} • ${_formatTimeAgo(post.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'by ${post.author}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark, color: Colors.orange),
                    onPressed: () => appState.unsavePost(post),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }

  Widget _buildSavedPostCard(BuildContext context, Post post, AppStateProvider appState) {
    final isReddit = post.postType == 'reddit';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewPost(context, post),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Post type indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isReddit ? Colors.orange : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isReddit ? Icons.reddit : Icons.forum,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                              isReddit ? 'Reddit' : 'Community',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                              'by ${post.author}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${post.petType} • ${_formatDate(post.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      switch (value) {
                        case 'view':
                          _viewPost(context, post);
                          break;
                        case 'unsave':
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Unsave Post'),
                              content: const Text('Are you sure you want to unsave this post?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Unsave',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            try {
                              await appState.unsavePost(post);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unsaved "${post.title}"')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to unsave post: $e')),
                              );
                            }
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'unsave',
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_remove, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Unsave', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPost(BuildContext context, Post post) {
    if (post.postType == 'reddit' && post.redditUrl != null) {
      // For Reddit posts, open the URL in browser
      _launchRedditUrl(post.redditUrl!);
    } else {
      // For community posts, navigate to detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(post: post),
        ),
      );
    }
  }
  
  void _launchRedditUrl(String url) async {
    try {
      // Use url_launcher to open Reddit URL in browser
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open Reddit link: $e')),
        );
      }
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Saved Posts'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by title, content, or author...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 