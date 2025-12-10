import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bella_client_mobile/model/product.dart';
import 'package:bella_client_mobile/model/category.dart';
import 'package:bella_client_mobile/model/manufacturer.dart';
import 'package:bella_client_mobile/model/search_result.dart';
import 'package:bella_client_mobile/providers/product_provider.dart';
import 'package:bella_client_mobile/providers/category_provider.dart';
import 'package:bella_client_mobile/providers/manufacturer_provider.dart';
import 'package:bella_client_mobile/providers/cart_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/screens/product_details_screen.dart';
import 'package:bella_client_mobile/utils/base_dropdown.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController nameController = TextEditingController();
  Category? selectedCategory;
  Manufacturer? selectedManufacturer;

  SearchResult<Product>? products;
  List<Category> categories = [];
  List<Manufacturer> manufacturers = [];

  bool _isLoading = false;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadFilters();
      await _performSearch();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final manufacturerProvider = Provider.of<ManufacturerProvider>(context, listen: false);
      
      final categoriesResult = await categoryProvider.get(
        filter: {
          'isActive': true,
          'pageSize': 1000,
        },
      );
      final manufacturersResult = await manufacturerProvider.get(
        filter: {
          'isActive': true,
          'pageSize': 1000,
        },
      );

      if (mounted) {
        setState(() {
          categories = categoriesResult.items ?? [];
          manufacturers = manufacturersResult.items ?? [];
        });
        // Debug print to verify data is loaded
        print('Loaded ${categories.length} categories and ${manufacturers.length} manufacturers');
        if (categories.isEmpty) {
          print('WARNING: No categories loaded!');
        }
        if (manufacturers.isEmpty) {
          print('WARNING: No manufacturers loaded!');
        }
      }
    } catch (e) {
      print('Error loading filters: $e');
      if (mounted) {
        _showErrorDialog('Failed to load filters: $e');
      }
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final filter = {
        if (nameController.text.isNotEmpty) 'name': nameController.text,
        if (selectedCategory != null) 'categoryId': selectedCategory!.id,
        if (selectedManufacturer != null) 'manufacturerId': selectedManufacturer!.id,
        'isActive': true, // Only show active products
        'page': 0,
        'pageSize': 100,
        'includeTotalCount': true,
      };

      final result = await productProvider.get(filter: filter);
      if (mounted) {
        setState(() {
          products = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load products: $e');
      }
    }
  }

  Future<void> _addToCart(Product product) async {
    final user = UserProvider.currentUser;
    if (user == null) {
      _showErrorDialog('Please log in to add items to cart');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Get or create cart, then add item
      await cartProvider.getOrCreateCart(user.id);
      await cartProvider.addItemToCart(user.id, product.id, 1);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            backgroundColor: orangePrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to add to cart: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: orangePrimary,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Name filter
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Search by name',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: nameController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              nameController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: orangePrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),
                // Category filter
                BaseDropdown<Category>(
                  label: 'Category',
                  value: selectedCategory,
                  prefixIcon: Icons.category_rounded,
                  hintText: 'All Categories',
                  items: [
                    const DropdownMenuItem<Category>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                    _performSearch();
                  },
                ),
                const SizedBox(height: 12),
                // Manufacturer filter
                BaseDropdown<Manufacturer>(
                  label: 'Manufacturer',
                  value: selectedManufacturer,
                  prefixIcon: Icons.business_rounded,
                  hintText: 'All Manufacturers',
                  items: [
                    const DropdownMenuItem<Manufacturer>(
                      value: null,
                      child: Text('All Manufacturers'),
                    ),
                    ...manufacturers.map((manufacturer) {
                      return DropdownMenuItem<Manufacturer>(
                        value: manufacturer,
                        child: Text(manufacturer.name),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedManufacturer = value;
                    });
                    _performSearch();
                  },
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
                    ),
                  )
                : products == null || products!.items == null || products!.items!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products!.items!.length,
                        itemBuilder: (context, index) {
                          final product = products!.items![index];
                          return _buildProductCard(product);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: product.picture != null && product.picture!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.memory(
                          base64Decode(product.picture!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.manufacturerName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: orangePrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: orangePrimary,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _addToCart(product),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 30,
                              height: 30,
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.shopping_bag_rounded,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}

