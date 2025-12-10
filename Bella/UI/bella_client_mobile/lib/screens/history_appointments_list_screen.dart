import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_client_mobile/model/appointment.dart';
import 'package:bella_client_mobile/model/search_result.dart';
import 'package:bella_client_mobile/providers/appointment_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/screens/history_appointments_details_screen.dart';
import 'package:bella_client_mobile/utils/base_picture_cover.dart';

class HistoryAppointmentsListScreen extends StatefulWidget {
  const HistoryAppointmentsListScreen({super.key});

  @override
  State<HistoryAppointmentsListScreen> createState() =>
      _HistoryAppointmentsListScreenState();
}

class _HistoryAppointmentsListScreenState
    extends State<HistoryAppointmentsListScreen> {
  SearchResult<Appointment>? _appointments;
  bool _isLoading = false;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
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
        'page': 0,
        'pageSize': 1000,
        'includeTotalCount': false,
      };

      final result = await appointmentProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _appointments = result;
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

  Color _getStatusColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'reserved':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
            ),
          )
        : _appointments == null || _appointments!.items == null || _appointments!.items!.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _loadAppointments,
                color: orangePrimary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments!.items!.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments!.items![index];
                    return _buildAppointmentCard(appointment);
                  },
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
                Icons.calendar_today_outlined,
                size: 64,
                color: orangePrimary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Appointments Yet",
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
              "Your appointment history will appear here",
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

    final statusColor = _getStatusColor(appointment.statusName);

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HistoryAppointmentsDetailsScreen(appointment: appointment),
              ),
            ).then((_) {
              _loadAppointments(); // Reload after returning
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
                  size: 80,
                  fallbackIcon: serviceIcon,
                  borderColor: orangePrimary.withOpacity(0.2),
                  iconColor: orangePrimary,
                  backgroundColor: orangePrimary.withOpacity(0.1),
                  isCircular: false,
                  borderRadius: 12,
                ),
                const SizedBox(width: 16),
                // Appointment Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              serviceName.isNotEmpty
                                  ? serviceName
                                  : 'Appointment',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              appointment.statusName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
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
                          const Row(
                            children: [
                              Icon(
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
}

