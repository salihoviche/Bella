import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_client_mobile/model/appointment.dart';
import 'package:bella_client_mobile/model/review.dart';
import 'package:bella_client_mobile/providers/appointment_provider.dart';
import 'package:bella_client_mobile/providers/review_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/utils/base_picture_cover.dart';
import 'package:bella_client_mobile/screens/review_details_screen.dart';
import 'package:bella_client_mobile/layouts/master_screen.dart';

class ReviewSelectionScreen extends StatefulWidget {
  const ReviewSelectionScreen({super.key});

  @override
  State<ReviewSelectionScreen> createState() => _ReviewSelectionScreenState();
}

class _ReviewSelectionScreenState extends State<ReviewSelectionScreen> {
  List<Appointment> _appointments = [];
  List<Appointment> _unreviewedAppointments = [];
  bool _isLoading = true;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

      // Load appointments (filter by userId and statusId = 3 for Completed)
      final appointmentsResult = await appointmentProvider.get(
        filter: {
          'userId': UserProvider.currentUser!.id,
          'statusId': 3, // Only Completed appointments
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );

      // Load user's reviews to check which appointments they've already reviewed
      final userReviewsResult = await reviewProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
          'userId': UserProvider.currentUser!.id,
        },
      );

      if (mounted) {
        setState(() {
          final allAppointments = appointmentsResult.items ?? [];
          
          // Filter: Only show appointments that belong to the current user and are Completed (statusId = 3)
          _appointments = allAppointments
              .where((appointment) => 
                  appointment.userId == UserProvider.currentUser!.id &&
                  appointment.statusId == 3) // Only Completed appointments
              .toList();
          
          // Remove appointments that the user has already reviewed
          final reviewedAppointmentIds = (userReviewsResult.items ?? [])
              .map((r) => r.appointmentId)
              .toSet();
          
          _unreviewedAppointments = _appointments
              .where((appointment) => !reviewedAppointmentIds.contains(appointment.id))
              .toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load appointments: $e');
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

  Future<void> _createReviewForAppointment(Appointment appointment) async {
    // Double-check that this appointment doesn't already have a review from this user
    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      final existingReviews = await reviewProvider.get(
        filter: {
          'appointmentId': appointment.id,
          'userId': UserProvider.currentUser!.id,
          'page': 0,
          'pageSize': 1,
          'includeTotalCount': false,
        },
      );
      
      if (existingReviews.items != null && existingReviews.items!.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text("This appointment already has a review. Please edit the existing review instead."),
                  ),
                ],
              ),
              backgroundColor: orangePrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          // Reload data to refresh the list
          await _loadData();
        }
        return;
      }
    } catch (e) {
      // If check fails, proceed anyway - backend will validate
    }

    // Create a new review object for this appointment
    final newReview = Review(
      id: 0,
      rating: 0,
      comment: null,
      createdAt: DateTime.now(),
      userId: UserProvider.currentUser!.id,
      userName: UserProvider.currentUser!.username,
      userFullName: '${UserProvider.currentUser!.firstName} ${UserProvider.currentUser!.lastName}',
      hairdresserFullName: appointment.hairdresserName,
      appointmentId: appointment.id,
      appointment: ReviewAppointment(
        id: appointment.id,
        finalPrice: appointment.finalPrice,
        appointmentDate: appointment.appointmentDate,
        createdAt: appointment.createdAt,
        isActive: appointment.isActive,
        userId: appointment.userId,
        userName: appointment.userName,
        hairdresserId: appointment.hairdresserId,
        hairdresserName: appointment.hairdresserName,
        statusId: appointment.statusId,
        statusName: appointment.statusName,
        hairstyleId: appointment.hairstyleId,
        hairstyleName: appointment.hairstyleName,
        hairstylePrice: appointment.hairstylePrice,
        hairstyleImage: appointment.hairstyleImage,
        facialHairId: appointment.facialHairId,
        facialHairName: appointment.facialHairName,
        facialHairPrice: appointment.facialHairPrice,
        facialHairImage: appointment.facialHairImage,
        dyingId: appointment.dyingId,
        dyingName: appointment.dyingName,
        dyingHexCode: appointment.dyingHexCode,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailsScreen(review: newReview),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Select Appointment to Review',
      showBackButton: true,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
              ),
            )
          : _unreviewedAppointments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: orangePrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _unreviewedAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _unreviewedAppointments[index];
                      return _buildAppointmentCard(appointment);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: orangePrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: orangePrimary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "All Appointments Reviewed",
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
              "You've reviewed all your appointments or they aren't completed yet!",
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
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    // Get service name and image
    String serviceName = '';
    String? serviceImage;
    IconData serviceIcon = Icons.content_cut_rounded;
    
    if (appointment.hairstyleName != null && appointment.hairstyleName!.isNotEmpty) {
      serviceName = appointment.hairstyleName!;
      serviceImage = appointment.hairstyleImage;
      serviceIcon = Icons.content_cut_rounded;
    } else if (appointment.facialHairName != null && appointment.facialHairName!.isNotEmpty) {
      serviceName = appointment.facialHairName!;
      serviceImage = appointment.facialHairImage;
      serviceIcon = Icons.face_rounded;
    } else if (appointment.dyingName != null && appointment.dyingName!.isNotEmpty) {
      serviceName = appointment.dyingName!;
      serviceImage = null;
      serviceIcon = Icons.palette_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          onTap: () => _createReviewForAppointment(appointment),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image
                BasePictureCover(
                  base64: serviceImage,
                  size: 80,
                  fallbackIcon: serviceIcon,
                  borderColor: orangePrimary.withOpacity(0.2),
                  iconColor: orangePrimary,
                  backgroundColor: orangePrimary.withOpacity(0.1),
                  isCircular: false,
                  borderRadius: 12,
                ),
                const SizedBox(width: 16),
                // Service Details
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
                            DateFormat('MMM dd, yyyy • hh:mm a').format(appointment.appointmentDate),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: orangePrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rate_review_rounded,
                              size: 16,
                              color: orangePrimary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to Review',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: orangePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

