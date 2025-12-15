import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_hairdresser_mobile/model/appointment.dart';
import 'package:bella_hairdresser_mobile/model/search_result.dart';
import 'package:bella_hairdresser_mobile/providers/appointment_provider.dart';
import 'package:bella_hairdresser_mobile/providers/user_provider.dart';
import 'package:bella_hairdresser_mobile/screens/appointments_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SearchResult<Appointment>? _appointments;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  // Purple color scheme for hairdresser app
  static const Color purplePrimary = Color(0xFF8B5CF6); // Purple
  static const Color purpleDark = Color(0xFF6D28D9); // Dark purple

  // Available time slots
  static const List<int> _availableTimeSlots = [7, 8, 9, 10, 11, 12, 13, 14];

  // Status IDs: 1 = Reserved, 2 = Cancelled, 3 = Completed
  static const int statusReserved = 1;
  static const int statusCancelled = 2;
  static const int statusCompleted = 3;

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

      // Load appointments for the selected date (all statuses)
      final startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        0,
        0,
        0,
      );
      final endOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        23,
        59,
        59,
      );

      final filter = {
        'hairdresserId': user.id,
        'isActive': true,
        // Remove statusId filter to get all appointments
        'appointmentDateFrom': startOfDay,
        'appointmentDateTo': endOfDay,
        'page': 0,
        'pageSize': 1000,
        'includeTotalCount': false,
      };

      final result = await appointmentProvider.get(filter: filter);

      if (mounted) {
        final allAppointments = result.items ?? [];
        
        // Filter appointments to only include specific time slots
        final filteredAppointments = allAppointments
            .where((appointment) {
              // Only specific time slots
              final hour = appointment.appointmentDate.hour;
              return _availableTimeSlots.contains(hour);
            })
            .toList();

        // Sort by appointment date (ascending)
        filteredAppointments.sort((a, b) =>
            a.appointmentDate.compareTo(b.appointmentDate));

        setState(() {
          _appointments = SearchResult<Appointment>(
            items: filteredAppointments,
            totalCount: filteredAppointments.length,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<int, Appointment?> _getAppointmentsByHour() {
    final appointmentsByHour = <int, Appointment?>{};
    
    // Initialize all time slots as empty
    for (var hour in _availableTimeSlots) {
      appointmentsByHour[hour] = null;
    }

    // Group appointments by hour
    final appointmentsByHourList = <int, List<Appointment>>{};
    
    if (_appointments?.items != null) {
      for (var appointment in _appointments!.items!) {
        final hour = appointment.appointmentDate.hour;
        if (_availableTimeSlots.contains(hour)) {
          appointmentsByHourList.putIfAbsent(hour, () => []).add(appointment);
        }
      }
    }

    // For each hour, select the highest priority appointment
    // Priority: Reserved (1) > Completed (3) > Cancelled (2)
    appointmentsByHourList.forEach((hour, appointments) {
      if (appointments.isEmpty) {
        appointmentsByHour[hour] = null;
      } else if (appointments.length == 1) {
        appointmentsByHour[hour] = appointments.first;
      } else {
        // Multiple appointments - prioritize by status
        Appointment? selectedAppointment;
        
        // Check for Reserved first
        final reserved = appointments.where((a) => a.statusId == statusReserved).toList();
        if (reserved.isNotEmpty) {
          selectedAppointment = reserved.first;
        } else {
          // Check for Completed
          final completed = appointments.where((a) => a.statusId == statusCompleted).toList();
          if (completed.isNotEmpty) {
            selectedAppointment = completed.first;
          } else {
            // Fall back to first cancelled
            selectedAppointment = appointments.first;
          }
        }
        
        appointmentsByHour[hour] = selectedAppointment;
      }
    });

    return appointmentsByHour;
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day - 1,
      );
    });
    _loadAppointments();
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + 1,
      );
    });
    _loadAppointments();
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _selectedDate = DateTime(today.year, today.month, today.day);
    });
    _loadAppointments();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsByHour = _getAppointmentsByHour();
    final isToday = _isToday(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        color: purplePrimary,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(purplePrimary),
                ),
              )
            : _buildDayView(_selectedDate, appointmentsByHour, isToday),
      ),
    );
  }

  Widget _buildDayView(
    DateTime date,
    Map<int, Appointment?> appointmentsByHour,
    bool isToday,
  ) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Navigation Header
          _buildDateNavigationHeader(date, dateFormat, isToday),
          const SizedBox(height: 20),
          
          // Time Slots
          ..._buildAllTimeSlots(appointmentsByHour),
        ],
      ),
    );
  }

  Widget _buildDateNavigationHeader(
    DateTime date,
    DateFormat dateFormat,
    bool isToday,
  ) {
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: purplePrimary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Display - Use Flexible to prevent overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isToday ? Icons.today_rounded : Icons.calendar_today_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  isToday
                      ? 'Today - ${dateFormat.format(date)}'
                      : dateFormat.format(date),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Day Button
              _buildNavButton(
                icon: Icons.chevron_left_rounded,
                onPressed: _goToPreviousDay,
              ),
              
              // Today Button (if not today) - Use Expanded/Flexible
              if (!isToday)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildTodayButton(),
                  ),
                )
              else
                const Spacer(),
              
              // Next Day Button
              _buildNavButton(
                icon: Icons.chevron_right_rounded,
                onPressed: _goToNextDay,
                isNext: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isNext = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTodayButton() {
    return GestureDetector(
      onTap: _goToToday,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Text(
          'Today',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> _buildAllTimeSlots(Map<int, Appointment?> appointmentsByHour) {
    final widgets = <Widget>[];

    for (var hour in _availableTimeSlots) {
      final appointment = appointmentsByHour[hour];
      widgets.add(
        appointment != null
            ? _buildAppointmentCard(appointment)
            : _buildEmptySlotCard(hour),
      );
      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  Widget _buildEmptySlotCard(int hour) {
    final timeFormat = DateFormat('HH:mm');
    final timeSlot = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          // Time Slot
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeFormat.format(timeSlot),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Empty Slot Info
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  'Available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final timeFormat = DateFormat('HH:mm');
    final serviceName = _getServiceName(appointment);
    final serviceIcon = _getServiceIcon(appointment);
    final statusColor = _getStatusColor(appointment.statusId);
    final isReserved = appointment.statusId == statusReserved;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentsDetailsScreen(
              appointment: appointment,
            ),
          ),
        ).then((_) {
          _loadAppointments();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Time Slot
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeFormat.format(appointment.appointmentDate),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Appointment Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            serviceIcon,
                            size: 18,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              serviceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
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
                            Icons.person_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              appointment.userName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
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
                            Icons.attach_money_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '\$${appointment.finalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                                width: 1,
                              ),
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
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
            
            // Complete Button (only for reserved appointments)
            if (isReserved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteConfirmation(context, appointment),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text('Complete Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case statusReserved:
        return Colors.blue;
      case statusCompleted:
        return Colors.green;
      case statusCancelled:
        return Colors.red;
      default:
        return purplePrimary;
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

  IconData _getServiceIcon(Appointment appointment) {
    if (appointment.hairstyleName != null &&
        appointment.hairstyleName!.isNotEmpty) {
      return Icons.content_cut_rounded;
    }
    if (appointment.facialHairName != null &&
        appointment.facialHairName!.isNotEmpty) {
      return Icons.face_rounded;
    }
    if (appointment.dyingName != null && appointment.dyingName!.isNotEmpty) {
      return Icons.palette_rounded;
    }
    return Icons.calendar_today_rounded;
  }

  Future<void> _showCompleteConfirmation(
    BuildContext context,
    Appointment appointment,
  ) async {
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
                    'Customer: ${appointment.userName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Service: ${_getServiceName(appointment)}',
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

    if (confirmed == true) {
      await _completeAppointment(appointment);
    }
  }

  Future<void> _completeAppointment(Appointment appointment) async {
    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      
      // Show loading
      if (!mounted) return;
      
      await appointmentProvider.completeAppointment(appointment.id);
      
      // Show success message
      if (!mounted) return;
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
      
      // Refresh appointments
      _loadAppointments();
    } catch (e) {
      if (!mounted) return;
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