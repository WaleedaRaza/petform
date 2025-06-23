import '../models/shopping_item.dart';
import 'chewy_service.dart';

class ShoppingService {
  // Real shopping suggestions with images and data
  static final Map<String, List<ShoppingItem>> _petShoppingSuggestions = {
    'dog': [
      ShoppingItem(
        id: 'dog_food_premium',
        name: 'Royal Canin Adult Dog Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 34.99,
        description: 'Premium dry food formulated for adult dogs with balanced nutrition',
        brand: 'Royal Canin',
        store: 'PetSmart',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['food', 'premium', 'adult', 'dry'],
      ),
      ShoppingItem(
        id: 'dog_toy_interactive',
        name: 'Kong Classic Dog Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 12.99,
        description: 'Durable rubber toy perfect for chewing and treat stuffing',
        brand: 'Kong',
        store: 'Amazon',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=300&fit=crop',
        tags: ['toys', 'chew', 'interactive', 'durable'],
      ),
      ShoppingItem(
        id: 'dog_collar_leather',
        name: 'Leather Dog Collar',
        category: 'Accessories',
        priority: 'High',
        estimatedCost: 24.99,
        description: 'Comfortable leather collar with brass buckle',
        brand: 'Ruffwear',
        store: 'Petco',
        imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=300&fit=crop',
        tags: ['collar', 'leather', 'comfortable', 'durable'],
      ),
      ShoppingItem(
        id: 'dog_bed_orthopedic',
        name: 'Orthopedic Dog Bed',
        category: 'Beds',
        priority: 'Medium',
        estimatedCost: 49.99,
        description: 'Memory foam bed for joint support and comfort',
        brand: 'Big Barker',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&h=300&fit=crop',
        tags: ['bed', 'orthopedic', 'memory-foam', 'comfort'],
      ),
      ShoppingItem(
        id: 'dog_shampoo',
        name: 'Oatmeal Dog Shampoo',
        category: 'Grooming',
        priority: 'Low',
        estimatedCost: 8.99,
        description: 'Gentle oatmeal shampoo for sensitive skin',
        brand: 'Earthbath',
        store: 'PetSmart',
        imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop',
        tags: ['grooming', 'shampoo', 'sensitive-skin', 'oatmeal'],
      ),
      ShoppingItem(
        id: 'dog_treats_training',
        name: 'Training Treats',
        category: 'Treats',
        priority: 'Medium',
        estimatedCost: 6.99,
        description: 'Small, soft treats perfect for training sessions',
        brand: 'Zuke\'s',
        store: 'Amazon',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['treats', 'training', 'soft', 'small'],
      ),
    ],
    'cat': [
      ShoppingItem(
        id: 'cat_food_premium',
        name: 'Purina Pro Plan Cat Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 28.99,
        description: 'High-protein dry food for adult cats',
        brand: 'Purina Pro Plan',
        store: 'PetSmart',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['food', 'premium', 'adult', 'high-protein'],
      ),
      ShoppingItem(
        id: 'cat_litter_clumping',
        name: 'Clumping Cat Litter',
        category: 'Hygiene',
        priority: 'High',
        estimatedCost: 19.99,
        description: 'Scented clumping litter for easy cleanup',
        brand: 'Tidy Cats',
        store: 'Petco',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['litter', 'clumping', 'scented', 'cleanup'],
      ),
      ShoppingItem(
        id: 'cat_scratcher',
        name: 'Cardboard Cat Scratcher',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 14.99,
        description: 'Replaceable cardboard scratcher with catnip',
        brand: 'SmartyKat',
        store: 'Amazon',
        imageUrl: 'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400&h=300&fit=crop',
        tags: ['scratcher', 'cardboard', 'catnip', 'replaceable'],
      ),
      ShoppingItem(
        id: 'cat_bed_cozy',
        name: 'Cozy Cat Bed',
        category: 'Beds',
        priority: 'Medium',
        estimatedCost: 29.99,
        description: 'Soft, plush bed with raised sides',
        brand: 'K&H Pet Products',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['bed', 'plush', 'cozy', 'raised-sides'],
      ),
      ShoppingItem(
        id: 'cat_treats_salmon',
        name: 'Salmon Cat Treats',
        category: 'Treats',
        priority: 'Low',
        estimatedCost: 4.99,
        description: 'Grain-free salmon treats for cats',
        brand: 'Temptations',
        store: 'PetSmart',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['treats', 'salmon', 'grain-free', 'natural'],
      ),
    ],
    'bird': [
      ShoppingItem(
        id: 'bird_seed_mix',
        name: 'Premium Bird Seed Mix',
        category: 'Food',
        priority: 'High',
        estimatedCost: 12.99,
        description: 'Nutritious seed mix for parakeets and small birds',
        brand: 'Kaytee',
        store: 'PetSmart',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['food', 'seeds', 'premium', 'small-birds'],
      ),
      ShoppingItem(
        id: 'bird_cage_large',
        name: 'Large Bird Cage',
        category: 'Housing',
        priority: 'High',
        estimatedCost: 89.99,
        description: 'Spacious cage with multiple perches and toys',
        brand: 'Prevue Pet Products',
        store: 'Amazon',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['cage', 'large', 'spacious', 'perches'],
      ),
    ],
    'fish': [
      ShoppingItem(
        id: 'fish_food_flakes',
        name: 'Tropical Fish Flakes',
        category: 'Food',
        priority: 'High',
        estimatedCost: 8.99,
        description: 'Complete nutrition for tropical fish',
        brand: 'Tetra',
        store: 'Petco',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['food', 'flakes', 'tropical', 'complete'],
      ),
      ShoppingItem(
        id: 'fish_tank_filter',
        name: 'Aquarium Filter',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 24.99,
        description: 'Power filter for clean, healthy water',
        brand: 'Marineland',
        store: 'PetSmart',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['filter', 'water', 'clean', 'healthy'],
      ),
    ],
  };

