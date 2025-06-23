import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';
import '../widgets/shopping_item_card.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  String _selectedCategory = 'All';
  String _selectedPetType = 'All';
  String _searchQuery = '';
  List<ShoppingItem> _filteredProducts = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'All',
    'Food',
    'Toys',
    'Beds',
    'Hygiene',
    'Equipment',
  ];

  final List<String> _petTypes = [
    'All',
    'Dog',
    'Cat',
    'Turtle',
    'Fish',
    'Bird',
    'Hamster',
    'Rabbit',
    'Snake',
    'Lizard',
    'Chicken',
    'Guinea Pig',
    'Frog',
    'Tarantula',
    'Axolotl',
    'Mouse',
    'Goat',
    'Hedgehog',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _applyFilters();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _applyFilters() {
    List<ShoppingItem> products;

    // Get products based on pet type filter
    if (_selectedPetType == 'All') {
      products = ShoppingService.getAllProducts();
    } else {
      products = ShoppingService.getProductsForPet(_selectedPetType);
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      products = products.where((item) => 
        item.category.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      products = products.where((item) =>
        item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
        item.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
        item.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    setState(() {
      _filteredProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    // Pet Type Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPetType,
                        decoration: InputDecoration(
                          labelText: 'Pet Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _petTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPetType = newValue!;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters or search terms',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ShoppingItemCard(
                              item: _filteredProducts[index],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 