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
              // For "All" category - fetch popular pet posts from top subreddits
              if (kDebugMode) {
                print('FeedProvider: Fetching popular pet posts for "All" category');
              }
              
              // Prioritize most common pets: Dogs, Cats, Fish, then others
              List<String> topPetSubreddits = [
                'dogtraining', 'catcare', 'aquariums', // Most common pets first
                'pets', 'hamstercare', 'reptiles', 'rabbitcare', 'parrots' // Others
              ];
              
              // Fetch from top subreddits with priority weighting
              for (int i = 0; i < topPetSubreddits.length; i++) {
                String subreddit = topPetSubreddits[i];
                try {
                  // Give more posts to dogs/cats/fish (most common pets)
                  int limit = (i < 3) ? 20 : 10; // More posts for top 3
                  
                  final posts = await apiService.fetchRedditPosts(
                    subreddit: subreddit,
                    limit: limit,
                  );
                  
                  // Intelligently assign pet type based on content
                  for (var post in posts) {
                    post.petType = _detectPetTypeFromContent(post.title, post.content);
                  }
                  
                  redditPosts.addAll(posts);
                  
                  if (kDebugMode) {
                    print('FeedProvider: Fetched ${posts.length} posts from r/$subreddit (priority ${i + 1})');
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('FeedProvider: Error fetching from r/$subreddit: $e');
                  }
                }
              }
              
              // Shuffle posts to mix different pet types
              redditPosts.shuffle();
              
              if (kDebugMode) {
                print('FeedProvider: Total posts for "All" category: ${redditPosts.length}');
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
              
              // Fetch posts from each subreddit for specific pet types
              for (String subreddit in subreddits) {
                try {
                  final posts = await apiService.fetchRedditPosts(
                    subreddit: subreddit,
                    limit: 20, // Reduced to avoid duplicates
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

      // FILTER INAPPROPRIATE CONTENT
      allPosts = _filterInappropriateContent(allPosts);
      
      // PRIORITIZE DOGS, CATS, FISH FOR FIRST 10 POSTS, THEN MIX OTHERS
      if (_selectedPetType == 'All') {
        // Separate posts by priority
        List<Post> priorityPosts = []; // Dogs, Cats, Fish
        List<Post> otherPosts = []; // Everything else
        
        for (Post post in allPosts) {
          String? petType = post.petType?.toLowerCase();
          if (petType == 'dog' || petType == 'cat' || petType == 'fish') {
            priorityPosts.add(post);
          } else {
            otherPosts.add(post);
          }
        }
        
        // Sort both lists by date (newest first)
        priorityPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        otherPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        // Take first 10 from priority posts, then 20 from others
        List<Post> finalPosts = [];
        finalPosts.addAll(priorityPosts.take(10));
        finalPosts.addAll(otherPosts.take(20));
        
        allPosts = finalPosts;
        
        if (kDebugMode) {
          print('FeedProvider: Main feed - ${priorityPosts.length} priority posts, ${otherPosts.length} other posts');
          print('FeedProvider: Final feed - ${allPosts.length} posts (10 priority + 20 others)');
        }
      } else {
        // For specific pet types, keep as is
        if (kDebugMode) {
          print('FeedProvider: Specific pet type feed with ${allPosts.length} posts');
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

  // Filter out inappropriate content - simplified for main feed
  List<Post> _filterInappropriateContent(List<Post> posts) {
    // Only filter explicit sexual/racist content, allow curse words
    final inappropriateKeywords = [
      'testicles', 'testicle', 'balls', 'ball', 'penis', 'dick', 'cock',
      'vagina', 'pussy', 'sex', 'sexual', 'mating', 'breeding',
      'nude', 'naked', 'nudity', 'porn', 'pornographic', 'explicit',
      'nsfw', 'sexual content', 'racist', 'racism', 'hate speech'
    ];

    return posts.where((post) {
      final title = post.title.toLowerCase();
      final content = post.content.toLowerCase();
      
      // Check for inappropriate keywords
      for (final keyword in inappropriateKeywords) {
        if (title.contains(keyword) || content.contains(keyword)) {
          if (kDebugMode) {
            print('FeedProvider: Filtered out post with inappropriate keyword: $keyword');
          }
          return false;
        }
      }
      
      // Only filter obvious spam (very repetitive content)
      final words = (title + ' ' + content).toLowerCase().split(' ');
      final wordCount = <String, int>{};
      for (final word in words) {
        if (word.length > 5) { // Only count longer words
          wordCount[word] = (wordCount[word] ?? 0) + 1;
        }
      }
      
      // If any word appears more than 15 times, it might be spam
      for (final entry in wordCount.entries) {
        if (entry.value > 15) {
          if (kDebugMode) {
            print('FeedProvider: Filtered out post with repetitive word: ${entry.key}');
          }
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  // Create balanced assortment from different pet types and topics
  List<Post> _createBalancedAssortment(List<Post> posts) {
    if (posts.isEmpty) return posts;

    // Group posts by pet type
    final postsByPetType = <String, List<Post>>{};
    final postsByTopic = <String, List<Post>>{};
    
    for (final post in posts) {
      // Group by pet type
      final petType = post.petType ?? 'Unknown';
      postsByPetType.putIfAbsent(petType, () => []).add(post);
      
      // Group by topic (extract main topic from title/content)
      final topic = _extractMainTopic(post.title, post.content);
      postsByTopic.putIfAbsent(topic, () => []).add(post);
    }

    if (kDebugMode) {
      print('FeedProvider: Posts by pet type: ${postsByPetType.keys.toList()}');
      for (final entry in postsByPetType.entries) {
        print('FeedProvider: ${entry.key}: ${entry.value.length} posts');
      }
    }

    final balancedPosts = <Post>[];
    final maxPostsPerPetType = 3; // Increased back to 3 for more posts
    final maxPostsPerTopic = 2; // Increased back to 2 for more posts
    final targetTotalPosts = 25; // Increased to 25 for more posts
    
    // STRICT PET TYPE BALANCING - ensure variety
    final petTypes = postsByPetType.keys.toList();
    petTypes.sort(); // Sort for consistent ordering
    
    // Take up to 2 posts from each pet type first (if available)
    for (final petType in petTypes) {
      final petPosts = postsByPetType[petType]!;
      petPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
      
      if (petPosts.isNotEmpty) {
        // Take up to 2 posts from each pet type
        final postsToTake = petPosts.take(2).toList();
        balancedPosts.addAll(postsToTake);
        if (kDebugMode) {
          print('FeedProvider: Added ${postsToTake.length} posts from $petType');
        }
      }
    }
    
    // Then add additional posts to fill up to target, but maintain balance
    final remainingSlots = targetTotalPosts - balancedPosts.length;
    if (remainingSlots > 0) {
      final additionalPosts = <Post>[];
      
      // Add more posts from different pet types, but limit to maxPostsPerPetType
      for (final petType in petTypes) {
        final petPosts = postsByPetType[petType]!;
        if (petPosts.length > 1) {
          // Take additional posts (skip the first one we already took)
          final additionalFromThisType = petPosts.skip(1).take(maxPostsPerPetType - 1);
          additionalPosts.addAll(additionalFromThisType);
        }
      }
      
      // Shuffle additional posts and take what we need
      additionalPosts.shuffle();
      balancedPosts.addAll(additionalPosts.take(remainingSlots));
    }
    
    // Final shuffle for variety
    balancedPosts.shuffle();
    
    if (kDebugMode) {
      print('FeedProvider: Final balanced assortment: ${balancedPosts.length} posts');
      final finalPetTypes = <String, int>{};
      for (final post in balancedPosts) {
        final petType = post.petType ?? 'Unknown';
        finalPetTypes[petType] = (finalPetTypes[petType] ?? 0) + 1;
      }
      for (final entry in finalPetTypes.entries) {
        print('FeedProvider: Final mix - ${entry.key}: ${entry.value} posts');
      }
    }
    
    return balancedPosts;
  }

  // Extract main topic from post title and content
  String _extractMainTopic(String title, String content) {
    final text = (title + ' ' + content).toLowerCase();
    
    // Define topic keywords
    final topicKeywords = {
      'health': ['vet', 'veterinary', 'health', 'medical', 'sick', 'illness', 'disease', 'symptom', 'treatment'],
      'training': ['training', 'train', 'behavior', 'obedience', 'command', 'trick', 'socialization'],
      'nutrition': ['food', 'diet', 'feeding', 'nutrition', 'meal', 'treat', 'feeding'],
      'care': ['care', 'grooming', 'bathing', 'cleaning', 'maintenance', 'hygiene'],
      'exercise': ['exercise', 'walk', 'play', 'activity', 'workout', 'fitness'],
      'adoption': ['adopt', 'adoption', 'rescue', 'foster', 'shelter'],
      'equipment': ['toy', 'bed', 'crate', 'collar', 'leash', 'equipment', 'supplies'],
      'general': ['general', 'question', 'advice', 'help', 'support']
    };
    
    // Find the most relevant topic
    String bestTopic = 'general';
    int maxMatches = 0;
    
    for (final entry in topicKeywords.entries) {
      int matches = 0;
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          matches++;
        }
      }
      if (matches > maxMatches) {
        maxMatches = matches;
        bestTopic = entry.key;
      }
    }
    
    return bestTopic;
  }

  // Detect pet type from post content
  String _detectPetTypeFromContent(String title, String content) {
    final text = (title + ' ' + content).toLowerCase();
    
    // Define pet type keywords with more comprehensive terms
    final petTypeKeywords = {
      'Dog': ['dog', 'puppy', 'puppies', 'canine', 'hound', 'breed', 'leash', 'walk', 'bark', 'woof', 'beagle', 'dachshund', 'rescue', 'house train', 'training', 'obedience', 'dogtraining', 'puppy101', 'dogcare', 'dogadvice'],
      'Cat': ['cat', 'kitten', 'kittens', 'feline', 'meow', 'purr', 'litter', 'scratch', 'kitty', 'tabby', 'siamese', 'catcare', 'catbehavior', 'catadvice'],
      'Bird': ['bird', 'parrot', 'cockatiel', 'budgie', 'canary', 'finch', 'wing', 'feather', 'cage', 'avian', 'flying'],
              'Fish': ['fish', 'aquarium', 'tank', 'water', 'swim', 'guppy', 'betta', 'goldfish', 'tropical', 'aquatic', 'underwater', 'aquariums', 'fishcare', 'fishadvice'],
      'Rabbit': ['rabbit', 'bunny', 'bunnies', 'hare', 'hop', 'carrot', 'hutch', 'lagomorph'],
      'Hamster': ['hamster', 'gerbil', 'mouse', 'rodent', 'wheel', 'cage', 'small pet'],
      'Snake': ['snake', 'python', 'boa', 'reptile', 'scale', 'slither', 'terrarium', 'serpent'],
      'Lizard': ['lizard', 'gecko', 'bearded dragon', 'iguana', 'reptile', 'scale', 'reptilian'],
      'Turtle': ['turtle', 'tortoise', 'shell', 'aquatic', 'pond', 'chelonian'],
      'Guinea Pig': ['guinea pig', 'cavy', 'pig', 'rodent', 'guinea'],
      'Parrot': ['parrot', 'macaw', 'cockatoo', 'african grey', 'amazon', 'psittacine'],
      'Hedgehog': ['hedgehog', 'spike', 'quill', 'hedge'],
      'Ferret': ['ferret', 'weasel', 'playful', 'mustelid'],
      'Chinchilla': ['chinchilla', 'dust bath', 'soft', 'chinchilla'],
      'Frog': ['frog', 'toad', 'amphibian', 'pond', 'amphibian'],
      'Tarantula': ['tarantula', 'spider', 'arachnid', 'web', 'arachnid'],
      'Axolotl': ['axolotl', 'salamander', 'aquatic', 'amphibian'],
      'Mouse': ['mouse', 'mice', 'rodent', 'small', 'murine'],
      'Goat': ['goat', 'farm', 'hoof', 'mountain', 'caprine'],
    };
    
    // Find the most relevant pet type
    String bestPetType = 'All';
    int maxMatches = 0;
    
    for (final entry in petTypeKeywords.entries) {
      int matches = 0;
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          matches++;
        }
      }
      if (matches > maxMatches) {
        maxMatches = matches;
        bestPetType = entry.key;
      }
    }
    
    // Only return specific pet type if we have good confidence (at least 2 matches)
    if (maxMatches >= 2) {
      if (kDebugMode) {
        print('FeedProvider: Detected pet type "$bestPetType" with $maxMatches matches');
      }
      return bestPetType;
    } else {
      if (kDebugMode) {
        print('FeedProvider: Could not detect specific pet type, using "All"');
      }
      return 'All';
    }
  }
}
