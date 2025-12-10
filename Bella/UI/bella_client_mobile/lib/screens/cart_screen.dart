import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bella_client_mobile/model/cart.dart';
import 'package:bella_client_mobile/model/cart_item.dart';
import 'package:bella_client_mobile/providers/cart_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/layouts/master_screen.dart';
import 'package:bella_client_mobile/screens/payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Cart? _cart;
  bool _isLoading = false;
  CartProvider? _cartProvider; // Store reference to avoid context access in dispose

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);
  static const Color orangeDark = Color(0xFFFF6B1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCart();
        // Listen to cart provider changes
        _cartProvider = Provider.of<CartProvider>(context, listen: false);
        _cartProvider?.addListener(_onCartChanged);
      }
    });
  }

  @override
  void dispose() {
    // Only remove listener if we added one and provider still exists
    if (_cartProvider != null && mounted) {
      try {
        _cartProvider?.removeListener(_onCartChanged);
      } catch (e) {
        // Ignore errors if widget is already deactivated
      }
    }
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      _loadCart();
    }
  }

  Future<void> _loadCart() async {
    final user = UserProvider.currentUser;
    if (user == null || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final cart = await cartProvider.getByUserId(user.id);

      if (mounted) {
        setState(() {
          _cart = cart;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load cart: $e');
      }
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) {
      _removeItem(item);
      return;
    }

    final user = UserProvider.currentUser;
    if (user == null) {
      _showErrorDialog('Please log in to update cart');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.updateItemQuantity(user.id, item.productId, newQuantity);

      if (mounted) {
        await _loadCart();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to update quantity: $e');
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    final user = UserProvider.currentUser;
    if (user == null) {
      _showErrorDialog('Please log in to remove items');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.removeItemFromCart(user.id, item.productId);

      if (mounted) {
        await _loadCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productName} removed from cart'),
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
        _showErrorDialog('Failed to remove item: $e');
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
    return MasterScreen(
      title: 'Shopping Cart',
      showBackButton: true,
      child: _isLoading && _cart == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
              ),
            )
          : _cart == null || _cart!.cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartContent(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cart!.cartItems.length,
            itemBuilder: (context, index) {
              final item = _cart!.cartItems[index];
              return _buildCartItemCard(item);
            },
          ),
        ),

        // Bottom Summary and Checkout
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Items:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '${_cart!.totalItems}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '\$${_cart!.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: orangePrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Proceed to Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            orangePrimary,
                            orangeDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: orangePrimary.withOpacity(0.4),
                            spreadRadius: 0,
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading || _cart == null || _cart!.cartItems.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(cart: _cart!),
                                  ),
                                ).then((_) {
                                  // Reload cart when returning from payment screen
                                  _loadCart();
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment_rounded, size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Proceed to Checkout",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          const SizedBox(width: 10),
          Container(
            width: 100,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: item.productPicture != null && item.productPicture!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.memory(
                      base64Decode(item.productPicture!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    ),
                  )
                : _buildPlaceholderImage(),
          ),

          // Product Info and Controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Price per unit
                  Text(
                    '\$${item.productPrice.toStringAsFixed(2)} each',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quantity Controls and Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Controls
                     Container(
  decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(6), // smaller radius
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Decrease
      IconButton(
        onPressed: _isLoading
            ? null
            : () => _updateQuantity(item, item.quantity - 1),
        icon: const Icon(Icons.remove_rounded, size: 18), // smaller icon
        color: Colors.grey[700],
        padding: const EdgeInsets.all(2), // smaller padding
        constraints: const BoxConstraints(
          minWidth: 26, // smaller hitbox
          minHeight: 26,
        ),
      ),

      // Quantity text
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 2), // smaller spacing
        child: Text(
          '${item.quantity}',
          style: const TextStyle(
            fontSize: 14, // slightly smaller font
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ),

      // Increase
      IconButton(
        onPressed: _isLoading
            ? null
            : () => _updateQuantity(item, item.quantity + 1),
        icon: const Icon(Icons.add_rounded, size: 18), // smaller icon
        color: orangePrimary,
        padding: const EdgeInsets.all(2),
        constraints: const BoxConstraints(
          minWidth: 26,
          minHeight: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Total Price
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: orangePrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Remove Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _isLoading
                  ? null
                  : () => _removeItem(item),
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red[400],
              tooltip: 'Remove item',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.shopping_bag_rounded,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}

