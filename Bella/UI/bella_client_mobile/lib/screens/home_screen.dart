import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_client_mobile/model/appointment.dart';
import 'package:bella_client_mobile/model/product.dart';
import 'package:bella_client_mobile/model/search_result.dart';
import 'package:bella_client_mobile/providers/appointment_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/providers/product_provider.dart';
import 'package:bella_client_mobile/providers/cart_provider.dart';
import 'package:bella_client_mobile/screens/history_appointments_details_screen.dart';
import 'package:bella_client_mobile/screens/product_details_screen.dart';
import 'package:bella_client_mobile/utils/base_picture_cover.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SearchResult<Appointment>? _appointments;
  List<Product> _recommendedProducts = [];
  bool _isLoading = false;
  bool _isLoadingRecommendations = false;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);
  static const Color orangeDark = Color(0xFFFF6B1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
      _loadRecommendedProducts();
    });
  }

  Future<void> _loadAppointments() async {
    final user = UserProvider.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      final filter = {
        'userId': user.id,
        'isActive': true,
        'appointmentDateFrom': DateTime.now(),
        'statusId': 1, // Only show Reserved appointments
        'page': 0,
        'pageSize': 1000,
        'includeTotalCount': false,
      };

      final result = await appointmentProvider.get(filter: filter);

      if (mounted) {
        // Filter appointments to only include future ones and sort by date
        final now = DateTime.now();
        final allAppointments = result.items ?? [];
        final upcomingAppointments = allAppointments
                .where((appointment) =>
                    appointment.appointmentDate.isAfter(now) ||
                    appointment.appointmentDate.isAtSameMomentAs(now))
                .toList();
        
        // Sort by appointment date (ascending)
        upcomingAppointments.sort((a, b) =>
            a.appointmentDate.compareTo(b.appointmentDate));

        setState(() {
          _appointments = SearchResult<Appointment>(
            items: upcomingAppointments,
            totalCount: upcomingAppointments.length,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Silently handle errors for home screen
      }
    }
  }

  Future<void> _loadRecommendedProducts() async {
    final user = UserProvider.currentUser;
    if (user == null) return;

    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final recommendations = await productProvider.getRecommendations(user.id);

      if (mounted) {
        setState(() {
          _recommendedProducts = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
        // Silently handle errors for recommendations
        print('Error loading recommendations: $e');
      }
    }
  }

  List<Appointment> get _upcomingAppointments {
    if (_appointments == null || _appointments!.items == null) {
      return [];
    }
    return _appointments!.items!;
  }

  Appointment? get _nextAppointment {
    if (_upcomingAppointments.isEmpty) return null;
    return _upcomingAppointments.first;
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProvider.currentUser;
    final userName = user?.firstName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _loadAppointments();
                await _loadRecommendedProducts();
              },
              color: orangePrimary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(userName),
                    const SizedBox(height: 24),

                    // Recommended Products Section
                    if (_recommendedProducts.isNotEmpty) ...[
                      _buildRecommendedProductsSection(),
                      const SizedBox(height: 24),
                    ],

                    // Next Appointment Section
                    if (_nextAppointment != null) ...[
                      _buildNextAppointmentSection(_nextAppointment!),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming Appointments Section
                    if (_upcomingAppointments.length > 1) ...[
                      _buildSectionHeader('Upcoming Appointments'),
                      const SizedBox(height: 16),
                      ...(_upcomingAppointments.skip(1).map(
                            (appointment) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildAppointmentCard(appointment),
                            ),
                          )),
                    ],

                    // Empty State
                    if (_upcomingAppointments.isEmpty) _buildEmptyState(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection(String userName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            orangePrimary,
            orangeDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: orangePrimary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAppointmentSection(Appointment appointment) {
    // Get service name and image
    String serviceName = '';
    String? serviceImage;
    IconData serviceIcon = Icons.content_cut_rounded;

    if (appointment.hairstyleName != null &&
        appointment.hairstyleName!.isNotEmpty) {
      serviceName = appointment.hairstyleName!;
      serviceImage = appointment.hairstyleImage;
      serviceIcon = Icons.content_cut_rounded;
    } else if (appointment.facialHairName != null &&
        appointment.facialHairName!.isNotEmpty) {
      serviceName = appointment.facialHairName!;
      serviceImage = appointment.facialHairImage;
      serviceIcon = Icons.face_rounded;
    } else if (appointment.dyingName != null &&
        appointment.dyingName!.isNotEmpty) {
      serviceName = appointment.dyingName!;
      serviceImage = null;
      serviceIcon = Icons.palette_rounded;
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;
    final difference = appointmentDate.difference(now);
    final daysUntil = difference.inDays;
    final hoursUntil = difference.inHours;
    final minutesUntil = difference.inMinutes;

    String timeUntilText = '';
    if (daysUntil > 0) {
      timeUntilText = '$daysUntil ${daysUntil == 1 ? 'day' : 'days'}';
    } else if (hoursUntil > 0) {
      timeUntilText = '$hoursUntil ${hoursUntil == 1 ? 'hour' : 'hours'}';
    } else if (minutesUntil > 0) {
      timeUntilText = '$minutesUntil ${minutesUntil == 1 ? 'minute' : 'minutes'}';
    } else {
      timeUntilText = 'Starting soon';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: orangePrimary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: orangePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: orangePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Next Appointment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timeUntilText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  // Cancel icon (only for reserved appointments)
                  if (appointment.statusId == 1) ...[
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showCancelConfirmation(appointment),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.cancel_outlined,
                            color: const Color(0xFFE53E3E),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HistoryAppointmentsDetailsScreen(appointment: appointment),
                ),
              ).then((_) {
                _loadAppointments();
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image
                BasePictureCover(
                  base64: serviceImage,
                  size: 100,
                  fallbackIcon: serviceIcon,
                  borderColor: orangePrimary.withOpacity(0.3),
                  iconColor: orangePrimary,
                  backgroundColor: orangePrimary.withOpacity(0.1),
                  isCircular: false,
                  borderRadius: 16,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName.isNotEmpty ? serviceName : 'Appointment',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              appointment.hairdresserName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('hh:mm a').format(appointment.appointmentDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${appointment.finalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: orangePrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistoryAppointmentsDetailsScreen(appointment: appointment),
                                ),
                              ).then((_) {
                                _loadAppointments();
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: orangePrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: orangePrimary,
                                  size: 20,
                                ),
                              ],
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: orangePrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    // Get service name and image
    String serviceName = '';
    String? serviceImage;
    IconData serviceIcon = Icons.content_cut_rounded;

    if (appointment.hairstyleName != null &&
        appointment.hairstyleName!.isNotEmpty) {
      serviceName = appointment.hairstyleName!;
      serviceImage = appointment.hairstyleImage;
      serviceIcon = Icons.content_cut_rounded;
    } else if (appointment.facialHairName != null &&
        appointment.facialHairName!.isNotEmpty) {
      serviceName = appointment.facialHairName!;
      serviceImage = appointment.facialHairImage;
      serviceIcon = Icons.face_rounded;
    } else if (appointment.dyingName != null &&
        appointment.dyingName!.isNotEmpty) {
      serviceName = appointment.dyingName!;
      serviceImage = null;
      serviceIcon = Icons.palette_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: orangePrimary.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HistoryAppointmentsDetailsScreen(appointment: appointment),
              ),
            ).then((_) {
              _loadAppointments();
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image
                BasePictureCover(
                  base64: serviceImage,
                  size: 70,
                  fallbackIcon: serviceIcon,
                  borderColor: orangePrimary.withOpacity(0.2),
                  iconColor: orangePrimary,
                  backgroundColor: orangePrimary.withOpacity(0.1),
                  isCircular: false,
                  borderRadius: 12,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName.isNotEmpty ? serviceName : 'Appointment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appointment.hairdresserName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a')
                                .format(appointment.appointmentDate),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${appointment.finalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: orangePrimary,
                            ),
                          ),
                          Row(
                            children: [
                              // Cancel button (only for reserved appointments)
                              if (appointment.statusId == 1)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showCancelConfirmation(appointment),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53E3E).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.cancel_outlined,
                                          color: Color(0xFFE53E3E),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: orangePrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 25,
              color: orangePrimary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Upcoming Appointments",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "You don't have any upcoming appointments.\nBook one now!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFE53E3E),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Cancel Appointment",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to cancel this appointment?",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(appointment.appointmentDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.hairdresserName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "No",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _cancelAppointment(appointment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    // Show loading indicator
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
        ),
      ),
    );

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      // Use cancel endpoint (which changes status to Cancelled)
      await appointmentProvider.cancelAppointment(appointment.id);

      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        _loadAppointments(); // Reload appointments

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text("Appointment cancelled successfully"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading indicator

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Failed to cancel appointment: $e"),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE53E3E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildRecommendedProductsSection() {
    if (_isLoadingRecommendations) {
      return Container(
        height: 280,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
          ),
        ),
      );
    }

    if (_recommendedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: orangePrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recommended For You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _recommendedProducts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildRecommendedProductCard(_recommendedProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedProductCard(Product product) {
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
        width: 180,
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
              flex: 1,
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
                            return _buildProductPlaceholderImage();
                          },
                        ),
                      )
                    : _buildProductPlaceholderImage(),
              ),
            ),
            // Product Info
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // <— makes column as small as possible

                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.manufacturerName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  Widget _buildProductPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.shopping_bag_rounded,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    final user = UserProvider.currentUser;
    if (user == null) {
      _showErrorDialog('Please log in to add items to cart');
      return;
    }

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Get or create cart, then add item
      await cartProvider.getOrCreateCart(user.id);
      await cartProvider.addItemToCart(user.id, product.id, 1);

      if (mounted) {
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
}