  // Get shopping suggestions for a specific pet type (now includes Chewy products)
  static List<ShoppingItem> getSuggestionsForPet(String petType) {
    List<ShoppingItem> suggestions = [];
    
    // Add regular suggestions
    suggestions.addAll(_petShoppingSuggestions[petType.toLowerCase()] ?? []);
    
    // Add Chewy products
    suggestions.addAll(ChewyService.getProductsForPet(petType));
    
    return suggestions;
  }

  // Get all suggestions (now includes Chewy products)
  static List<ShoppingItem> getAllSuggestions() {
    List<ShoppingItem> allSuggestions = [];
    
    // Add regular suggestions
    _petShoppingSuggestions.values.forEach((suggestions) {
      allSuggestions.addAll(suggestions);
    });
    
    // Add Chewy products
    allSuggestions.addAll(ChewyService.getAllProducts());
    
    return allSuggestions;
  }

  // Get suggestions by category (now includes Chewy products)
  static List<ShoppingItem> getSuggestionsByCategory(String category) {
    List<ShoppingItem> categorySuggestions = [];
    
    // Add regular suggestions
    _petShoppingSuggestions.values.forEach((suggestions) {
      categorySuggestions.addAll(
        suggestions.where((item) => item.category.toLowerCase() == category.toLowerCase())
      );
    });
    
    // Add Chewy products
    categorySuggestions.addAll(ChewyService.getProductsByCategory(category));
    
    return categorySuggestions;
  }

  // Get suggestions by priority (now includes Chewy products)
  static List<ShoppingItem> getSuggestionsByPriority(String priority) {
    List<ShoppingItem> prioritySuggestions = [];
    
    // Add regular suggestions
    _petShoppingSuggestions.values.forEach((suggestions) {
      prioritySuggestions.addAll(
        suggestions.where((item) => item.priority.toLowerCase() == priority.toLowerCase())
      );
    });
    
    // Add Chewy products
    ChewyService.getAllProducts().forEach((item) {
      if (item.priority.toLowerCase() == priority.toLowerCase()) {
        prioritySuggestions.add(item);
      }
    });
    
    return prioritySuggestions;
  }

