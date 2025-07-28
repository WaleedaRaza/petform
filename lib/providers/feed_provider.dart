import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';
import '../models/pet_types.dart';
import '../models/post.dart';
import '../models/reddit_post.dart';
import '../providers/app_state_provider.dart';

class FeedProvider with ChangeNotifier {
  String _selectedPetType = 'All';
  String _selectedPostType = 'All';
  List<Post> _posts = [];
  List<Post> _cachedRedditPosts = []; // Cache for Reddit posts (as Post objects)
  Map<String, List<Post>> _cachedPetTypePosts = {}; // Cache by pet type
  bool _isLoading = false;
  bool _isFetching = false; // Prevent multiple simultaneous fetches
  DateTime? _lastRedditFetch; // Track when Reddit posts were last fetched
  Map<String, DateTime?> _lastPetTypeFetch = {}; // Track when each pet type was last fetched

  String get selectedPetType => _selectedPetType;
  String get selectedPostType => _selectedPostType;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPetType(String petType) {
    if (_selectedPetType != petType) {
      _selectedPetType = petType;
      // Don't call notifyListeners here - fetchPosts will call it
    }
  }

  void setPostType(String postType) {
    if (_selectedPostType != postType) {
      _selectedPostType = postType;
      // Don't call notifyListeners here - fetchPosts will call it
    }
  }

  // Clear cache for a specific pet type or all
  void clearCache({String? petType}) {
    if (petType != null) {
      _cachedPetTypePosts.remove(petType);
      _lastPetTypeFetch.remove(petType);
      if (kDebugMode) {
        print('FeedProvider: Cleared cache for $petType');
      }
    } else {
      _cachedPetTypePosts.clear();
      _lastPetTypeFetch.clear();
      if (kDebugMode) {
        print('FeedProvider: Cleared all caches');
      }
    }
  }

