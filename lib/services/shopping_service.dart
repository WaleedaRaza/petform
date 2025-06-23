import '../models/shopping_item.dart';
import 'chewy_service.dart';

class ShoppingService {
  // Comprehensive product database organized by pet type
  static final Map<String, List<ShoppingItem>> _productsByPetType = {
    'Dog': _getDogProducts(),
    'Cat': _getCatProducts(),
    'Turtle': _getTurtleProducts(),
    'Fish': _getFishProducts(),
    'Bird': _getBirdProducts(),
    'Hamster': _getHamsterProducts(),
    'Rabbit': _getRabbitProducts(),
    'Snake': _getSnakeProducts(),
    'Lizard': _getLizardProducts(),
    'Chicken': _getChickenProducts(),
    'Guinea Pig': _getGuineaPigProducts(),
    'Frog': _getFrogProducts(),
    'Tarantula': _getTarantulaProducts(),
    'Axolotl': _getAxolotlProducts(),
    'Mouse': _getMouseProducts(),
    'Goat': _getGoatProducts(),
    'Hedgehog': _getHedgehogProducts(),
  };

  // Get products for a specific pet type
  static List<ShoppingItem> getProductsForPet(String petType) {
    return _productsByPetType[petType] ?? [];
  }

  // Get all products
  static List<ShoppingItem> getAllProducts() {
    List<ShoppingItem> allProducts = [];
    _productsByPetType.values.forEach((products) {
      allProducts.addAll(products);
    });
    return allProducts;
  }

  // Get products by category
  static List<ShoppingItem> getProductsByCategory(String category) {
    List<ShoppingItem> categoryProducts = [];
    _productsByPetType.values.forEach((products) {
      categoryProducts.addAll(
        products.where((item) => item.category.toLowerCase() == category.toLowerCase())
      );
    });
    return categoryProducts;
  }

  // Search products
  static List<ShoppingItem> searchProducts(String query) {
    List<ShoppingItem> searchResults = [];
    final lowercaseQuery = query.toLowerCase();
    
    _productsByPetType.values.forEach((products) {
      searchResults.addAll(
        products.where((item) =>
          item.name.toLowerCase().contains(lowercaseQuery) ||
          item.description?.toLowerCase().contains(lowercaseQuery) == true ||
          item.brand?.toLowerCase().contains(lowercaseQuery) == true ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
        )
      );
    });
    
    return searchResults;
  }

  // Get products by price range
  static List<ShoppingItem> getProductsByPriceRange(double minPrice, double maxPrice) {
    List<ShoppingItem> priceRangeProducts = [];
    _productsByPetType.values.forEach((products) {
      priceRangeProducts.addAll(
        products.where((item) => 
          item.estimatedCost >= minPrice && item.estimatedCost <= maxPrice
        )
      );
    });
    return priceRangeProducts;
  }

  // Get products with free shipping
  static List<ShoppingItem> getFreeShippingProducts() {
    List<ShoppingItem> freeShippingProducts = [];
    _productsByPetType.values.forEach((products) {
      freeShippingProducts.addAll(
        products.where((item) => item.freeShipping == true)
      );
    });
    return freeShippingProducts;
  }

  // Get products with auto-ship available
  static List<ShoppingItem> getAutoShipProducts() {
    List<ShoppingItem> autoShipProducts = [];
    _productsByPetType.values.forEach((products) {
      autoShipProducts.addAll(
        products.where((item) => item.autoShip == true)
      );
    });
    return autoShipProducts;
  }

  // Get top-rated products (4.5+ stars)
  static List<ShoppingItem> getTopRatedProducts() {
    List<ShoppingItem> topRatedProducts = [];
    _productsByPetType.values.forEach((products) {
      topRatedProducts.addAll(
        products.where((item) => item.rating != null && item.rating! >= 4.5)
      );
    });
    return topRatedProducts;
  }

  // Get best-selling products (1000+ reviews)
  static List<ShoppingItem> getBestSellingProducts() {
    List<ShoppingItem> bestSellingProducts = [];
    _productsByPetType.values.forEach((products) {
      bestSellingProducts.addAll(
        products.where((item) => item.reviewCount != null && item.reviewCount! >= 1000)
      );
    });
    return bestSellingProducts;
  }

  // Get budget-friendly suggestions
  static List<ShoppingItem> getBudgetSuggestions() {
    return getProductsByPriceRange(0, 25);
  }