  // Search suggestions (now includes Chewy products)
  static List<ShoppingItem> searchSuggestions(String query) {
    List<ShoppingItem> searchResults = [];
    final lowercaseQuery = query.toLowerCase();
    
    // Search regular suggestions
    _petShoppingSuggestions.values.forEach((suggestions) {
      searchResults.addAll(
        suggestions.where((item) =>
          item.name.toLowerCase().contains(lowercaseQuery) ||
          item.description?.toLowerCase().contains(lowercaseQuery) == true ||
          item.brand?.toLowerCase().contains(lowercaseQuery) == true ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
        )
      );
    });
    
    // Search Chewy products
    searchResults.addAll(ChewyService.searchProducts(query));
    
    return searchResults;
  }

  // Get popular items (items that appear in multiple pet types)
  static List<ShoppingItem> getPopularItems() {
    Map<String, int> itemCounts = {};
    
    _petShoppingSuggestions.values.forEach((suggestions) {
      suggestions.forEach((item) {
        itemCounts[item.name] = (itemCounts[item.name] ?? 0) + 1;
      });
    });
    
    List<ShoppingItem> popularItems = [];
    itemCounts.forEach((name, count) {
      if (count > 1) {
        // Find the first occurrence of this item
        for (final suggestions in _petShoppingSuggestions.values) {
          final item = suggestions.firstWhere((item) => item.name == name);
          popularItems.add(item);
          break;
        }
      }
    });
    
    return popularItems;
  }

  // Get budget-friendly suggestions (under $20)
  static List<ShoppingItem> getBudgetSuggestions() {
    List<ShoppingItem> budgetItems = [];
    
    // Add regular suggestions
    _petShoppingSuggestions.values.forEach((suggestions) {
      budgetItems.addAll(
        suggestions.where((item) => item.estimatedCost <= 20.0)
      );
    });
    
    // Add Chewy products
    budgetItems.addAll(ChewyService.getProductsByPriceRange(0.0, 20.0));
    
    return budgetItems;
  }

  // Get premium suggestions (over $40)
  static List<ShoppingItem> getPremiumSuggestions() {
    List<ShoppingItem> premiumItems = [];
    
    // Add regular suggestions
    _petShoppingSuggestions.values.forEach((suggestions) {
      premiumItems.addAll(
        suggestions.where((item) => item.estimatedCost >= 40.0)
      );
    });
    
    // Add Chewy products
    premiumItems.addAll(ChewyService.getProductsByPriceRange(40.0, double.infinity));
    
    return premiumItems;
  }

  // NEW: Get Chewy-specific suggestions
  static List<ShoppingItem> getChewySuggestions() {
    return ChewyService.getAllProducts();
  }

  // NEW: Get top-rated products from Chewy
  static List<ShoppingItem> getTopRatedSuggestions() {
    return ChewyService.getTopRatedProducts();
  }

  // NEW: Get best-selling products from Chewy
  static List<ShoppingItem> getBestSellingSuggestions() {
    return ChewyService.getBestSellingProducts();
  }

  // NEW: Get products with free shipping
  static List<ShoppingItem> getFreeShippingSuggestions() {
    return ChewyService.getFreeShippingProducts();
  }

  // NEW: Get auto-ship eligible products
  static List<ShoppingItem> getAutoShipSuggestions() {
    return ChewyService.getAutoShipProducts();
  }

  // NEW: Get products by brand
  static List<ShoppingItem> getSuggestionsByBrand(String brand) {
    return ChewyService.getProductsByBrand(brand);
  }

  // NEW: Get products by price range
  static List<ShoppingItem> getSuggestionsByPriceRange(double minPrice, double maxPrice) {
    return ChewyService.getProductsByPriceRange(minPrice, maxPrice);
  }

  // NEW: Get product details from Chewy
  static Future<Map<String, dynamic>> getProductDetails(String productId) async {
    return await ChewyService.getProductDetails(productId);
  }

  // NEW: Add item to Chewy cart
  static Future<bool> addToChewyCart(String productId, int quantity) async {
    return await ChewyService.addToCart(productId, quantity);
  }

  // NEW: Setup auto-ship with Chewy
  static Future<bool> setupChewyAutoShip(String productId, int quantity, String frequency) async {
    return await ChewyService.setupAutoShip(productId, quantity, frequency);
  }

  // NEW: Get Chewy shipping information
  static Map<String, dynamic> getChewyShippingInfo() {
    return ChewyService.getShippingInfo();
  }
} 