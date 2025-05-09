import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1_user/models/product_model.dart';

class MerchScreen extends StatefulWidget {
  const MerchScreen({super.key});

  @override
  State<MerchScreen> createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  String _selectedCategory = '';

  // Update the _getProducts method to handle case-insensitive filtering
  Stream<List<Product>> _getProducts() {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
        'merch',
      );

      if (_selectedCategory.isNotEmpty) {
        if (_selectedCategory == 'Accessories') {
          // Include cleaning-related categories under Accessories
          final categories = [
            'Accessories',
            'Cleaning',
            'cleaning',
            'grooming',
            'Grooming',
          ];
          query = query.where('category', whereIn: categories);
        } else {
          query = query.where('category', isEqualTo: _selectedCategory);
        }
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              final data = doc.data();
              debugPrint('Processing document: ${doc.id}');
              debugPrint('Document data: $data');

              if (!data.containsKey('name') ||
                  !data.containsKey('description') ||
                  !data.containsKey('category') ||
                  !data.containsKey('imageUrl') ||
                  !data.containsKey('url')) {
                debugPrint('Document ${doc.id} is missing required fields');
                return null;
              }

              final category = data['category'] as String;
              // Normalize cleaning-related categories
              final normalizedCategory = category.toLowerCase();
              if (normalizedCategory == 'cleaning' ||
                  normalizedCategory == 'grooming') {
                data['category'] = 'Accessories';
              }

              return Product(
                id: doc.id,
                name: data['name'] ?? '',
                description: data['description'] ?? '',
                category: data['category'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                url: data['url'] ?? '',
              );
            })
            .where((product) => product != null)
            .cast<Product>()
            .toList();
      });
    } catch (e) {
      debugPrint('Error in _getProducts: $e');
      return Stream.value([]);
    }
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF32649B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: Color(0xFF32649B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Shop Now Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _launchURL(product.url),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF32649B),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Shop Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Handle the error gracefully
      debugPrint('Error launching URL: $e');
      // Optionally show a snackbar or dialog to inform the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the link')));
    }
  }

  // Update the search hint text to better reflect cleaning items
  String _getSearchHintText() {
    switch (_selectedCategory) {
      case 'doctor mask':
        return 'Search Medical Supplies...';
      case 'Toys':
        return 'Search Toys...';
      case 'Health':
        return 'Search Health Items...';
      case 'Accessories':
        return 'Search Accessories, Cleaning Tools...';
      default:
        return 'Search items...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SharedDrawer(),
      backgroundColor: const Color(
        0xFF32649B,
      ), // Background color for whole screen
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Container
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Search TextField
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white, // Light background for search bar
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: _getSearchHintText(),
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.only(left: 16),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.search, color: Color(0xFF32649B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
            // Rest of your content goes here
            _buildCategoryButtons(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pet Shop',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = ''; // Clear category filter
                        _searchQuery = ''; // Optional: clear search query too
                      });
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 99, 175, 255),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Replace the existing Row with GridView
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<List<Product>>(
                  stream: _getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data ?? [];
                    final filteredProducts = products.where((product) {
                      final matchesSearch = product.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                          product.description.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              );
                      final matchesCategory = _selectedCategory.isEmpty ||
                          product.category == _selectedCategory;
                      return matchesSearch && matchesCategory;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                        childAspectRatio: 0.7, // Adjust for card height
                        crossAxisSpacing: 12, // Horizontal space between cards
                        mainAxisSpacing: 12, // Vertical space between cards
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => _showProductDetails(product),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Image not available',
                                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: const Color(0xFF32649B),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      const Spacer(),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF32649B).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: TextButton.icon(
                                          onPressed: () => _launchURL(product.url),
                                          icon: const Icon(
                                            Icons.shopping_cart_outlined, 
                                            color: Color(0xFF32649B),
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Shop Now',
                                            style: TextStyle(
                                              color: Color(0xFF32649B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryButton('doctor mask', Icons.medical_services),
            const SizedBox(width: 12),
            _buildCategoryButton('Toys', Icons.sports_baseball_sharp),
            const SizedBox(width: 12),
            _buildCategoryButton('Health', Icons.health_and_safety),
            const SizedBox(width: 12),
            _buildCategoryButton('Accessories', Icons.handyman_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _selectedCategory = isSelected ? '' : category;
          _searchQuery = ''; // Clear search when category changes
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF32649B) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF32649B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: Icon(icon),
      label: Text(category),
    );
  }
}
