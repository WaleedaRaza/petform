import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/shopping_item.dart';
import '../widgets/video_background.dart';


class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPetType = 'All';
  final List<String> _petTypes = [
    'All',
    'Dogs',
    'Cats',
    'Fish',
    'Birds',
    'Reptiles',
    'Small Animals',
  ];



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh shopping items when this screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.refreshShoppingItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return VideoBackground(
          videoPath: 'assets/backdrop2.mp4',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showBottomSheetAddItem(appState),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: Column(
            children: [
              // Header with title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title only - no button here
                    Text(
                      'Shopping',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pet type filter dropdown
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPetType,
                        decoration: InputDecoration(
                          labelText: 'Pet Type',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surface,
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Tab bar
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                      Tab(text: 'Browse All'),
                    Tab(text: 'My List'),
                    Tab(text: 'Search'),
                    Tab(text: 'Categories'),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                      _buildBrowseAllTab(appState),
                    _buildMyListTab(appState),
                    _buildSearchTab(appState),
                    _buildCategoriesTab(appState),
                  ],
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildMyListTab(AppStateProvider appState) {
    final myList = appState.shoppingItems;
    
    return Column(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Shopping List',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${myList.length} items • \$${_calculateTotalCost(myList).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (myList.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _clearShoppingList(appState),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
            ],
          ),
        ),
        
        // Shopping list
        Expanded(
          child: myList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your shopping list is empty'),
                      SizedBox(height: 8),
                      Text('Add items from suggestions to get started'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100, // Extra padding for bottom navigation
                  ),
                  itemCount: myList.length,
                  itemBuilder: (context, index) {
                    return _buildShoppingListItem(myList[index], appState);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBrowseAllTab(AppStateProvider appState) {
    // Simple placeholder for now - we'll focus on the working add functionality
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Browse products coming soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListItem(ShoppingItem item, AppStateProvider appState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
                child: SizedBox(
            width: 50,
            height: 50,
            child: Container(
              color: Colors.grey[300],
              child: const Icon(Icons.shopping_bag),
            ),
                          ),
                        ),
        title: Text(
                            item.name,
                              style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.brand ?? ''} • \$${item.estimatedCost.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor(item.category).withOpacity(0.3),
                ),
              ),
              child: Text(
                item.category,
                style: TextStyle(
                  color: _getCategoryColor(item.category),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showEditItemDialog(appState, item),
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Edit item',
            ),
            IconButton(
              onPressed: () => appState.removeShoppingItem(item.id),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete item',
            ),
          ],
        ),
        onTap: () async {
          // Open web link if available (custom URL or Chewy URL)
          String urlString;
          if (item.chewyUrl != null && item.chewyUrl!.isNotEmpty && !item.chewyUrl!.endsWith('/dp/')) {
            // Use custom URL or valid Chewy URL
            urlString = item.chewyUrl!;
          } else if (item.store == 'Custom') {
            // For custom items without URL, don't search Chewy
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No URL provided for this custom item')),
            );
            return;
          } else {
            // If URL is incomplete or missing for Chewy items, search for the product on Chewy
            final searchQuery = Uri.encodeComponent(item.name);
            urlString = 'https://www.chewy.com/s?query=$searchQuery';
          }
          
          final url = Uri.parse(urlString);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open link')),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchTab(AppStateProvider appState) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for pet products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Search results
        Expanded(
          child: _searchQuery.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Search for pet products'),
                      SizedBox(height: 8),
                      Text('Try searching for food, toys, beds, etc.'),
                    ],
                  ),
                )
              : _buildSearchResults(appState),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(AppStateProvider appState) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 9, // Number of categories excluding 'All'
      itemBuilder: (context, index) {
        final categories = ['Food', 'Toys', 'Beds', 'Accessories', 'Grooming', 'Treats', 'Hygiene', 'Equipment', 'Housing'];
        final category = categories[index];
        final items = _selectedPetType == 'All'
            ? ShoppingService.getSuggestionsByCategory(category)
            : ShoppingService.getProductsForPet(_selectedPetType).where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
        return _buildCategoryCard(category, items, appState);
      },
    );
  }

  Widget _buildSuggestionCard(ShoppingItem item, AppStateProvider appState) {
    // Check if item is in list by comparing name, brand, and store (since ID changes when saved to DB)
    final isInList = appState.shoppingItems.any((i) => 
        i.name == item.name && 
        i.brand == item.brand && 
        i.store == item.store);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showItemDetails(item, appState),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 64),
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store badge and rating
                  Row(
                    children: [
                      if (item.store != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isChewyProduct 
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.store!,
                            style: TextStyle(
                              color: item.isChewyProduct ? Colors.orange : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (item.hasRating) ...[
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          item.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (item.hasReviews) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${item.reviewCount})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Product name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Price and Chewy badges
                  Row(
                    children: [
                      Text(
                        '\$${item.estimatedCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange,
                        ),
                      ),
                      const Spacer(),
                      if (item.hasFreeShipping)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FREE SHIPPING',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (item.isAutoShipEligible) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'AUTO-SHIP',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action buttons
                  Row(
                    children: [
                        Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            String urlString;
                            if (item.chewyUrl != null && item.chewyUrl!.isNotEmpty && !item.chewyUrl!.endsWith('/dp/')) {
                              urlString = item.chewyUrl!;
                            } else {
                              // If URL is incomplete or missing, search for the product on Chewy
                              final searchQuery = Uri.encodeComponent(item.name);
                              urlString = 'https://www.chewy.com/s?query=$searchQuery';
                            }
                            
                            final url = Uri.parse(urlString);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not open link')),
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Link'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isInList) {
                              // Find the item in the shopping list by name, brand, and store
                              final itemToRemove = appState.shoppingItems.firstWhere(
                                (i) => i.name == item.name && i.brand == item.brand && i.store == item.store,
                                orElse: () => item,
                              );
                              appState.removeShoppingItem(itemToRemove.id);
                            } else {
                              appState.addShoppingItem(item);
                            }
                          },
                          icon: Icon(
                            isInList ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                          ),
                          label: Text(isInList ? 'Remove' : 'Add to List'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInList ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showItemDetails(ShoppingItem item, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildItemDetailsSheet(item, appState),
    );
  }

  Widget _buildItemDetailsSheet(ShoppingItem item, AppStateProvider appState) {
    // Check if item is in list by comparing name, brand, and store (since ID changes when saved to DB)
    final isInList = appState.shoppingItems.any((i) => 
        i.name == item.name && 
        i.brand == item.brand && 
        i.store == item.store);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Image
            if (item.imageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 64),
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Title and price
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${item.estimatedCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Brand and category
            Row(
              children: [
                if (item.brand != null) ...[
                  Text(
                    item.brand!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                _buildPriorityChip(item.priority),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            if (item.description != null) ...[
              Text(
                'Description',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
            
            // Store
            if (item.store != null) ...[
              Text(
                'Available at: ${item.store}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isInList) {
                        // Find the item in the shopping list by name, brand, and store
                        final itemToRemove = appState.shoppingItems.firstWhere(
                          (i) => i.name == item.name && i.brand == item.brand && i.store == item.store,
                          orElse: () => item,
                        );
                        appState.removeShoppingItem(itemToRemove.id);
                      } else {
                        appState.addShoppingItem(item);
                      }
                      Navigator.pop(context);
                    },
                    icon: Icon(isInList ? Icons.remove_shopping_cart : Icons.add_shopping_cart),
                    label: Text(isInList ? 'Remove from List' : 'Add to List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInList ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildSearchResults(AppStateProvider appState) {
    final searchResults = ShoppingService.searchProducts(_searchQuery);
    
    if (searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No products found'),
            SizedBox(height: 8),
            Text('Try different keywords'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 100, // Extra padding for bottom navigation
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return _buildSuggestionCard(searchResults[index], appState);
      },
    );
  }

  Widget _buildCategoryCard(String category, List<ShoppingItem> items, AppStateProvider appState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCategoryItems(category, items, appState),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${items.length} items',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }



  double _calculateTotalCost(List<ShoppingItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalCost);
  }

  void _clearShoppingList(AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Shopping List'),
        content: const Text('Are you sure you want to clear all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all items
              for (final item in appState.shoppingItems) {
                appState.removeShoppingItem(item.id);
              }
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showCategoryItems(String category, List<ShoppingItem> items, AppStateProvider appState) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(category),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildSuggestionCard(items[index], appState);
            },
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'toys':
        return Icons.toys;
      case 'beds':
        return Icons.bed;
      case 'accessories':
        return Icons.style;
      case 'grooming':
        return Icons.content_cut;
      case 'treats':
        return Icons.cake;
      case 'hygiene':
        return Icons.cleaning_services;
      case 'equipment':
        return Icons.build;
      case 'housing':
        return Icons.home;
      default:
        return Icons.shopping_cart;
    }
  }

  void _showAddCustomItemDialog(AppStateProvider appState) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    final notesController = TextEditingController();
    final urlController = TextEditingController(); // New URL field
    String selectedCategory = 'Food';
    int quantity = 1;

    final categories = ['Food', 'Toys', 'Beds', 'Accessories', 'Grooming', 'Treats', 'Hygiene', 'Equipment', 'Housing'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Custom Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        )).toList(),
                        onChanged: (value) => setState(() => selectedCategory = value!),
                      ),
                    ),
                    // Priority field removed per user request
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quantity', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: () => setState(() => quantity++),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Product URL (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/product',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an item name')),
                  );
                  return;
                }

                final customItem = ShoppingItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  category: selectedCategory,
                  priority: 'Medium', // Default priority since field was removed
                  estimatedCost: double.tryParse(priceController.text) ?? 0.0,
                  brand: brandController.text.trim().isNotEmpty ? brandController.text.trim() : null,
                  store: 'Custom',
                  quantity: quantity,
                  notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  chewyUrl: urlController.text.trim().isNotEmpty ? urlController.text.trim() : null, // Store custom URL in chewyUrl field
                );

                appState.addShoppingItem(customItem);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${customItem.name}" to shopping list')),
                );
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(AppStateProvider appState, ShoppingItem item) {
    final nameController = TextEditingController(text: item.name);
    final brandController = TextEditingController(text: item.brand ?? '');
    final priceController = TextEditingController(text: item.estimatedCost.toString());
    final notesController = TextEditingController(text: item.notes ?? '');
    final urlController = TextEditingController(text: item.chewyUrl ?? '');
    String selectedCategory = item.category;
    int quantity = item.quantity;

    final categories = ['Food', 'Toys', 'Beds', 'Accessories', 'Grooming', 'Treats', 'Hygiene', 'Equipment', 'Housing'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quantity', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: () => setState(() => quantity++),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Product URL (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/product',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an item name')),
                  );
                  return;
                }

                final updatedItem = ShoppingItem(
                  id: item.id, // Keep same ID
                  name: nameController.text.trim(),
                  category: selectedCategory,
                  priority: item.priority, // Keep existing priority
                  estimatedCost: double.tryParse(priceController.text) ?? 0.0,
                  brand: brandController.text.trim().isNotEmpty ? brandController.text.trim() : null,
                  store: item.store, // Keep existing store
                  quantity: quantity,
                  notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  chewyUrl: urlController.text.trim().isNotEmpty ? urlController.text.trim() : null,
                  isCompleted: item.isCompleted, // Keep completion status
                  createdAt: item.createdAt, // Keep original creation date
                  completedAt: item.completedAt, // Keep completion date
                  tags: item.tags, // Keep existing tags
                  imageUrl: item.imageUrl, // Keep existing image
                  rating: item.rating, // Keep existing rating
                  reviewCount: item.reviewCount, // Keep existing review count
                  inStock: item.inStock, // Keep existing stock status
                  autoShip: item.autoShip, // Keep existing auto ship
                  freeShipping: item.freeShipping, // Keep existing free shipping
                );

                appState.updateShoppingItem(updatedItem.id, updatedItem);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated "${updatedItem.name}"')),
                );
              },
              child: const Text('Update Item'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.green;
      case 'toys':
        return Colors.purple;
      case 'beds':
        return Colors.blue;
      case 'accessories':
        return Colors.orange;
      case 'grooming':
        return Colors.pink;
      case 'treats':
        return Colors.amber;
      case 'hygiene':
        return Colors.teal;
      case 'equipment':
        return Colors.brown;
      case 'housing':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  // NEW APPROACH: Bottom Sheet instead of Dialog
  void _showBottomSheetAddItem(AppStateProvider appState) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Add Shopping Item',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Name field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name *',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              
              // Category field
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: 'Food, Toys, etc.',
                ),
              ),
              const SizedBox(height: 30),
              
              // Add button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an item name')),
                      );
                      return;
                    }

                    // Create simple shopping item
                    final customItem = ShoppingItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      category: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : 'Other',
                      priority: 'Medium',
                      estimatedCost: 0.0,
                      brand: null,
                      store: 'Custom',
                      quantity: 1,
                      notes: null,
                      chewyUrl: null,
                      isCompleted: false,
                      createdAt: DateTime.now(),
                      completedAt: null,
                      tags: [],
                      imageUrl: null,
                      rating: null,
                      reviewCount: null,
                      inStock: null,
                      autoShip: null,
                      freeShipping: null,
                    );

                    // Add to shopping list
                    appState.addShoppingItem(customItem);
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added "${customItem.name}" to shopping list')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 