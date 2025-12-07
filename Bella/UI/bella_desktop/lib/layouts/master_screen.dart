import 'package:bella_desktop/screens/manufacturer_list_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:bella_desktop/main.dart';
import 'package:bella_desktop/screens/city_list_screen.dart';
import 'package:bella_desktop/screens/review_list_screen.dart';
import 'package:bella_desktop/screens/users_list_screen.dart';
import 'package:bella_desktop/screens/product_category_list_screen.dart';
import 'package:bella_desktop/screens/analytics_screen.dart';
import 'package:bella_desktop/screens/appointment_list_screen.dart';
import 'package:bella_desktop/screens/order_list_screen.dart';
import 'package:bella_desktop/screens/product_list_screen.dart';
import 'package:bella_desktop/screens/hairstyle_list_screen.dart';
import 'package:bella_desktop/screens/facial_hair_list_screen.dart';
import 'package:bella_desktop/screens/dying_list_screen.dart';
import 'package:bella_desktop/providers/user_provider.dart';

// Orange color scheme constants
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);
const Color _yellowOrange = Color(0xFFFFA500);

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
  });
  final Widget child;
  final String title;
  final bool showBackButton;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  // Static variable to persist sidebar state across navigation
  static bool _persistedSidebarExpanded = true;
  
  bool _isSidebarExpanded = _persistedSidebarExpanded;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarWidthAnimation;

  // Orange color scheme (using top-level constants)

  @override
  void initState() {
    super.initState();
    // Restore persisted state
    _isSidebarExpanded = _persistedSidebarExpanded;
    
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _sidebarWidthAnimation = Tween<double>(begin: 80.0, end: 280.0).animate(
      CurvedAnimation(
        parent: _sidebarAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    
    // Set animation to match current state
    if (_isSidebarExpanded) {
      _sidebarAnimationController.value = 1.0;
    } else {
      _sidebarAnimationController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
      _persistedSidebarExpanded = _isSidebarExpanded; // Persist state
      if (_isSidebarExpanded) {
        _sidebarAnimationController.forward();
      } else {
        _sidebarAnimationController.reverse();
      }
    });
  }

  void _collapseSidebar() {
    if (_isSidebarExpanded) {
      setState(() {
        _isSidebarExpanded = false;
        _persistedSidebarExpanded = false; // Persist collapsed state
        _sidebarAnimationController.reverse();
      });
    }
  }

  Widget _buildUserAvatar() {
    final user = UserProvider.currentUser;
    final double radius = 20;
    ImageProvider? imageProvider;
    if (user?.picture != null && (user!.picture!.isNotEmpty)) {
      try {
        final sanitized = user.picture!.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: _orangePrimary,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Text(
                      _getUserInitials(user?.firstName, user?.lastName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user != null
                      ? '${user.firstName} ${user.lastName}'
                      : 'Guest',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  user?.username ?? 'User',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getUserInitials(String? firstName, String? lastName) {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    return (a + b).toUpperCase();
  }

  void _showProfileOverlay(BuildContext context) {
    final user = UserProvider.currentUser;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile',
      barrierColor: Colors.black54.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 8,
                right: 12,
              ),
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, -0.05),
                    end: Offset.zero,
                  ).animate(curved),
                  child: _ProfileOverlayCard(user: user),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Fixed Sidebar
          AnimatedBuilder(
            animation: _sidebarWidthAnimation,
            builder: (context, child) {
              return Container(
                width: _sidebarWidthAnimation.value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _orangeDark,
                      _orangePrimary,
                      _yellowOrange,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _orangePrimary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: _buildSidebarContent(),
              );
            },
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // AppBar
                _buildAppBar(context),
                // Body Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            Container(
              margin: const EdgeInsets.only(left: 16, right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF374151),
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  _buildSubheader(),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showProfileOverlay(context),
                  child: _buildUserAvatar(),
                ),
              ),
              const SizedBox(width: 12),
              // Logout button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _orangePrimary,
                          _orangeDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _orangePrimary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        _buildSidebarHeader(),
        Expanded(child: _buildFocusedNav(context)),
      ],
    );
  }

  Widget _buildSubheader() {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: _orangePrimary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Bella Administration Hub',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader() {
    return AnimatedBuilder(
      animation: _sidebarWidthAnimation,
      builder: (context, child) {
        // Calculate if we have enough space for expanded content
        // Show expanded content when width > 150px (about 35% through animation)
        final currentWidth = _sidebarWidthAnimation.value;
        final showExpandedContent = currentWidth > 150;
        final padding = showExpandedContent ? 12.0 : 10.0;
        
        return Container(
          padding: EdgeInsets.fromLTRB(
            padding,
            16,
            padding,
            16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: showExpandedContent
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo_small.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    SizedBox(width: currentWidth > 200 ? 12 : 4),
                    if (currentWidth > 200)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Bella Salon',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Admin Hub',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    if (currentWidth > 200) SizedBox(width: 8),
                    IconButton(
                      onPressed: _toggleSidebar,
                      icon: Icon(
                        _isSidebarExpanded
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: _isSidebarExpanded ? 'Collapse' : 'Expand',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/logo_small.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: _toggleSidebar,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: 'Expand',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFocusedNav(BuildContext context) {
    return AnimatedBuilder(
      animation: _sidebarWidthAnimation,
      builder: (context, child) {
        final currentWidth = _sidebarWidthAnimation.value;
        final showExpandedContent = currentWidth > 150;
        
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Analytics Section
            if (showExpandedContent) _buildSectionHeader('Analytics'),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.analytics_outlined,
              activeIcon: Icons.analytics,
              label: 'Business Insights',
              screen: const AnalyticsScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            
            // Wellness Section
            if (showExpandedContent) _buildSectionHeader('SALON SERVICES MANAGEMENT'),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
              label: 'Appointments',
              screen: const AppointmentListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            _modernDrawerTile(
              context,
              icon: Icons.content_cut_outlined,
              activeIcon: Icons.content_cut,
              label: 'Hairstyles',
              screen: const HairstyleListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            _modernDrawerTile(
              context,
              icon: Icons.face_outlined,
              activeIcon: Icons.face,
              label: 'Facial Hair',
              screen: const FacialHairListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            _modernDrawerTile(
              context,
              icon: Icons.palette_outlined,
              activeIcon: Icons.palette,
              label: 'Dye Colors',
              screen: const DyingListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),

            
            // Product Section
            if (showExpandedContent) _buildSectionHeader('PRODUCTS MANAGEMENT'),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.shopping_cart_outlined,
              activeIcon: Icons.shopping_cart,
              label: 'Orders',
              screen: const OrderListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            _modernDrawerTile(
              context,
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag,
              label: 'Products',
              screen: const ProductListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            _modernDrawerTile(
              context,
              icon: Icons.grid_view_outlined,
              activeIcon: Icons.grid_view,
              label: 'Categories',
              screen: const ProductCategoryListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            _modernDrawerTile(
              context,
              icon: Icons.factory_outlined,
              activeIcon: Icons.factory,
              label: 'Manufacturers',
              screen: const ManufacturerListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),

            // User Section
            if (showExpandedContent) _buildSectionHeader('USERS MANAGEMENT'),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.people_outlined,
              activeIcon: Icons.people_rounded,
              label: 'Users',
              screen: const UsersListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            
            // Reviews tile (no section header)
            _modernDrawerTile(
              context,
              icon: Icons.star_rate_outlined,
              activeIcon: Icons.star_rate,
              label: 'Reviews',
              screen: ReviewListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
            const SizedBox(height: 4),
            
            // Cities tile (no section header)
            _modernDrawerTile(
              context,
              icon: Icons.location_on_outlined,
              activeIcon: Icons.location_on_rounded ,
              label: 'Cities',
              screen: CityListScreen(),
              isSidebarExpanded: showExpandedContent,
              onCollapseSidebar: _collapseSidebar,
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    if (!_isSidebarExpanded) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

}

class _ProfileOverlayCard extends StatelessWidget {
  const _ProfileOverlayCard({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _orangePrimary,
                        _orangeDark,
                      ],
                    ),
                ),
                child: Row(
                  children: [
                    _ProfileAvatarLarge(user: user),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null
                                ? '${user.firstName} ${user.lastName}'
                                : 'Guest',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.username ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Administrator',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user?.email ?? '-',
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user?.phoneNumber ?? 'Not provided',
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Member since',
                      value: user?.createdAt != null
                          ? _formatDate(user!.createdAt)
                          : 'Unknown',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ProfileAvatarLarge extends StatelessWidget {
  const _ProfileAvatarLarge({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final double size = 70;
    ImageProvider? imageProvider;

    if (user?.picture != null && (user!.picture!.isNotEmpty)) {
      try {
        final sanitized = user.picture!.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageProvider != null
            ? Image(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  String get _initials {
    final f = (user?.firstName ?? '').trim();
    final l = (user?.lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    return (a + b).toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _orangePrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: _orangePrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _modernDrawerTile(
  BuildContext context, {
  required IconData icon,
  required IconData activeIcon,
  required String label,
  required Widget screen,
  required bool isSidebarExpanded,
  required VoidCallback onCollapseSidebar,
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final screenRoute = screen.runtimeType.toString();

  // Get the current screen type from the route
  bool isSelected = false;

  if (label == 'Cities') {
    isSelected =
        currentRoute == 'CityListScreen' ||
        currentRoute == 'CityDetailsScreen' ||
        currentRoute == 'CityEditScreen';
  } else if (label == 'Reviews') {
    isSelected =
        currentRoute == 'ReviewListScreen' ||
        currentRoute == 'ReviewDetailsScreen';
  } else if (label == 'Users') {
    isSelected =
        currentRoute == 'UsersListScreen' ||
        currentRoute == 'UsersDetailsScreen' ||
        currentRoute == 'UsersEditScreen';
  } else if (label == 'Product Categories') {
    isSelected =
        currentRoute == 'ProductCategoryListScreen' ||
        currentRoute == 'ProductCategoryDetailsScreen' ||
        currentRoute == 'ProductCategoryEditScreen';
  } else if (label == 'Brands') {
    isSelected =
        currentRoute == 'BrandListScreen' ||
        currentRoute == 'BrandDetailsScreen' ||
        currentRoute == 'BrandEditScreen';
  } else if (label == 'Wellness Services') {
    isSelected =
        currentRoute == 'WellnessServiceListScreen' ||
        currentRoute == 'WellnessServiceDetailsScreen' ||
        currentRoute == 'WellnessServiceEditScreen';
  } else if (label == 'Wellness Categories') {
    isSelected =
        currentRoute == 'WellnessServiceCategoryListScreen' ||
        currentRoute == 'WellnessServiceCategoryDetailsScreen' ||
        currentRoute == 'WellnessServiceCategoryEditScreen';
  } else if (label == 'Products') {
    isSelected =
        currentRoute == 'ProductListScreen' ||
        currentRoute == 'ProductDetailsScreen' ||
        currentRoute == 'ProductEditScreen';
  } else if (label == 'Orders') {
    isSelected =
        currentRoute == 'OrderListScreen' ||
        currentRoute == 'OrderDetailsScreen';
  } else if (label == 'Wellness Boxes') {
    isSelected =
        currentRoute == 'WellnessBoxListScreen' ||
        currentRoute == 'WellnessBoxDetailsScreen' ||
        currentRoute == 'WellnessBoxEditScreen';
  } else if (label == 'Gifts') {
    isSelected =
        currentRoute == 'GiftListScreen' ||
        currentRoute == 'GiftDetailsScreen';
  } else if (label == 'Appointments') {
    isSelected =
        currentRoute == 'AppointmentListScreen' ||
        currentRoute == 'AppointmentDetailsScreen';
  } else if (label == 'Hairstyles') {
    isSelected =
        currentRoute == 'HairstyleListScreen' ||
        currentRoute == 'HairstyleDetailsScreen' ||
        currentRoute == 'HairstyleEditScreen';
  } else if (label == 'Facial Hair') {
    isSelected =
        currentRoute == 'FacialHairListScreen' ||
        currentRoute == 'FacialHairDetailsScreen' ||
        currentRoute == 'FacialHairEditScreen';
  } else if (label == 'Dye Colors') {
    isSelected =
        currentRoute == 'DyingListScreen' ||
        currentRoute == 'DyingDetailsScreen' ||
        currentRoute == 'DyingEditScreen';
  } else if (label == 'Business Analytics') {
    isSelected = currentRoute == 'AnalyticsScreen';
  } else if (label == 'Categories') {
    isSelected =
        currentRoute == 'ProductCategoryListScreen' ||
        currentRoute == 'ProductCategoryDetailsScreen' ||
        currentRoute == 'ProductCategoryEditScreen';
  } else if (label == 'Manufacturers') {
    isSelected =
        currentRoute == 'ManufacturerListScreen' ||
        currentRoute == 'ManufacturerDetailsScreen' ||
        currentRoute == 'ManufacturerEditScreen';
  }

  return Container(
    margin: EdgeInsets.symmetric(
      vertical: 2,
      horizontal: isSidebarExpanded ? 8 : 4,
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate first
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
              settings: RouteSettings(name: screenRoute),
            ),
          );
          // Only collapse if sidebar was expanded - don't expand if collapsed
          if (isSidebarExpanded) {
            onCollapseSidebar();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isSidebarExpanded ? 14 : 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: isSidebarExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (isSidebarExpanded) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    ),
  );
}


void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: const Color(0xFFFF8C42)),
            SizedBox(width: 12),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C42),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