  Future<void> fetchPosts(BuildContext context, {bool forceRefresh = false}) async {
    print('FeedProvider: fetchPosts called! forceRefresh: $forceRefresh');
    if (_isFetching) {
      print('FeedProvider: Already fetching, skipping...');
      return; // Prevent multiple simultaneous fetches
    }
    
    _isFetching = true;
    _isLoading = true;
    notifyListeners();

    try {
      List<Post> allPosts = [];
      
      // Get community posts from Supabase
      if (_selectedPostType == 'All' || _selectedPostType == 'Community') {
        try {
          final supabasePosts = await SupabaseService.getPosts();
          final communityPosts = supabasePosts
              .map((postData) => Post.fromJson(postData))
              .where((post) => 
                  post.id != null && 
                  _isValidUUID(post.id!) &&
                  !post.content.startsWith('http')) // Exclude posts with URLs (saved Reddit posts)
              .toList();
          allPosts.addAll(communityPosts);
          
          if (kDebugMode) {
            print('FeedProvider: Loaded ${communityPosts.length} community posts from Supabase (filtered for valid UUIDs and excluding saved Reddit posts)');
          }
        } catch (e) {
          if (kDebugMode) {
            print('FeedProvider: Error loading community posts from Supabase: $e');
          }
        }
      }
      
      // REDDIT POSTS - Different strategy based on pet type
      if (_selectedPostType == 'All' || _selectedPostType == 'Reddit') {
        // Check if we should use cached Reddit posts
        final shouldUseCache = !forceRefresh && 
            _cachedPetTypePosts.containsKey(_selectedPetType) &&
            _lastPetTypeFetch[_selectedPetType] != null &&
            DateTime.now().difference(_lastPetTypeFetch[_selectedPetType]!).inMinutes < 5; // Cache for 5 minutes
        
        if (shouldUseCache) {
          if (kDebugMode) {
            print('FeedProvider: Using cached Reddit posts for $_selectedPetType (${_cachedPetTypePosts[_selectedPetType]?.length ?? 0} posts)');
          }
          allPosts.addAll(_cachedPetTypePosts[_selectedPetType] ?? []);
        } else {
          // Fetch fresh Reddit posts
          try {
            if (kDebugMode) {
              print('FeedProvider: Starting ON-DEMAND Reddit aggregation for pet type: $_selectedPetType');
            }
            
            final apiService = ApiService();
            List<RedditPost> redditPosts = [];
          
            if (_selectedPetType == 'All') {
              // For "All" category - fetch 30 general pet posts (pet hub style)
              if (kDebugMode) {
                print('FeedProvider: Fetching 30 general pet posts for "All" category');
              }
              
              // Enhanced general pet subreddits for startup feed - more variety and viral content
              List<String> generalPetSubreddits = [
                'pets', 'petcare', 'petadvice', 'pethealth', 'petfood',
                'petbehavior', 'petnews', 'petcommunity', 'aww', 'eyebleach',
                'funny', 'memes', 'videos', 'gifs', 'pics', 'cute',
                'animals', 'animalvideos', 'petvideos', 'cuteanimals',
                'doggos', 'kittens', 'puppies', 'cats', 'dogs'
              ];
              
              // Shuffle subreddits for variety
              generalPetSubreddits.shuffle();
              
              // Fetch 30 posts from general pet subreddits
              int postsPerSubreddit = (30 / generalPetSubreddits.length).ceil();
              
              for (String subreddit in generalPetSubreddits.take(6)) { // Use first 6 subreddits for more variety
                try {
                  final posts = await apiService.fetchRedditPosts(
                    subreddit: subreddit,
                    limit: postsPerSubreddit + 5, // Fetch more posts for better variety
                  );
                  
                  // Assign general pet type
                  for (var post in posts) {
                    post.petType = 'All';
                  }
                  
                  redditPosts.addAll(posts);
                  
                  if (kDebugMode) {
                    print('FeedProvider: Fetched ${posts.length} posts from r/$subreddit for general pets');
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('FeedProvider: Error fetching from r/$subreddit: $e');
                  }
                }
              }
              
              // Shuffle for variety
              redditPosts.shuffle();
              
              if (kDebugMode) {
                print('FeedProvider: Total general pet posts for "All" category: ${redditPosts.length}');
              }
            } else {
              // For specific pet types - fetch only when that category is clicked
              if (kDebugMode) {
                print('FeedProvider: Fetching specific posts for $_selectedPetType category');
              }
              
              // Enhanced subreddit mapping - include viral content and memes
              Map<String, List<String>> petTypeToSubreddits = {
                'Dog': [
                  'dogtraining', 'dogcare', 'dogadvice', 'doghealth', 'puppy101',
                  'dogfood', 'dogbreeds', 'doggos', 'puppies', 'dogs',
                  'dogpictures', 'dogvideos', 'dogmemes'
                ],
                'Cat': [
                  'catcare', 'catbehavior', 'catadvice', 'cathealth', 'catfood',
                  'catbreeds', 'kittens', 'cats', 'catpictures', 'catvideos',
                  'catmemes', 'kitten', 'catswithjobs'
                ],
                'Hamster': [
                  'hamstercare', 'hamsteradvice', 'hamsterhealth', 'hamsterfood',
                  'hamsterbreeds', 'hamsters', 'hamsterpictures'
                ],
                'Bird': [
                  'birdcare', 'birdadvice', 'birdhealth', 'birdfood', 'parrots',
                  'birdbreeds', 'canaries', 'birds', 'parrot', 'birdpictures',
                  'parrots', 'birdvideos'
                ],
                'Fish': [
                  'aquariums', 'fishcare', 'fishadvice', 'fishhealth', 'fishfood',
                  'bettafish', 'goldfish', 'tropicalfish', 'fish', 'aquarium',
                  'fishpictures', 'betta'
                ],
                'Turtle': [
                  'turtlecare', 'turtleadvice', 'turtlehealth', 'turtlefood',
                  'turtlebreeds', 'reptiles', 'turtles', 'turtlepictures'
                ],
                'Rabbit': [
                  'rabbitcare', 'rabbitadvice', 'rabbithealth', 'rabbitfood',
                  'rabbitbreeds', 'bunnies', 'rabbits', 'rabbitpictures',
                  'bunny', 'rabbitvideos'
                ],
                'Guinea Pig': [
                  'guineapigcare', 'guineapigadvice', 'guineapighealth', 'guineapigfood',
                  'guineapigs', 'guineapigpictures'
                ],
                'Parrot': [
                  'parrotcare', 'parrotadvice', 'parrothealth', 'parrotfood',
                  'parrotbreeds', 'birds', 'parrots', 'parrotpictures',
                  'parrotvideos'
                ],
                'Snake': [
                  'snakecare', 'snakeadvice', 'snakehealth', 'snakefood',
                  'snakebreeds', 'reptiles', 'snakes', 'snakepictures',
                  'snakevideos'
                ],
                'Lizard': [
                  'lizardcare', 'lizardadvice', 'lizardhealth', 'lizardfood',
                  'lizardbreeds', 'reptiles', 'lizards', 'lizardpictures',
                  'beardeddragons', 'geckos'
                ],
                'Hedgehog': [
                  'hedgehogcare', 'hedgehogadvice', 'hedgehoghealth', 'hedgehogfood',
                  'hedgehogs', 'hedgehogpictures'
                ],
                'Ferret': [
                  'ferretcare', 'ferretadvice', 'ferrethealth', 'ferretfood',
                  'ferrets', 'ferretpictures', 'ferretvideos'
                ],
                'Chinchilla': [
                  'chinchillacare', 'chinchillaadvice', 'chinchillahealth', 'chinchillafood',
                  'chinchillas', 'chinchillapictures'
                ],
                'Frog': [
                  'frogcare', 'frogadvice', 'froghealth', 'frogfood', 'amphibians',
                  'frogs', 'frogpictures', 'frogvideos'
                ],
                'Tarantula': [
                  'tarantulacare', 'tarantulaadvice', 'tarantulahealth', 'tarantulafood',
                  'spiders', 'tarantulas', 'spiderpictures'
                ],
                'Axolotl': [
                  'axolotlcare', 'axolotladvice', 'axolotlhealth', 'axolotlfood',
                  'axolotls', 'axolotlpictures'
                ],
                'Mouse': [
                  'mousecare', 'mouseadvice', 'mousehealth', 'mousefood',
                  'mice', 'mousepictures'
                ],
                'Goat': [
                  'goatcare', 'goatadvice', 'goathealth', 'goatfood',
                  'goats', 'goatpictures', 'goatvideos'
                ],
              };
              
              List<String> subreddits = petTypeToSubreddits[_selectedPetType] ?? ['pets'];
              
              if (kDebugMode) {
                print('FeedProvider: Fetching from ${subreddits.length} subreddits: $subreddits');
              }
              
              // Fetch 25 posts from each subreddit for specific pet types
              for (String subreddit in subreddits) {
                try {
                  final posts = await apiService.fetchRedditPosts(
                    subreddit: subreddit,
                    limit: 30, // Increased from 25 for more variety
                  );
                  
                  // Assign the specific pet type
                  for (var post in posts) {
                    post.petType = _selectedPetType;
                  }
                  
                  redditPosts.addAll(posts);
                  
                  if (kDebugMode) {
                    print('FeedProvider: Fetched ${posts.length} posts from r/$subreddit');
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('FeedProvider: Error fetching from r/$subreddit: $e');
                  }
                }
              }
            }
            
            // Add fetched Reddit posts to all posts
            allPosts.addAll(redditPosts);
            _cachedPetTypePosts[_selectedPetType] = redditPosts.cast<Post>(); // Convert RedditPost to Post
            _lastPetTypeFetch[_selectedPetType] = DateTime.now(); // Update last fetch time
            
            if (kDebugMode) {
              print('FeedProvider: Total Reddit posts fetched: ${redditPosts.length}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('FeedProvider: Error fetching Reddit posts: $e');
            }
            // If Reddit API fails, still show community posts
            if (kDebugMode) {
              print('FeedProvider: Continuing with community posts only');
            }
          }
        }
      }

      // Shuffle posts for better variety (especially for "All" category)
      if (_selectedPetType == 'All') {
        allPosts.shuffle();
        if (kDebugMode) {
          print('FeedProvider: Shuffled posts for "All" category');
        }
      }

      // Sort all posts by creation date (newest first)
      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _posts = allPosts;
      notifyListeners();
    } finally {
      _isFetching = false;
      _isLoading = false; // Add this line to fix infinite loading
      notifyListeners(); // Notify again to update loading state
    }
  }

  Future<void> addPost(Post post) async {
    try {
      await SupabaseService.createPost(post.toJson());
      // Refresh posts after adding new one
      await _loadPosts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error adding post: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePost(String id, Post post) async {
    try {
      await SupabaseService.updatePost(id, post.toJson());
      // Refresh posts after updating
      await _loadPosts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error updating post: $e');
      }
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await SupabaseService.deletePost(id);
      // Refresh posts after deleting
      await _loadPosts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error deleting post: $e');
      }
      rethrow;
    }
  }

  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await SupabaseService.getPosts();
      _posts = posts.map((p) => Post.fromJson(p)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('FeedProvider: Error loading posts: $e');
      }
      rethrow;
    }
  }

  bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
    return uuidRegex.hasMatch(uuid);
  }

  // Check if a Reddit post is saved by consulting AppStateProvider
  bool isRedditPostSaved(BuildContext context, String redditUrl) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return appState.isRedditPostSaved(redditUrl);
  }
  
  // Update Reddit posts with saved state from AppStateProvider
  void updateRedditPostsSavedState(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    for (int i = 0; i < _posts.length; i++) {
      final post = _posts[i];
      if (post.postType == 'reddit' && post.redditUrl != null) {
        final isSaved = appState.isRedditPostSaved(post.redditUrl!);
        if (post.isSaved != isSaved) {
          _posts[i] = post.copyWith(isSaved: isSaved);
        }
      }
    }
    
    // Also update cached Reddit posts
    for (int i = 0; i < _cachedRedditPosts.length; i++) {
      final post = _cachedRedditPosts[i];
      if (post.postType == 'reddit' && post.redditUrl != null) {
        final isSaved = appState.isRedditPostSaved(post.redditUrl!);
        if (post.isSaved != isSaved) {
          _cachedRedditPosts[i] = post.copyWith(isSaved: isSaved);
        }
      }
    }
    
    notifyListeners();
  }
}
