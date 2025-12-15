import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_hairdresser_mobile/model/appointment.dart';
import 'package:bella_hairdresser_mobile/layouts/master_screen.dart';
import 'package:bella_hairdresser_mobile/providers/appointment_provider.dart';

class AppointmentsDetailsScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentsDetailsScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentsDetailsScreen> createState() => _AppointmentsDetailsScreenState();
}

class _AppointmentsDetailsScreenState extends State<AppointmentsDetailsScreen> {
  late Appointment _currentAppointment;
  bool _isCompleting = false;

  // Purple color scheme for hairdresser app
  static const Color purplePrimary = Color(0xFF8B5CF6); // Purple
  static const Color purpleDark = Color(0xFF6D28D9); // Dark purple

  // Status IDs: 1 = Reserved, 2 = Cancelled, 3 = Completed
  static const int statusReserved = 1;

  @override
  void initState() {
    super.initState();
    _currentAppointment = widget.appointment;
  }

  Future<void> _completeAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete Appointment',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to mark this appointment as completed?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer: ${_currentAppointment.userName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Service: ${_getServiceName(_currentAppointment)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      final updatedAppointment = await appointmentProvider.completeAppointment(_currentAppointment.id);

      if (mounted) {
        setState(() {
          _currentAppointment = updatedAppointment;
          _isCompleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Appointment completed successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to complete appointment: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  String _getServiceName(Appointment appointment) {
    if (appointment.hairstyleName != null &&
        appointment.hairstyleName!.isNotEmpty) {
      return appointment.hairstyleName!;
    }
    if (appointment.facialHairName != null &&
        appointment.facialHairName!.isNotEmpty) {
      return appointment.facialHairName!;
    }
    if (appointment.dyingName != null && appointment.dyingName!.isNotEmpty) {
      return appointment.dyingName!;
    }
    return 'Appointment';
  }

  @override
  Widget build(BuildContext context) {
    final isReserved = _currentAppointment.statusId == statusReserved;

    return MasterScreen(
      title: 'Appointment',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Date & Time Card
            _buildDateTimeCard(),
            const SizedBox(height: 20),

            // Customer Information Card
            _buildCustomerCard(),
            const SizedBox(height: 20),

            // Services Card
            _buildServicesCard(),
            const SizedBox(height: 20),

            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Price Card
            _buildPriceCard(),
            const SizedBox(height: 20),

            // Complete Button (only for reserved appointments)
            if (isReserved) _buildCompleteButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCompleting ? null : _completeAppointment,
        icon: _isCompleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.check_circle_rounded, size: 24),
        label: Text(
          _isCompleting ? 'Completing...' : 'Complete Appointment',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: purplePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: purplePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Date & Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.date_range_rounded,
                  label: 'Date',
                  value: DateFormat('EEEE, MMMM d, yyyy').format(_currentAppointment.appointmentDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: DateFormat('HH:mm').format(_currentAppointment.appointmentDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: purplePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: purplePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.badge_rounded,
                  label: 'Customer Name',
                  value: _currentAppointment.userName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard() {
    final services = <Widget>[];

    if (_currentAppointment.hairstyleName != null &&
        _currentAppointment.hairstyleName!.isNotEmpty) {
      services.add(_buildServiceItem(
        icon: Icons.content_cut_rounded,
        name: _currentAppointment.hairstyleName!,
        price: _currentAppointment.hairstylePrice ?? 0.0,
        image: _currentAppointment.hairstyleImage,
      ));
    }

    if (_currentAppointment.facialHairName != null &&
        _currentAppointment.facialHairName!.isNotEmpty) {
      services.add(_buildServiceItem(
        icon: Icons.face_rounded,
        name: _currentAppointment.facialHairName!,
        price: _currentAppointment.facialHairPrice ?? 0.0,
        image: _currentAppointment.facialHairImage,
      ));
    }

    if (_currentAppointment.dyingName != null && _currentAppointment.dyingName!.isNotEmpty) {
      services.add(_buildServiceItem(
        icon: Icons.palette_rounded,
        name: _currentAppointment.dyingName!,
        price: 10.0, // Dying is always $10
        hexCode: _currentAppointment.dyingHexCode,
      ));
    }

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: purplePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: purplePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...services.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: service,
              )),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String name,
    required double price,
    String? image,
    String? hexCode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Service Image or Icon
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                base64Decode(image),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildServiceIconPlaceholder(icon, hexCode);
                },
              ),
            )
          else if (hexCode != null && hexCode.isNotEmpty)
            _buildDyingColorIndicator(hexCode)
          else
            _buildServiceIconPlaceholder(icon, null),
          const SizedBox(width: 16),
          
          // Service Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: purplePrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIconPlaceholder(IconData icon, String? hexCode) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: hexCode != null && hexCode.isNotEmpty
            ? _hexToColor(hexCode)
            : purplePrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: hexCode != null && hexCode.isNotEmpty
            ? Colors.white
            : purplePrimary,
        size: 30,
      ),
    );
  }

  Widget _buildDyingColorIndicator(String hexCode) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _hexToColor(hexCode),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
    );
  }

  Color _hexToColor(String hexCode) {
    final hex = hexCode.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.grey;
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    
    switch (_currentAppointment.statusId) {
      case 1: // Reserved
        statusColor = Colors.blue;
        statusIcon = Icons.event_available_rounded;
        break;
      case 2: // Cancelled
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      case 3: // Completed
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _currentAppointment.statusName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            purpleDark,
            purplePrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: purplePrimary.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Price',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '\$${_currentAppointment.finalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}