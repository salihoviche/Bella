import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/providers/cart_provider.dart';
import 'package:bella_client_mobile/model/cart.dart';
import 'package:bella_client_mobile/screens/profile_screen.dart';
import 'package:bella_client_mobile/screens/product_list_screen.dart';
import 'package:bella_client_mobile/screens/cart_screen.dart';
import 'package:bella_client_mobile/screens/review_list_screen.dart';
import 'package:bella_client_mobile/screens/appointment_screen.dart';
import 'package:bella_client_mobile/screens/history_screen.dart';
import 'package:bella_client_mobile/screens/home_screen.dart';


class CustomPageViewScrollPhysics extends ScrollPhysics {
  final int currentIndex;

  const CustomPageViewScrollPhysics({
    required this.currentIndex,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(
      currentIndex: currentIndex,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Prevent swiping from profile (index 2) to logout (index 3)
    if (currentIndex == 3 && value > position.pixels) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // Prevent swiping from profile (index 2) to logout (index 3)
    if (currentIndex == 2) {
      return false;
    }
    return super.shouldAcceptUserOffset(position);
  }
}

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });
  final Widget child;
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
  
  // Static method to navigate to home from anywhere
  static void navigateToHome() {
    _MasterScreenState.navigateToHomeTab();
  }
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 2; // Default to Home (center)
  PageController? _pageController; // Nullable since it's only used when not in back button mode
  Cart? _cart;
  CartProvider? _cartProvider; // Store reference to avoid context access in dispose
  
  // Static reference to the current master screen instance
  static _MasterScreenState? _currentInstance;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);
  static const Color orangeDark = Color(0xFFFF6B1A);


  @override
  void initState() {
    super.initState();
    if (!widget.showBackButton) {
      _pageController = PageController(initialPage: 2); // Start at Home
    }
    _currentInstance = this; // Store reference to current instance
    _loadCart();
    
    // Always listen to cart provider changes to update cart count in header
    if (mounted) {
      _cartProvider = Provider.of<CartProvider>(context, listen: false);
      _cartProvider?.addListener(_onCartChanged);
    }
  }

  void _onCartChanged() {
    // Reload cart when provider notifies
    if (mounted) {
      _loadCart();
    }
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
    if (_currentInstance == this) {
      _currentInstance = null; // Clear reference
    }
    _pageController?.dispose();
    super.dispose();
  }
  
  // Static method to navigate to home from anywhere (called via MasterScreen.navigateToHome())
  static void navigateToHomeTab() {
    if (_currentInstance != null && 
        _currentInstance!.mounted &&
        !_currentInstance!.widget.showBackButton &&
        _currentInstance!._pageController != null) {
      // Directly animate to home page (index 2)
      _currentInstance!._pageController!.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Also update the selected index
      _currentInstance!.setState(() {
        _currentInstance!._selectedIndex = 2;
      });
    }
  }

  Future<void> _loadCart() async {
    if (UserProvider.currentUser == null || !mounted) return;

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final cart = await cartProvider.getByUserId(UserProvider.currentUser!.id);
      
      if (mounted) {
        setState(() {
          _cart = cart;
        });
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    ).then((_) {
      // Reload cart when returning from cart screen
      _loadCart();
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    // Clear user data
    UserProvider.currentUser = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: orangePrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: orangePrimary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // Message
              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Logout Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          // Navigate back to login by popping all routes
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }


  @override
  Widget build(BuildContext context) {
    // Ensure current instance is always set when widget is built and updated
    if (!widget.showBackButton && _currentInstance != this) {
      _currentInstance = this;
    }
    
    return Scaffold(
      body: Column(
        children: [
          // Header with Orange Theme (dynamic height based on safe area)
          Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context);
              final topInset = mediaQuery.padding.top;
              // Content area needs minimum 71px (95 - typical 24px safe area)
              // Total header height = safe area inset + content area
              // This ensures enough space even on devices with large notches/cutouts
              const baseContentHeight = 71.0;
              final headerHeight = topInset + baseContentHeight;
              
              return Container(
                height: headerHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      orangeDark,
                      orangePrimary,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: orangePrimary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Back button (if enabled)
                        if (widget.showBackButton) ...[
                          _buildHeaderButton(
                            icon: Icons.arrow_back_rounded,
                            onPressed: () {
                              if (widget.onBackPressed != null) {
                                widget.onBackPressed!();
                              } else if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Greeting with user's first name (if back button not shown)
                        if (!widget.showBackButton)
                          Expanded(
                            child: Text(
                              'Hi ${UserProvider.currentUser?.firstName ?? 'User'}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        if (widget.showBackButton)
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Profile Button (only if not showing back button)
                        if (!widget.showBackButton) ...[
                          _buildHeaderButton(
                            icon: Icons.person_rounded,
                            onPressed: () {
                              _onItemTapped(5); // Navigate to profile tab
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Cart Button with Badge (hide when on cart screen)
                        if (!widget.showBackButton)
                          _buildCartButtonHeader(_cart?.totalItems ?? 0),
                        if (!widget.showBackButton) ...[
                          const SizedBox(width: 8),
                          // Logout Button
                          _buildHeaderButton(
                            icon: Icons.logout_rounded,
                            onPressed: _handleLogout,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Page Content
          Expanded(
            child: widget.showBackButton
                ? widget.child
                : PageView(
                    controller: _pageController!,
                    onPageChanged: (index) {
                      _onPageChanged(index);
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Appointments
                      const AppointmentScreen(),
                      // Products
                      const ProductListScreen(),
                      // Home
                      const HomeScreen(),
                      // Reviews
                      const ReviewListScreen(),
                      // History
                      const HistoryScreen(),
                      // Profile
                      const ProfileScreen(),
                    ],
                  ),
          ),

          // Bottom Navigation with Orange Theme (only show if not in back button mode)
          if (!widget.showBackButton)
            Container(
              height: 85,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    orangeDark,
                    orangePrimary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: orangePrimary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Appointments Tab
                      Expanded(
                        child: _buildNavigationItem(
                          index: 0,
                          icon: Icons.calendar_today_rounded,
                          label: 'Appointments',
                        ),
                      ),
                      // Products Tab
                      Expanded(
                        child: _buildNavigationItem(
                          index: 1,
                          icon: Icons.shopping_bag_rounded,
                          label: 'Products',
                        ),
                      ),
                      // Home Tab (Center - Special styling)
                      _buildHomeNavigationItem(),
                      // Reviews Tab
                      Expanded(
                        child: _buildNavigationItem(
                          index: 3,
                          icon: Icons.rate_review_rounded,
                          label: 'Reviews',
                        ),
                      ),
                      // History Tab
                      Expanded(
                        child: _buildNavigationItem(
                          index: 4,
                          icon: Icons.shopping_cart_rounded,
                          label: 'History',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

 

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }

  Widget _buildCartButtonHeader(int itemCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: _navigateToCart,
            icon: const Icon(
              Icons.shopping_cart_rounded,
              color: Colors.white,
              size: 22,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            tooltip: 'Cart',
          ),
        ),
        if (itemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFE53E3E),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeNavigationItem() {
    final isSelected = _selectedIndex == 2;

    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.home_rounded,
            color: isSelected ? orangePrimary : Colors.grey[600],
            size: 32,
          ),
        ),
      ),
    );
  }
}
