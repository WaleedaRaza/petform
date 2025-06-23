import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/shopping_item.dart';

class ChewyService {
  // Simulated Chewy API base URL
  static const String _baseUrl = 'https://api.chewy.com';
  
  // Comprehensive product database with real Chewy-like data
  static final Map<String, List<ShoppingItem>> _chewyProducts = {
    'dog': [
      // Dog Food - Premium
      ShoppingItem(
        id: 'chewy_dog_food_royal_canin',
        name: 'Royal Canin Adult Dog Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 34.99,
        description: 'Premium dry food formulated for adult dogs with balanced nutrition',
        brand: 'Royal Canin',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=300&fit=crop',
        tags: ['food', 'premium', 'adult', 'dry', 'chewy'],
        chewyUrl: 'https://www.chewy.com/royal-canin-adult-dog-food/dp/123456',
        rating: 4.8,
        reviewCount: 1247,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_dog_food_blue_buffalo',
        name: 'Blue Buffalo Life Protection Formula',
        category: 'Food',
        priority: 'High',
        estimatedCost: 29.99,
        description: 'Natural dry dog food with real chicken and brown rice',
        brand: 'Blue Buffalo',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop',
        tags: ['food', 'natural', 'chicken', 'grain', 'chewy'],
        chewyUrl: 'https://www.chewy.com/blue-buffalo-life-protection/dp/123457',
        rating: 4.6,
        reviewCount: 892,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_dog_food_purina_pro',
        name: 'Purina Pro Plan Adult Dog Food',
        category: 'Food',
        priority: 'Medium',
        estimatedCost: 24.99,
        description: 'High-protein dry food for active adult dogs',
        brand: 'Purina Pro Plan',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&h=300&fit=crop',
        tags: ['food', 'high-protein', 'active', 'adult', 'chewy'],
        chewyUrl: 'https://www.chewy.com/purina-pro-plan-adult/dp/123458',
        rating: 4.4,
        reviewCount: 1567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      
      // Dog Toys
      ShoppingItem(
        id: 'chewy_dog_toy_kong_classic',
        name: 'Kong Classic Dog Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 12.99,
        description: 'Durable rubber toy perfect for chewing and treat stuffing',
        brand: 'Kong',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=300&fit=crop',
        tags: ['toys', 'chew', 'interactive', 'durable', 'chewy'],
        chewyUrl: 'https://www.chewy.com/kong-classic-dog-toy/dp/123459',
        rating: 4.7,
        reviewCount: 2341,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_dog_toy_rope',
        name: 'Cotton Rope Dog Toy',
        category: 'Toys',
        priority: 'Low',
        estimatedCost: 8.99,
        description: 'Natural cotton rope toy for tug-of-war and chewing',
        brand: 'PetSafe',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['toys', 'rope', 'tug', 'natural', 'chewy'],
        chewyUrl: 'https://www.chewy.com/cotton-rope-dog-toy/dp/123460',
        rating: 4.3,
        reviewCount: 567,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      
      // Dog Beds
      ShoppingItem(
        id: 'chewy_dog_bed_orthopedic',
        name: 'Orthopedic Memory Foam Dog Bed',
        category: 'Beds',
        priority: 'High',
        estimatedCost: 49.99,
        description: 'Memory foam bed for joint support and comfort',
        brand: 'Big Barker',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&h=300&fit=crop',
        tags: ['bed', 'orthopedic', 'memory-foam', 'comfort', 'chewy'],
        chewyUrl: 'https://www.chewy.com/orthopedic-memory-foam-bed/dp/123461',
        rating: 4.9,
        reviewCount: 892,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_dog_bed_plush',
        name: 'Plush Donut Dog Bed',
        category: 'Beds',
        priority: 'Medium',
        estimatedCost: 29.99,
        description: 'Soft, plush donut bed with raised sides for security',
        brand: 'Frisco',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['bed', 'plush', 'donut', 'security', 'chewy'],
        chewyUrl: 'https://www.chewy.com/plush-donut-dog-bed/dp/123462',
        rating: 4.5,
        reviewCount: 1234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      
      // Dog Treats
      ShoppingItem(
        id: 'chewy_dog_treats_training',
        name: 'Training Treats - Soft & Chewy',
        category: 'Treats',
        priority: 'Medium',
        estimatedCost: 6.99,
        description: 'Small, soft treats perfect for training sessions',
        brand: 'Zuke\'s',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['treats', 'training', 'soft', 'small', 'chewy'],
        chewyUrl: 'https://www.chewy.com/zukes-training-treats/dp/123463',
        rating: 4.6,
        reviewCount: 2341,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_dog_treats_dental',
        name: 'Dental Chews for Dogs',
        category: 'Treats',
        priority: 'Low',
        estimatedCost: 14.99,
        description: 'Dental chews that clean teeth and freshen breath',
        brand: 'Greenies',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop',
        tags: ['treats', 'dental', 'clean', 'breath', 'chewy'],
        chewyUrl: 'https://www.chewy.com/greenies-dental-chews/dp/123464',
        rating: 4.7,
        reviewCount: 3456,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      
      // Dog Grooming
      ShoppingItem(
        id: 'chewy_dog_shampoo_oatmeal',
        name: 'Oatmeal Dog Shampoo',
        category: 'Grooming',
        priority: 'Low',
        estimatedCost: 8.99,
        description: 'Gentle oatmeal shampoo for sensitive skin',
        brand: 'Earthbath',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop',
        tags: ['grooming', 'shampoo', 'sensitive-skin', 'oatmeal', 'chewy'],
        chewyUrl: 'https://www.chewy.com/earthbath-oatmeal-shampoo/dp/123465',
        rating: 4.4,
        reviewCount: 789,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_dog_brush_slicker',
        name: 'Slicker Brush for Dogs',
        category: 'Grooming',
        priority: 'Medium',
        estimatedCost: 12.99,
        description: 'Professional slicker brush for detangling and grooming',
        brand: 'Hertzko',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['grooming', 'brush', 'slicker', 'detangle', 'chewy'],
        chewyUrl: 'https://www.chewy.com/hertzko-slicker-brush/dp/123466',
        rating: 4.8,
        reviewCount: 1456,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      
      // Dog Accessories
      ShoppingItem(
        id: 'chewy_dog_collar_leather',
        name: 'Leather Dog Collar',
        category: 'Accessories',
        priority: 'High',
        estimatedCost: 24.99,
        description: 'Comfortable leather collar with brass buckle',
        brand: 'Ruffwear',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=300&fit=crop',
        tags: ['collar', 'leather', 'comfortable', 'durable', 'chewy'],
        chewyUrl: 'https://www.chewy.com/ruffwear-leather-collar/dp/123467',
        rating: 4.6,
        reviewCount: 678,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_dog_leash_retractable',
        name: 'Retractable Dog Leash',
        category: 'Accessories',
        priority: 'Medium',
        estimatedCost: 19.99,
        description: '16ft retractable leash with comfortable grip',
        brand: 'Flexi',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1583511655826-05700d52f5d9?w=400&h=300&fit=crop',
        tags: ['leash', 'retractable', '16ft', 'comfortable', 'chewy'],
        chewyUrl: 'https://www.chewy.com/flexi-retractable-leash/dp/123468',
        rating: 4.5,
        reviewCount: 2341,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ],
    
    'cat': [
      // Cat Food - Premium
      ShoppingItem(
        id: 'chewy_cat_food_royal_canin',
        name: 'Royal Canin Adult Cat Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 28.99,
        description: 'Premium dry food formulated for adult cats',
        brand: 'Royal Canin',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['food', 'premium', 'adult', 'dry', 'chewy'],
        chewyUrl: 'https://www.chewy.com/royal-canin-adult-cat-food/dp/123469',
        rating: 4.7,
        reviewCount: 1567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_cat_food_blue_buffalo',
        name: 'Blue Buffalo Indoor Cat Food',
        category: 'Food',
        priority: 'High',
        estimatedCost: 26.99,
        description: 'Natural dry food for indoor cats with weight control',
        brand: 'Blue Buffalo',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['food', 'natural', 'indoor', 'weight-control', 'chewy'],
        chewyUrl: 'https://www.chewy.com/blue-buffalo-indoor-cat/dp/123470',
        rating: 4.5,
        reviewCount: 892,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      
      // Cat Litter
      ShoppingItem(
        id: 'chewy_cat_litter_clumping',
        name: 'Clumping Cat Litter',
        category: 'Hygiene',
        priority: 'High',
        estimatedCost: 19.99,
        description: 'Scented clumping litter for easy cleanup',
        brand: 'Tidy Cats',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['litter', 'clumping', 'scented', 'cleanup', 'chewy'],
        chewyUrl: 'https://www.chewy.com/tidy-cats-clumping-litter/dp/123471',
        rating: 4.3,
        reviewCount: 2341,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_cat_litter_natural',
        name: 'Natural Pine Cat Litter',
        category: 'Hygiene',
        priority: 'Medium',
        estimatedCost: 24.99,
        description: 'Natural pine pellet litter, eco-friendly and odor control',
        brand: 'Feline Pine',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['litter', 'natural', 'pine', 'eco-friendly', 'chewy'],
        chewyUrl: 'https://www.chewy.com/feline-pine-natural-litter/dp/123472',
        rating: 4.6,
        reviewCount: 567,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      
      // Cat Toys
      ShoppingItem(
        id: 'chewy_cat_toy_feather_wand',
        name: 'Feather Wand Cat Toy',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 9.99,
        description: 'Interactive feather wand for play and exercise',
        brand: 'SmartyKat',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400&h=300&fit=crop',
        tags: ['toys', 'feather', 'interactive', 'exercise', 'chewy'],
        chewyUrl: 'https://www.chewy.com/smartykat-feather-wand/dp/123473',
        rating: 4.7,
        reviewCount: 1234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_cat_scratcher_cardboard',
        name: 'Cardboard Cat Scratcher',
        category: 'Toys',
        priority: 'Medium',
        estimatedCost: 14.99,
        description: 'Replaceable cardboard scratcher with catnip',
        brand: 'SmartyKat',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400&h=300&fit=crop',
        tags: ['scratcher', 'cardboard', 'catnip', 'replaceable', 'chewy'],
        chewyUrl: 'https://www.chewy.com/smartykat-cardboard-scratcher/dp/123474',
        rating: 4.4,
        reviewCount: 789,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      
      // Cat Beds
      ShoppingItem(
        id: 'chewy_cat_bed_cozy',
        name: 'Cozy Cat Bed',
        category: 'Beds',
        priority: 'Medium',
        estimatedCost: 29.99,
        description: 'Soft, plush bed with raised sides',
        brand: 'K&H Pet Products',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['bed', 'plush', 'cozy', 'raised-sides', 'chewy'],
        chewyUrl: 'https://www.chewy.com/kh-cozy-cat-bed/dp/123475',
        rating: 4.8,
        reviewCount: 1456,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_cat_bed_window',
        name: 'Window Cat Bed',
        category: 'Beds',
        priority: 'Low',
        estimatedCost: 34.99,
        description: 'Window-mounted bed for sunbathing and bird watching',
        brand: 'K&H Pet Products',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['bed', 'window', 'sunbathing', 'mounted', 'chewy'],
        chewyUrl: 'https://www.chewy.com/kh-window-cat-bed/dp/123476',
        rating: 4.6,
        reviewCount: 678,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
      
      // Cat Treats
      ShoppingItem(
        id: 'chewy_cat_treats_salmon',
        name: 'Salmon Cat Treats',
        category: 'Treats',
        priority: 'Low',
        estimatedCost: 4.99,
        description: 'Grain-free salmon treats for cats',
        brand: 'Temptations',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
        tags: ['treats', 'salmon', 'grain-free', 'natural', 'chewy'],
        chewyUrl: 'https://www.chewy.com/temptations-salmon-treats/dp/123477',
        rating: 4.5,
        reviewCount: 3456,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_cat_treats_dental',
        name: 'Dental Cat Treats',
        category: 'Treats',
        priority: 'Low',
        estimatedCost: 6.99,
        description: 'Dental treats that clean teeth and freshen breath',
        brand: 'Greenies',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop',
        tags: ['treats', 'dental', 'clean', 'breath', 'chewy'],
        chewyUrl: 'https://www.chewy.com/greenies-cat-dental-treats/dp/123478',
        rating: 4.7,
        reviewCount: 2341,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
    ],
    
    'bird': [
      ShoppingItem(
        id: 'chewy_bird_seed_premium',
        name: 'Premium Bird Seed Mix',
        category: 'Food',
        priority: 'High',
        estimatedCost: 12.99,
        description: 'Nutritious seed mix for parakeets and small birds',
        brand: 'Kaytee',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['food', 'seeds', 'premium', 'small-birds', 'chewy'],
        chewyUrl: 'https://www.chewy.com/kaytee-premium-seed-mix/dp/123479',
        rating: 4.4,
        reviewCount: 456,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_bird_cage_large',
        name: 'Large Bird Cage',
        category: 'Housing',
        priority: 'High',
        estimatedCost: 89.99,
        description: 'Spacious cage with multiple perches and toys',
        brand: 'Prevue Pet Products',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=300&fit=crop',
        tags: ['cage', 'large', 'spacious', 'perches', 'chewy'],
        chewyUrl: 'https://www.chewy.com/prevue-large-bird-cage/dp/123480',
        rating: 4.6,
        reviewCount: 234,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ],
    
    'fish': [
      ShoppingItem(
        id: 'chewy_fish_food_flakes',
        name: 'Tropical Fish Flakes',
        category: 'Food',
        priority: 'High',
        estimatedCost: 8.99,
        description: 'Complete nutrition for tropical fish',
        brand: 'Tetra',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['food', 'flakes', 'tropical', 'complete', 'chewy'],
        chewyUrl: 'https://www.chewy.com/tetra-tropical-flakes/dp/123481',
        rating: 4.5,
        reviewCount: 1234,
        inStock: true,
        autoShip: true,
        freeShipping: true,
      ),
      ShoppingItem(
        id: 'chewy_fish_tank_filter',
        name: 'Aquarium Filter',
        category: 'Equipment',
        priority: 'High',
        estimatedCost: 24.99,
        description: 'Power filter for clean, healthy water',
        brand: 'Marineland',
        store: 'Chewy',
        imageUrl: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&h=300&fit=crop',
        tags: ['filter', 'water', 'clean', 'healthy', 'chewy'],
        chewyUrl: 'https://www.chewy.com/marineland-aquarium-filter/dp/123482',
        rating: 4.7,
        reviewCount: 567,
        inStock: true,
        autoShip: false,
        freeShipping: true,
      ),
    ],
  };

  // Get Chewy products for a specific pet type
  static List<ShoppingItem> getProductsForPet(String petType) {
    return _chewyProducts[petType.toLowerCase()] ?? [];
  }

  // Get all Chewy products
  static List<ShoppingItem> getAllProducts() {
    List<ShoppingItem> allProducts = [];
    _chewyProducts.values.forEach((products) {
      allProducts.addAll(products);
    });
    return allProducts;
  }

  // Search Chewy products
  static List<ShoppingItem> searchProducts(String query) {
    List<ShoppingItem> searchResults = [];
    final lowercaseQuery = query.toLowerCase();
    
    _chewyProducts.values.forEach((products) {
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

  // Get products by category
  static List<ShoppingItem> getProductsByCategory(String category) {
    List<ShoppingItem> categoryProducts = [];
    _chewyProducts.values.forEach((products) {
      categoryProducts.addAll(
        products.where((item) => item.category.toLowerCase() == category.toLowerCase())
      );
    });
    return categoryProducts;
  }

  // Get products by brand
  static List<ShoppingItem> getProductsByBrand(String brand) {
    List<ShoppingItem> brandProducts = [];
    _chewyProducts.values.forEach((products) {
      brandProducts.addAll(
        products.where((item) => item.brand?.toLowerCase() == brand.toLowerCase())
      );
    });
    return brandProducts;
  }

  // Get products with free shipping
  static List<ShoppingItem> getFreeShippingProducts() {
    List<ShoppingItem> freeShippingProducts = [];
    _chewyProducts.values.forEach((products) {
      freeShippingProducts.addAll(
        products.where((item) => item.freeShipping == true)
      );
    });
    return freeShippingProducts;
  }

  // Get products with auto-ship available
  static List<ShoppingItem> getAutoShipProducts() {
    List<ShoppingItem> autoShipProducts = [];
    _chewyProducts.values.forEach((products) {
      autoShipProducts.addAll(
        products.where((item) => item.autoShip == true)
      );
    });
    return autoShipProducts;
  }

  // Get products by price range
  static List<ShoppingItem> getProductsByPriceRange(double minPrice, double maxPrice) {
    List<ShoppingItem> priceRangeProducts = [];
    _chewyProducts.values.forEach((products) {
      priceRangeProducts.addAll(
        products.where((item) => 
          item.estimatedCost >= minPrice && item.estimatedCost <= maxPrice
        )
      );
    });
    return priceRangeProducts;
  }

  // Get top-rated products (4.5+ stars)
  static List<ShoppingItem> getTopRatedProducts() {
    List<ShoppingItem> topRatedProducts = [];
    _chewyProducts.values.forEach((products) {
      topRatedProducts.addAll(
        products.where((item) => item.rating >= 4.5)
      );
    });
    return topRatedProducts;
  }

  // Get best-selling products (1000+ reviews)
  static List<ShoppingItem> getBestSellingProducts() {
    List<ShoppingItem> bestSellingProducts = [];
    _chewyProducts.values.forEach((products) {
      bestSellingProducts.addAll(
        products.where((item) => item.reviewCount >= 1000)
      );
    });
    return bestSellingProducts;
  }

  // Simulate Chewy API call for product details
  static Future<Map<String, dynamic>> getProductDetails(String productId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find the product
    ShoppingItem? product;
    for (final products in _chewyProducts.values) {
      product = products.firstWhere((item) => item.id == productId);
      if (product != null) break;
    }
    
    if (product == null) {
      throw Exception('Product not found');
    }
    
    // Return detailed product information
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'brand': product.brand,
      'price': product.estimatedCost,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'inStock': product.inStock,
      'autoShip': product.autoShip,
      'freeShipping': product.freeShipping,
      'chewyUrl': product.chewyUrl,
      'imageUrl': product.imageUrl,
      'tags': product.tags,
      'category': product.category,
      'priority': product.priority,
      'similarProducts': _getSimilarProducts(product),
      'reviews': _generateMockReviews(product),
    };
  }

  // Get similar products
  static List<ShoppingItem> _getSimilarProducts(ShoppingItem product) {
    List<ShoppingItem> similarProducts = [];
    
    // Get products in the same category and brand
    for (final products in _chewyProducts.values) {
      similarProducts.addAll(
        products.where((item) => 
          item.category == product.category && 
          item.brand == product.brand &&
          item.id != product.id
        ).take(3)
      );
    }
    
    return similarProducts;
  }

  // Generate mock reviews
  static List<Map<String, dynamic>> _generateMockReviews(ShoppingItem product) {
    return [
      {
        'id': '1',
        'user': 'PetLover123',
        'rating': 5,
        'title': 'Great product!',
        'content': 'My pet loves this product. Highly recommend!',
        'date': '2024-01-15',
        'verified': true,
      },
      {
        'id': '2',
        'user': 'HappyCustomer',
        'rating': 4,
        'title': 'Good quality',
        'content': 'Good quality for the price. Would buy again.',
        'date': '2024-01-10',
        'verified': true,
      },
      {
        'id': '3',
        'user': 'PetParent',
        'rating': 5,
        'title': 'Excellent!',
        'content': 'Exceeded my expectations. My pet is very happy.',
        'date': '2024-01-05',
        'verified': false,
      },
    ];
  }

  // Simulate adding item to Chewy cart
  static Future<bool> addToCart(String productId, int quantity) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (kDebugMode) {
      print('Added $quantity of product $productId to Chewy cart');
    }
    
    return true;
  }

  // Simulate setting up auto-ship
  static Future<bool> setupAutoShip(String productId, int quantity, String frequency) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (kDebugMode) {
      print('Set up auto-ship for product $productId: $quantity every $frequency');
    }
    
    return true;
  }

  // Get Chewy shipping information
  static Map<String, dynamic> getShippingInfo() {
    return {
      'freeShippingThreshold': 49.0,
      'freeShippingMessage': 'Free shipping on orders over \$49',
      'autoShipDiscount': 0.05, // 5% discount
      'autoShipMessage': 'Save 5% with auto-ship',
      'deliveryTime': '1-3 business days',
      'returns': '30-day returns',
    };
  }
} 