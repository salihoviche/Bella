import 'package:flutter/material.dart';
import 'package:bella_hairdresser_mobile/providers/user_provider.dart';
import 'package:bella_hairdresser_mobile/screens/profile_screen.dart';
import 'package:bella_hairdresser_mobile/screens/review_list_screen.dart';
import 'package:bella_hairdresser_mobile/screens/home_screen.dart';
import 'package:bella_hairdresser_mobile/screens/analytics_screen.dart';


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
  int _selectedIndex = 1; // Default to Home (center of 4 tabs)
  PageController? _pageController; // Nullable since it's only used when not in back button mode
  
  // Static reference to the current master screen instance
  static _MasterScreenState? _currentInstance;

  // Purple color scheme for hairdresser app (matching main.dart)
  static const Color purplePrimary = Color(0xFF8B5CF6); // Purple
  static const Color purpleDark = Color(0xFF6D28D9); // Dark purple


  @override
  void initState() {
    super.initState();
    if (!widget.showBackButton) {
      _pageController = PageController(initialPage: 1); // Start at Home (center)
    }
    _currentInstance = this; // Store reference to current instance
  }

  @override
  void dispose() {
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
      // Directly animate to home page (index 1)
      _currentInstance!._pageController!.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Also update the selected index
      _currentInstance!.setState(() {
        _currentInstance!._selectedIndex = 1;
      });
    }
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
                  color: purplePrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: purplePrimary,
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
                            purplePrimary,
                            purpleDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: purplePrimary.withOpacity(0.4),
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
          // Header with Purple Theme (dynamic height based on safe area)
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
                      purpleDark,
                      purplePrimary,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: purplePrimary.withOpacity(0.3),
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
                    child: _buildHeaderContent(),
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
                      // Analytics
                      const AnalyticsScreen(),
                      // Home
                      const HomeScreen(),
                      // Reviews
                      const ReviewListScreen(),
                      // Profile
                      const ProfileScreen(),
                    ],
                  ),
          ),

          // Bottom Navigation with Purple Theme (only show if not in back button mode)
          if (!widget.showBackButton)
            Container(
              height: 85,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    purpleDark,
                    purplePrimary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: purplePrimary.withOpacity(0.3),
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
                      // Analytics Tab (Left)
                      _buildNavigationItem(
                        index: 0,
                        icon: Icons.analytics_rounded,
                        label: 'Analytics',
                      ),
                      // Home Tab (Center - Special styling)
                      _buildHomeNavigationItem(),
                      // Reviews Tab (Right)
                      _buildNavigationItem(
                        index: 2,
                        icon: Icons.rate_review_rounded,
                        label: 'Reviews',
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

  Widget _buildHeaderContent() {
    if (widget.showBackButton) {
      // Back button mode
      return Row(
        
        children: [
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
        ],
      );
    } else {
      // Normal mode with greeting and buttons
      return Row(
        children: [
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
          const SizedBox(width: 8),
          _buildHeaderButton(
            icon: Icons.person_rounded,
            onPressed: () {
              _onItemTapped(3); // Navigate to profile tab
            },
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            icon: Icons.logout_rounded,
            onPressed: _handleLogout,
          ),
        ],
      );
    }
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
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
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
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
        constraints: const BoxConstraints(
          maxWidth: 100,
        ),
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
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
    final isSelected = _selectedIndex == 1;

    return GestureDetector(
      onTap: () => _onItemTapped(1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
            color: isSelected ? purplePrimary : Colors.grey[600],
            size: 32,
          ),
        ),
      ),
    );
  }
}