  // Get premium suggestions
  static List<ShoppingItem> getPremiumSuggestions() {
    return getProductsByPriceRange(50, double.infinity);
  }

  // Get popular items
  static List<ShoppingItem> getPopularItems() {
    return getBestSellingProducts();
  }

  // Get suggestions for a specific pet
  static List<ShoppingItem> getSuggestionsForPet(String petType) {
    return getProductsForPet(petType);
  }

  // Get suggestions by category
  static List<ShoppingItem> getSuggestionsByCategory(String category) {
    return getProductsByCategory(category);
  }

  // Get suggestions by priority
  static List<ShoppingItem> getSuggestionsByPriority(String priority) {
    List<ShoppingItem> priorityProducts = [];
    _productsByPetType.values.forEach((products) {
      priorityProducts.addAll(
        products.where((item) => item.priority.toLowerCase() == priority.toLowerCase())
      );
    });
    return priorityProducts;
  }

  // Search suggestions
  static List<ShoppingItem> searchSuggestions(String query) {
    return searchProducts(query);
  }

  // Get Chewy suggestions (for compatibility)
  static List<ShoppingItem> getChewySuggestions() {
    return getAllProducts().where((item) => item.store == 'Chewy').toList();
  }

  // Product data for each pet type
  static List<ShoppingItem> _getDogProducts() {
    return [
      // Dog Food
      ShoppingItem(
        id: 'dog_food_royal_canin',
        name: 'Royal Canin Adult Dog Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 34.99,
        description: 'Premium dry food formulated for adult dogs with balanced nutrition',
        brand: 'Royal Canin',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['food', 'premium', 'adult', 'dry'],
        chewyUrl: 'https://www.chewy.com/royal-canin-adult-dog-food/dp/123456',
        rating: 4.8,
        reviewCount: 1247,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'dog_food_purina_pro',
        name: 'Purina Pro Plan Adult Dog Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 29.99,
        description: 'High-protein formula for active adult dogs',
        brand: 'Purina Pro Plan',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['food', 'high-protein', 'active', 'adult'],
        chewyUrl: 'https://www.chewy.com/purina-pro-plan-adult/dp/123457',
        rating: 4.6,
        reviewCount: 2156,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'dog_food_blue_buffalo',
        name: 'Blue Buffalo Life Protection',
        category: 'Food',
        priority: 'High',
        estimatedCost: 39.99,
        description: 'Natural ingredients with real chicken as first ingredient',
        brand: 'Blue Buffalo',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['food', 'natural', 'chicken', 'grain-free'],
        chewyUrl: 'https://www.chewy.com/blue-buffalo-life-protection/dp/123458',
        rating: 4.7,
        reviewCount: 1893,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Dog Toys
      ShoppingItem(
        id: 'dog_toy_kong_classic',
        name: 'Kong Classic Dog Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 12.99,
        description: 'Durable rubber toy perfect for chewing and treat stuffing',
        brand: 'Kong',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=300&fit=crop',
        tags: ['toys', 'chew', 'interactive', 'durable'],
        chewyUrl: 'https://www.chewy.com/kong-classic-dog-toy/dp/123459',
        rating: 4.7,
        reviewCount: 2341,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'dog_toy_tennis_balls',
        name: 'Tennis Ball Set (6-pack)',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 8.99,
        description: 'Classic tennis balls for fetch and play',
        brand: 'Chuckit!',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=300&fit=crop',
        tags: ['toys', 'fetch', 'tennis-balls', 'outdoor'],
        chewyUrl: 'https://www.chewy.com/chuckit-tennis-balls/dp/123460',
        rating: 4.5,
        reviewCount: 1567,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'dog_toy_rope_tug',
        name: 'Cotton Rope Tug Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 9.99,
        description: 'Natural cotton rope for interactive tug-of-war play',
        brand: 'Mammoth',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=300&fit=crop',
        tags: ['toys', 'tug', 'rope', 'interactive'],
        chewyUrl: 'https://www.chewy.com/mammoth-rope-tug/dp/123461',
        rating: 4.4,
        reviewCount: 892,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Dog Beds
      ShoppingItem(
        id: 'dog_bed_orthopedic',
        name: 'Orthopedic Memory Foam Dog Bed',
        category: 'Beds',
        priority: 'High',
        estimatedCost: 49.99,
        description: 'Memory foam bed for joint support and comfort',
        brand: 'Big Barker',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&h=300&fit=crop',
        tags: ['bed', 'orthopedic', 'memory-foam', 'comfort'],
        chewyUrl: 'https://www.chewy.com/orthopedic-memory-foam-bed/dp/123462',
        rating: 4.9,
        reviewCount: 892,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'dog_bed_bolster',
        name: 'Bolster Dog Bed with Removable Cover',
        category: 'Beds',
        priority: 'Medium',
        estimatedCost: 34.99,
        description: 'Comfortable bolster bed with washable cover',
        brand: 'Frisco',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&h=300&fit=crop',
        tags: ['bed', 'bolster', 'washable', 'comfortable'],
        chewyUrl: 'https://www.chewy.com/frisco-bolster-bed/dp/123463',
        rating: 4.6,
        reviewCount: 567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Dog Treats
      ShoppingItem(
        id: 'dog_treats_training',
        name: 'Training Treats - Soft & Chewy',
        category: 'Food',
        priority: 'Medium',
        estimatedCost: 6.99,
        description: 'Small, soft treats perfect for training sessions',
        brand: 'Zuke\'s',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['treats', 'training', 'soft', 'small'],
        chewyUrl: 'https://www.chewy.com/zukes-training-treats/dp/123464',
        rating: 4.7,
        reviewCount: 1234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'dog_treats_dental',
        name: 'Dental Chews for Fresh Breath',
        category: 'Hygiene',
        priority: 'Medium',
        estimatedCost: 14.99,
        description: 'Dental chews that clean teeth and freshen breath',
        brand: 'Greenies',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['treats', 'dental', 'breath', 'chews'],
        chewyUrl: 'https://www.chewy.com/greenies-dental-chews/dp/123465',
        rating: 4.8,
        reviewCount: 3456,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Dog Collars & Leashes
      ShoppingItem(
        id: 'dog_collar_nylon',
        name: 'Nylon Dog Collar with ID Tag',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 12.99,
        description: 'Adjustable nylon collar with safety buckle',
        brand: 'Frisco',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['collar', 'nylon', 'adjustable', 'safety'],
        chewyUrl: 'https://www.chewy.com/frisco-nylon-collar/dp/123466',
        rating: 4.5,
        reviewCount: 789,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'dog_leash_retractable',
        name: 'Retractable Dog Leash 16ft',
        category: 'Equipment',
        priority: 'Medium',
        estimatedCost: 19.99,
        description: 'Retractable leash with comfortable grip handle',
        brand: 'Flexi',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['leash', 'retractable', '16ft', 'comfortable'],
        chewyUrl: 'https://www.chewy.com/flexi-retractable-leash/dp/123467',
        rating: 4.6,
        reviewCount: 1234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Dog Shampoo
      ShoppingItem(
        id: 'dog_shampoo_oatmeal',
        name: 'Oatmeal Dog Shampoo & Conditioner',
        category: 'Hygiene',
        priority: 'Medium',
        estimatedCost: 8.99,
        description: 'Gentle oatmeal formula for sensitive skin',
        brand: 'Earthbath',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['shampoo', 'oatmeal', 'sensitive', 'conditioner'],
        chewyUrl: 'https://www.chewy.com/earthbath-oatmeal-shampoo/dp/123468',
        rating: 4.7,
        reviewCount: 2341,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getCatProducts() {
    return [
      // Cat Food
      ShoppingItem(
        id: 'cat_food_royal_canin',
        name: 'Royal Canin Adult Cat Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 28.99,
        description: 'Premium dry food formulated for adult cats',
        brand: 'Royal Canin',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['food', 'premium', 'adult', 'dry'],
        chewyUrl: 'https://www.chewy.com/royal-canin-adult-cat-food/dp/123469',
        rating: 4.7,
        reviewCount: 1567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'cat_food_purina_fancy',
        name: 'Purina Fancy Feast Wet Cat Food',
        category: 'Food',
        priority: 'Medium',
        estimatedCost: 24.99,
        description: 'Gourmet wet food in gravy with real meat',
        brand: 'Purina Fancy Feast',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['food', 'wet', 'gourmet', 'gravy'],
        chewyUrl: 'https://www.chewy.com/purina-fancy-feast-wet/dp/123470',
        rating: 4.5,
        reviewCount: 2341,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'cat_food_blue_wilderness',
        name: 'Blue Wilderness High Protein',
        category: 'Food',
        priority: 'High',
        estimatedCost: 32.99,
        description: 'Grain-free high protein formula with real chicken',
        brand: 'Blue Buffalo',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['food', 'grain-free', 'high-protein', 'chicken'],
        chewyUrl: 'https://www.chewy.com/blue-wilderness-cat-food/dp/123471',
        rating: 4.8,
        reviewCount: 1892,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Cat Litter
      ShoppingItem(
        id: 'cat_litter_clumping',
        name: 'Clumping Cat Litter',
        category: 'Hygiene',
        priority: 'High',
        estimatedCost: 19.99,
        description: 'Scented clumping litter for easy cleanup',
        brand: 'Tidy Cats',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['litter', 'clumping', 'scented', 'cleanup'],
        chewyUrl: 'https://www.chewy.com/tidy-cats-clumping-litter/dp/123472',
        rating: 4.3,
        reviewCount: 2341,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'cat_litter_crystal',
        name: 'Crystal Cat Litter',
        category: 'Hygiene',
        priority: 'Medium',
        estimatedCost: 24.99,
        description: 'Silica gel crystals for superior odor control',
        brand: 'Fresh Step',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['litter', 'crystal', 'odor-control', 'silica'],
        chewyUrl: 'https://www.chewy.com/fresh-step-crystal-litter/dp/123473',
        rating: 4.6,
        reviewCount: 1234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Cat Toys
      ShoppingItem(
        id: 'cat_toy_feather_wand',
        name: 'Feather Wand Cat Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 7.99,
        description: 'Interactive feather wand for play and exercise',
        brand: 'SmartyKat',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['toys', 'feather', 'interactive', 'exercise'],
        chewyUrl: 'https://www.chewy.com/smartykat-feather-wand/dp/123474',
        rating: 4.7,
        reviewCount: 892,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'cat_toy_laser_pointer',
        name: 'Laser Pointer Cat Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 5.99,
        description: 'Red laser pointer for interactive play',
        brand: 'PetSafe',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['toys', 'laser', 'interactive', 'exercise'],
        chewyUrl: 'https://www.chewy.com/petsafe-laser-pointer/dp/123475',
        rating: 4.5,
        reviewCount: 567,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Cat Beds
      ShoppingItem(
        id: 'cat_bed_round',
        name: 'Round Cat Bed with Rim',
        category: 'Beds',
        priority: 'Medium',
        estimatedCost: 24.99,
        description: 'Soft round bed with raised rim for comfort',
        brand: 'Frisco',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['bed', 'round', 'soft', 'comfortable'],
        chewyUrl: 'https://www.chewy.com/frisco-round-cat-bed/dp/123476',
        rating: 4.6,
        reviewCount: 456,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Cat Treats
      ShoppingItem(
        id: 'cat_treats_tuna',
        name: 'Tuna Flavor Cat Treats',
        category: 'Food',
        priority: 'Medium',
        estimatedCost: 4.99,
        description: 'Soft treats with real tuna flavor',
        brand: 'Temptations',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['treats', 'tuna', 'soft', 'flavorful'],
        chewyUrl: 'https://www.chewy.com/temptations-tuna-treats/dp/123477',
        rating: 4.8,
        reviewCount: 3456,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Cat Scratching Posts
      ShoppingItem(
        id: 'cat_scratch_post',
        name: 'Cat Scratching Post',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 29.99,
        description: 'Sisal rope scratching post with platform',
        brand: 'Frisco',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['scratching', 'sisal', 'platform', 'exercise'],
        chewyUrl: 'https://www.chewy.com/frisco-scratching-post/dp/123478',
        rating: 4.4,
        reviewCount: 789,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getTurtleProducts() {
    return [
      // Turtle Food
      ShoppingItem(
        id: 'turtle_food_pellets',
        name: 'Turtle Pellets - Complete Nutrition',
        category: 'Food',
        priority: 'High',
        estimatedCost: 8.99,
        description: 'Complete nutrition pellets for aquatic turtles',
        brand: 'Zoo Med',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
        tags: ['food', 'pellets', 'aquatic', 'complete'],
        chewyUrl: 'https://www.chewy.com/zoo-med-turtle-pellets/dp/123481',
        rating: 4.5,
        reviewCount: 567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'turtle_food_sticks',
        name: 'Turtle Food Sticks',
        category: 'Food',
        priority: 'Medium',
        estimatedCost: 6.99,
        description: 'Floating food sticks for turtles',
        brand: 'Tetra',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
        tags: ['food', 'sticks', 'floating', 'turtles'],
        chewyUrl: 'https://www.chewy.com/tetra-turtle-sticks/dp/123482',
        rating: 4.3,
        reviewCount: 234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Water Conditioner
      ShoppingItem(
        id: 'turtle_water_conditioner',
        name: 'Turtle Water Conditioner & Dechlorinator',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 12.99,
        description: 'Removes chlorine and chloramines, adds beneficial electrolytes',
        brand: 'Zoo Med',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
        tags: ['water', 'conditioner', 'dechlorinator', 'electrolytes'],
        chewyUrl: 'https://www.chewy.com/zoo-med-turtle-water-conditioner/dp/123483',
        rating: 4.6,
        reviewCount: 234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Basking Lamp
      ShoppingItem(
        id: 'turtle_basking_lamp',
        name: 'Turtle Basking Lamp & UVB Bulb',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 24.99,
        description: 'Provides heat and UVB for proper turtle health',
        brand: 'Zoo Med',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
        tags: ['basking', 'lamp', 'uvb', 'heat'],
        chewyUrl: 'https://www.chewy.com/zoo-med-turtle-basking-lamp/dp/123484',
        rating: 4.7,
        reviewCount: 345,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Floating Dock
      ShoppingItem(
        id: 'turtle_floating_dock',
        name: 'Turtle Floating Basking Platform',
        category: 'Equipment',
        priority: 'Medium',
        estimatedCost: 15.99,
        description: 'Floating platform for turtles to bask and rest',
        brand: 'Penn-Plax',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
        tags: ['basking', 'platform', 'floating', 'rest'],
        chewyUrl: 'https://www.chewy.com/penn-plax-floating-dock/dp/123485',
        rating: 4.4,
        reviewCount: 178,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Turtle Tank Filter
      ShoppingItem(
        id: 'turtle_tank_filter',
        name: 'Aquatic Turtle Tank Filter',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 34.99,
        description: 'Powerful filter for turtle tanks',
        brand: 'Marineland',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
        tags: ['filter', 'tank', 'aquatic', 'powerful'],
        chewyUrl: 'https://www.chewy.com/marineland-turtle-filter/dp/123486',
        rating: 4.5,
        reviewCount: 123,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getFishProducts() {
    return [
      // Fish Food
      ShoppingItem(
        id: 'fish_food_flakes',
        name: 'Tropical Fish Flakes',
        category: 'Food',
        priority: 'High',
        estimatedCost: 8.99,
        description: 'Complete nutrition for tropical fish',
        brand: 'Tetra',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['food', 'flakes', 'tropical', 'complete'],
        chewyUrl: 'https://www.chewy.com/tetra-tropical-flakes/dp/123487',
        rating: 4.5,
        reviewCount: 1234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'fish_food_pellets',
        name: 'Goldfish Pellets',
        category: 'Food',
        priority: 'High',
        estimatedCost: 7.99,
        description: 'Sinking pellets for goldfish',
        brand: 'Hikari',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['food', 'pellets', 'goldfish', 'sinking'],
        chewyUrl: 'https://www.chewy.com/hikari-goldfish-pellets/dp/123488',
        rating: 4.6,
        reviewCount: 567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'fish_food_frozen',
        name: 'Frozen Bloodworms',
        category: 'Food',
        priority: 'Medium',
        estimatedCost: 12.99,
        description: 'Frozen bloodworms for carnivorous fish',
        brand: 'Hikari',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['food', 'frozen', 'bloodworms', 'carnivorous'],
        chewyUrl: 'https://www.chewy.com/hikari-frozen-bloodworms/dp/123489',
        rating: 4.7,
        reviewCount: 234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Water Conditioner
      ShoppingItem(
        id: 'fish_water_conditioner',
        name: 'Aquarium Water Conditioner',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 9.99,
        description: 'Removes chlorine and neutralizes heavy metals',
        brand: 'API',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['water', 'conditioner', 'chlorine', 'metals'],
        chewyUrl: 'https://www.chewy.com/api-water-conditioner/dp/123490',
        rating: 4.8,
        reviewCount: 2341,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Fish Tank Filter
      ShoppingItem(
        id: 'fish_tank_filter',
        name: 'Aquarium Power Filter',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 29.99,
        description: 'Hang-on-back filter for aquariums',
        brand: 'Marineland',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['filter', 'aquarium', 'hang-on', 'power'],
        chewyUrl: 'https://www.chewy.com/marineland-power-filter/dp/123491',
        rating: 4.6,
        reviewCount: 892,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Fish Tank Heater
      ShoppingItem(
        id: 'fish_tank_heater',
        name: 'Aquarium Heater 50W',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 19.99,
        description: 'Submersible heater for tropical fish',
        brand: 'Aqueon',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['heater', 'aquarium', 'submersible', 'tropical'],
        chewyUrl: 'https://www.chewy.com/aqueon-heater-50w/dp/123492',
        rating: 4.5,
        reviewCount: 456,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getBirdProducts() {
    return [
      // Bird Food
      ShoppingItem(
        id: 'bird_seed_mix',
        name: 'Premium Bird Seed Mix',
        category: 'Food',
        priority: 'High',
        estimatedCost: 12.99,
        description: 'Nutritious seed mix for parakeets and small birds',
        brand: 'Kaytee',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['food', 'seeds', 'premium', 'small-birds'],
        chewyUrl: 'https://www.chewy.com/kaytee-premium-seed-mix/dp/123493',
        rating: 4.4,
        reviewCount: 456,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'bird_pellets',
        name: 'Bird Pellets - Complete Nutrition',
        category: 'Food',
        priority: 'High',
        estimatedCost: 15.99,
        description: 'Complete nutrition pellets for birds',
        brand: 'Zupreem',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['food', 'pellets', 'complete', 'nutrition'],
        chewyUrl: 'https://www.chewy.com/zupreem-bird-pellets/dp/123494',
        rating: 4.6,
        reviewCount: 234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Bird Toys
      ShoppingItem(
        id: 'bird_toy_mirror',
        name: 'Bird Mirror Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 8.99,
        description: 'Mirror toy for birds to interact with',
        brand: 'Penn-Plax',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['toys', 'mirror', 'interactive', 'birds'],
        chewyUrl: 'https://www.chewy.com/penn-plax-bird-mirror/dp/123495',
        rating: 4.3,
        reviewCount: 123,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Bird Cage
      ShoppingItem(
        id: 'bird_cage_medium',
        name: 'Medium Bird Cage',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 89.99,
        description: 'Spacious cage for medium-sized birds',
        brand: 'Prevue',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['cage', 'medium', 'spacious', 'birds'],
        chewyUrl: 'https://www.chewy.com/prevue-bird-cage/dp/123496',
        rating: 4.7,
        reviewCount: 234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getHamsterProducts() {
    return [
      // Hamster Food
      ShoppingItem(
        id: 'hamster_food_mix',
        name: 'Hamster Food Mix',
        category: 'Food',
        priority: 'High',
        estimatedCost: 6.99,
        description: 'Complete nutrition mix for hamsters',
        brand: 'Kaytee',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop',
        tags: ['food', 'mix', 'complete', 'nutrition'],
        chewyUrl: 'https://www.chewy.com/kaytee-hamster-food/dp/123497',
        rating: 4.3,
        reviewCount: 234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Hamster Bedding
      ShoppingItem(
        id: 'hamster_bedding',
        name: 'Hamster Bedding - Paper',
        category: 'Hygiene',
        priority: 'High',
        estimatedCost: 8.99,
        description: 'Soft paper bedding for hamsters',
        brand: 'Carefresh',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop',
        tags: ['bedding', 'paper', 'soft', 'hamsters'],
        chewyUrl: 'https://www.chewy.com/carefresh-hamster-bedding/dp/123498',
        rating: 4.5,
        reviewCount: 567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Hamster Wheel
      ShoppingItem(
        id: 'hamster_wheel',
        name: 'Silent Spinner Hamster Wheel',
        category: 'Equipment',
        priority: 'Medium',
        estimatedCost: 14.99,
        description: 'Silent wheel for hamsters to exercise',
        brand: 'Kaytee',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop',
        tags: ['wheel', 'silent', 'exercise', 'hamsters'],
        chewyUrl: 'https://www.chewy.com/kaytee-silent-spinner/dp/123499',
        rating: 4.6,
        reviewCount: 345,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getRabbitProducts() {
    return [
      // Rabbit Food
      ShoppingItem(
        id: 'rabbit_pellets',
        name: 'Rabbit Pellets',
        category: 'Food',
        priority: 'High',
        estimatedCost: 14.99,
        description: 'Timothy hay-based pellets for adult rabbits',
        brand: 'Oxbow',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'pellets', 'timothy', 'adult'],
        chewyUrl: 'https://www.chewy.com/oxbow-rabbit-pellets/dp/123500',
        rating: 4.6,
        reviewCount: 567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Rabbit Hay
      ShoppingItem(
        id: 'rabbit_hay_timothy',
        name: 'Timothy Hay for Rabbits',
        category: 'Food',
        priority: 'High',
        estimatedCost: 19.99,
        description: 'Premium timothy hay for rabbits',
        brand: 'Oxbow',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['hay', 'timothy', 'premium', 'rabbits'],
        chewyUrl: 'https://www.chewy.com/oxbow-timothy-hay/dp/123501',
        rating: 4.8,
        reviewCount: 892,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Rabbit Cage
      ShoppingItem(
        id: 'rabbit_cage_large',
        name: 'Large Rabbit Cage',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 79.99,
        description: 'Spacious cage for rabbits',
        brand: 'Midwest',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['cage', 'large', 'spacious', 'rabbits'],
        chewyUrl: 'https://www.chewy.com/midwest-rabbit-cage/dp/123502',
        rating: 4.5,
        reviewCount: 234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getSnakeProducts() {
    return [
      // Snake Food
      ShoppingItem(
        id: 'snake_mice_frozen',
        name: 'Frozen Mice for Snakes',
        category: 'Food',
        priority: 'High',
        estimatedCost: 19.99,
        description: 'Frozen feeder mice for snakes',
        brand: 'Arctic Mice',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'frozen', 'mice', 'feeder'],
        chewyUrl: 'https://www.chewy.com/arctic-mice-frozen/dp/123503',
        rating: 4.5,
        reviewCount: 123,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Snake Tank
      ShoppingItem(
        id: 'snake_tank_terrarium',
        name: 'Snake Terrarium',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 149.99,
        description: 'Glass terrarium for snakes',
        brand: 'Exo Terra',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['terrarium', 'glass', 'snakes', 'large'],
        chewyUrl: 'https://www.chewy.com/exo-terra-snake-terrarium/dp/123504',
        rating: 4.7,
        reviewCount: 89,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Snake Heat Mat
      ShoppingItem(
        id: 'snake_heat_mat',
        name: 'Under Tank Heater for Snakes',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 24.99,
        description: 'Heat mat for snake terrariums',
        brand: 'Zoo Med',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['heater', 'heat-mat', 'under-tank', 'snakes'],
        chewyUrl: 'https://www.chewy.com/zoo-med-heat-mat/dp/123505',
        rating: 4.6,
        reviewCount: 156,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getLizardProducts() {
    return [
      // Lizard Food
      ShoppingItem(
        id: 'lizard_crickets',
        name: 'Live Crickets for Lizards',
        category: 'Food',
        priority: 'High',
        estimatedCost: 8.99,
        description: 'Live crickets for insectivorous lizards',
        brand: 'Fluker\'s',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'live', 'crickets', 'insects'],
        chewyUrl: 'https://www.chewy.com/flukers-live-crickets/dp/123506',
        rating: 4.4,
        reviewCount: 89,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      // Lizard UVB Light
      ShoppingItem(
        id: 'lizard_uvb_light',
        name: 'UVB Light for Lizards',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 34.99,
        description: 'UVB light for lizard terrariums',
        brand: 'Zoo Med',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['light', 'uvb', 'lizards', 'terrarium'],
        chewyUrl: 'https://www.chewy.com/zoo-med-uvb-light/dp/123507',
        rating: 4.7,
        reviewCount: 234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getChickenProducts() {
    return [
      // Chicken Feed
      ShoppingItem(
        id: 'chicken_layer_feed',
        name: 'Layer Feed for Chickens',
        category: 'Food',
        priority: 'High',
        estimatedCost: 24.99,
        description: 'Complete layer feed for egg-laying chickens',
        brand: 'Purina',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'layer', 'eggs', 'complete'],
        chewyUrl: 'https://www.chewy.com/purina-layer-feed/dp/123508',
        rating: 4.7,
        reviewCount: 234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Chicken Grit
      ShoppingItem(
        id: 'chicken_grit',
        name: 'Chicken Grit for Digestion',
        category: 'Food',
        priority: 'Medium',
        estimatedCost: 12.99,
        description: 'Grit to help chickens digest their food',
        brand: 'Manna Pro',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'grit', 'digestion', 'supplement'],
        chewyUrl: 'https://www.chewy.com/manna-pro-chicken-grit/dp/123509',
        rating: 4.5,
        reviewCount: 156,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      // Chicken Coop
      ShoppingItem(
        id: 'chicken_coop',
        name: 'Chicken Coop with Run',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 299.99,
        description: 'Wooden chicken coop with attached run',
        brand: 'Tractor Supply',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['coop', 'wooden', 'run', 'chickens'],
        chewyUrl: 'https://www.chewy.com/tractor-supply-chicken-coop/dp/123510',
        rating: 4.6,
        reviewCount: 89,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  // Placeholder methods for other pet types with basic products
  static List<ShoppingItem> _getGuineaPigProducts() {
    return [
      ShoppingItem(
        id: 'guinea_pig_food',
        name: 'Guinea Pig Food Pellets',
        category: 'Food',
        priority: 'High',
        estimatedCost: 11.99,
        description: 'Vitamin C enriched pellets for guinea pigs',
        brand: 'Oxbow',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'pellets', 'vitamin-c', 'guinea-pigs'],
        chewyUrl: 'https://www.chewy.com/oxbow-guinea-pig-food/dp/123511',
        rating: 4.6,
        reviewCount: 234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getFrogProducts() {
    return [
      ShoppingItem(
        id: 'frog_food_crickets',
        name: 'Live Crickets for Frogs',
        category: 'Food',
        priority: 'High',
        estimatedCost: 7.99,
        description: 'Live crickets for frogs and amphibians',
        brand: 'Fluker\'s',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'live', 'crickets', 'frogs'],
        chewyUrl: 'https://www.chewy.com/flukers-frog-crickets/dp/123512',
        rating: 4.4,
        reviewCount: 67,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getTarantulaProducts() {
    return [
      ShoppingItem(
        id: 'tarantula_crickets',
        name: 'Live Crickets for Tarantulas',
        category: 'Food',
        priority: 'High',
        estimatedCost: 6.99,
        description: 'Live crickets for tarantulas',
        brand: 'Fluker\'s',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'live', 'crickets', 'tarantulas'],
        chewyUrl: 'https://www.chewy.com/flukers-tarantula-crickets/dp/123513',
        rating: 4.3,
        reviewCount: 45,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getAxolotlProducts() {
    return [
      ShoppingItem(
        id: 'axolotl_worms',
        name: 'Live Worms for Axolotls',
        category: 'Food',
        priority: 'High',
        estimatedCost: 9.99,
        description: 'Live worms for axolotls',
        brand: 'Fluker\'s',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'live', 'worms', 'axolotls'],
        chewyUrl: 'https://www.chewy.com/flukers-axolotl-worms/dp/123514',
        rating: 4.5,
        reviewCount: 34,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getMouseProducts() {
    return [
      ShoppingItem(
        id: 'mouse_food_mix',
        name: 'Mouse Food Mix',
        category: 'Food',
        priority: 'High',
        estimatedCost: 5.99,
        description: 'Complete nutrition mix for mice',
        brand: 'Kaytee',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'mix', 'complete', 'mice'],
        chewyUrl: 'https://www.chewy.com/kaytee-mouse-food/dp/123515',
        rating: 4.4,
        reviewCount: 123,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getGoatProducts() {
    return [
      ShoppingItem(
        id: 'goat_feed',
        name: 'Goat Feed Pellets',
        category: 'Food',
        priority: 'High',
        estimatedCost: 34.99,
        description: 'Complete goat feed pellets',
        brand: 'Purina',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'pellets', 'complete', 'goats'],
        chewyUrl: 'https://www.chewy.com/purina-goat-feed/dp/123516',
        rating: 4.6,
        reviewCount: 78,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
    ];
  }

  static List<ShoppingItem> _getHedgehogProducts() {
    return [
      ShoppingItem(
        id: 'hedgehog_food',
        name: 'Hedgehog Food Mix',
        category: 'Food',
        priority: 'High',
        estimatedCost: 12.99,
        description: 'Complete nutrition for hedgehogs',
        brand: 'Exotic Nutrition',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['food', 'mix', 'complete', 'hedgehogs'],
        chewyUrl: 'https://www.chewy.com/exotic-nutrition-hedgehog-food/dp/123517',
        rating: 4.5,
        reviewCount: 89,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
    ];
  }
} 