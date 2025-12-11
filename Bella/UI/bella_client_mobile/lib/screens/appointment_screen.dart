import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_client_mobile/model/appointment.dart';
import 'package:bella_client_mobile/model/user.dart';
import 'package:bella_client_mobile/model/hairstyle.dart';
import 'package:bella_client_mobile/model/facial_hair.dart';
import 'package:bella_client_mobile/model/dying.dart';
import 'package:bella_client_mobile/providers/appointment_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/providers/hairstyle_provider.dart';
import 'package:bella_client_mobile/providers/facial_hair_provider.dart';
import 'package:bella_client_mobile/providers/dying_provider.dart';
import 'package:bella_client_mobile/providers/length_provider.dart';
import 'package:bella_client_mobile/model/length.dart';
import 'package:bella_client_mobile/utils/base_picture_cover.dart';
import 'package:bella_client_mobile/utils/base_dropdown.dart';
import 'package:bella_client_mobile/screens/appointment_checkout_screen.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);
  static const Color orangeDark = Color(0xFFFF6B1A);

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  User? _selectedHairdresser;
  Length? _selectedLength;
  Hairstyle? _selectedHairstyle;
  FacialHair? _selectedFacialHair;
  Dying? _selectedDying;

  // Toggle switches for service sections (all off by default)
  bool _showHairstyle = false;
  bool _showFacialHair = false;
  bool _showDying = false;

  List<User> _hairdressers = [];
  List<Length> _lengths = [];
  List<Hairstyle> _hairstyles = [];
  List<Hairstyle> _filteredHairstyles = [];
  List<FacialHair> _facialHairs = [];
  List<Dying> _dyings = [];
  List<Appointment> _existingAppointments = [];
  
  // PageControllers for carousels
  final PageController _hairstylePageController = PageController();
  final PageController _facialHairPageController = PageController();
  final PageController _dyingPageController = PageController();

  bool _isLoading = false;
  bool _isLoadingAppointments = false;

  // Time slots: Only specific times
  final List<TimeOfDay> _timeSlots = [
    const TimeOfDay(hour: 7, minute: 0),   // 7:00
    const TimeOfDay(hour: 8, minute: 0),   // 8:00
    const TimeOfDay(hour: 9, minute: 0),   // 9:00
    const TimeOfDay(hour: 10, minute: 0),  // 10:00
    const TimeOfDay(hour: 11, minute: 0),  // 11:00
    const TimeOfDay(hour: 12, minute: 0),  // 12:00
    const TimeOfDay(hour: 13, minute: 0),  // 13:00
    const TimeOfDay(hour: 14, minute: 0),  // 14:00
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadHairdressers(),
        _loadLengths(),
        _loadHairstyles(),
        _loadFacialHairs(),
        _loadDyings(),
      ]);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to load data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadHairdressers() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.get(
        filter: {
          'roleId': 3, // Hairdresser role
          'isActive': true,
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      if (mounted) {
        setState(() {
          _hairdressers = result.items ?? [];
        });
      }
    } catch (e) {
      print('Error loading hairdressers: $e');
    }
  }

  Future<void> _loadLengths() async {
    try {
      final lengthProvider = Provider.of<LengthProvider>(context, listen: false);
      final result = await lengthProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      if (mounted) {
        setState(() {
          _lengths = result.items ?? [];
        });
      }
    } catch (e) {
      print('Error loading lengths: $e');
    }
  }

  Future<void> _loadHairstyles() async {
    try {
      final hairstyleProvider = Provider.of<HairstyleProvider>(context, listen: false);
      final currentUser = UserProvider.currentUser;
      
      if (currentUser == null) return;
      
      final result = await hairstyleProvider.get(
        filter: {
          'isActive': true,
          'genderId': currentUser.genderId, // Filter by user's gender
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      if (mounted) {
        setState(() {
          _hairstyles = result.items ?? [];
          _filterHairstyles();
        });
      }
    } catch (e) {
      print('Error loading hairstyles: $e');
    }
  }
  
  void _filterHairstyles() {
    if (_selectedLength == null) {
      setState(() {
        _filteredHairstyles = [];
        _selectedHairstyle = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hairstylePageController.hasClients) {
          _hairstylePageController.jumpToPage(0);
        }
      });
      return;
    }
    
    setState(() {
      _filteredHairstyles = _hairstyles
          .where((hs) => hs.lengthId == _selectedLength!.id)
          .toList();
      
      // Reset selection if current selection doesn't match filter
      if (_selectedHairstyle != null) {
        final index = _filteredHairstyles.indexWhere(
          (hs) => hs.id == _selectedHairstyle!.id,
        );
        if (index < 0) {
          _selectedHairstyle = null;
        }
      }
      
      // Reset page controller to first page or to selected item
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hairstylePageController.hasClients && _filteredHairstyles.isNotEmpty) {
          if (_selectedHairstyle != null) {
            final index = _filteredHairstyles.indexWhere(
              (hs) => hs.id == _selectedHairstyle!.id,
            );
            if (index >= 0) {
              _hairstylePageController.jumpToPage(index);
              return;
            }
          }
          _hairstylePageController.jumpToPage(0);
        }
      });
    });
  }

  Future<void> _loadFacialHairs() async {
    try {
      final facialHairProvider = Provider.of<FacialHairProvider>(context, listen: false);
      final result = await facialHairProvider.get(
        filter: {
          'isActive': true,
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      if (mounted) {
        setState(() {
          _facialHairs = result.items ?? [];
        });
      }
    } catch (e) {
      print('Error loading facial hairs: $e');
    }
  }

  Future<void> _loadDyings() async {
    try {
      final dyingProvider = Provider.of<DyingProvider>(context, listen: false);
      final result = await dyingProvider.get(
        filter: {
          'isActive': true,
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      if (mounted) {
        setState(() {
          _dyings = result.items ?? [];
        });
      }
    } catch (e) {
      print('Error loading dyings: $e');
    }
  }

  Future<void> _loadExistingAppointments() async {
    if (_selectedDate == null || _selectedHairdresser == null) {
      setState(() {
        _existingAppointments = [];
      });
      return;
    }

    setState(() {
      _isLoadingAppointments = true;
    });

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      // Get start and end of selected date
      final startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 0, 0);
      final endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59);

      final result = await appointmentProvider.get(
        filter: {
          'hairdresserId': _selectedHairdresser!.id,
          'appointmentDateFrom': startOfDay.toIso8601String(),
          'appointmentDateTo': endOfDay.toIso8601String(),
          'isActive': true,
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _existingAppointments = result.items ?? [];
          _isLoadingAppointments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAppointments = false;
        });
        print('Error loading appointments: $e');
      }
    }
  }

  bool _isTimeSlotAvailable(TimeOfDay timeSlot) {
    if (_selectedDate == null || _selectedHairdresser == null) {
      return true;
    }

    final slotDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      timeSlot.hour,
      timeSlot.minute,
    );

    // Check if this time slot conflicts with any existing appointment
    // Only block time slots with Reserved (statusId = 1) or Completed (statusId = 3) appointments
    // Cancelled appointments (statusId = 2) should not block the slot
    for (var appointment in _existingAppointments) {
      final appointmentTime = appointment.appointmentDate;
      final isCancelled = appointment.statusId == 2;
      
      // Skip cancelled appointments - they don't block the slot
      if (isCancelled) {
        continue;
      }
      
      // Check if the slot overlaps (same hour and minute)
      if (appointmentTime.year == slotDateTime.year &&
          appointmentTime.month == slotDateTime.month &&
          appointmentTime.day == slotDateTime.day &&
          appointmentTime.hour == slotDateTime.hour &&
          appointmentTime.minute == slotDateTime.minute) {
        return false;
      }
    }

    return true;
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    if (_selectedHairstyle != null) {
      total += _selectedHairstyle!.price;
    }
    if (_selectedFacialHair != null) {
      total += _selectedFacialHair!.price;
    }
    if (_selectedDying != null) {
      total += 10.0; // Dying is always +10
    }
    return total;
  }

  bool _canProceedToCheckout() {
    // Check if at least one service is selected (based on toggle states)
    bool hasSelectedService = false;
    if (_showHairstyle && _selectedHairstyle != null) {
      hasSelectedService = true;
    }
    if (_showFacialHair && _selectedFacialHair != null) {
      hasSelectedService = true;
    }
    if (_showDying && _selectedDying != null) {
      hasSelectedService = true;
    }

    return _selectedDate != null &&
        _selectedTime != null &&
        _selectedHairdresser != null &&
        hasSelectedService;
  }

  bool _isFemaleUser() {
    return UserProvider.currentUser?.genderId == 2;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: orangePrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
      });
      
      // Reload appointments for the new date if hairdresser is selected
      if (_selectedHairdresser != null) {
        await _loadExistingAppointments();
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

  void _handleProceedToCheckout() {
    if (!_canProceedToCheckout()) {
      _showErrorDialog('Please select date, time, hairdresser, and at least one service.');
      return;
    }

    // Validate required fields
    if (_selectedDate == null || _selectedTime == null || _selectedHairdresser == null) {
      _showErrorDialog('Please select date, time, and hairdresser.');
      return;
    }

    // Combine date and time into DateTime
    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Navigate to checkout screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentCheckoutScreen(
          selectedDate: _selectedDate!,
          selectedTime: appointmentDateTime,
          selectedHairdresser: _selectedHairdresser!,
          selectedHairstyle: _selectedHairstyle,
          selectedFacialHair: _selectedFacialHair,
          selectedDying: _selectedDying,
          totalPrice: _calculateTotalPrice(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hairstylePageController.dispose();
    _facialHairPageController.dispose();
    _dyingPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selection
                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 12),
                  _buildDateSelector(),
                  const SizedBox(height: 24),

                  // Hairdresser Selection
                  _buildSectionTitle('Select Hairdresser'),
                  const SizedBox(height: 12),
                  _buildHairdresserDropdown(),
                  const SizedBox(height: 24),

                  // Time Slot Selection
                  if (_selectedDate != null && _selectedHairdresser != null) ...[
                    _buildSectionTitle('Select Time'),
                    const SizedBox(height: 12),
                    _buildTimeSlotSelector(),
                    const SizedBox(height: 24),
                  ],

                  // Service Selections
                  _buildSectionTitle('Select Services (Optional)'),
                  const SizedBox(height: 12),

                  // Hairstyle Toggle
                  _buildServiceToggle(
                    title: 'Hairstyle',
                    value: _showHairstyle,
                    onChanged: (value) {
                      setState(() {
                        _showHairstyle = value;
                        if (!value) {
                          _selectedHairstyle = null;
                          _selectedLength = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Length Selection and Hairstyle Carousel (shown when toggle is on)
                  if (_showHairstyle) ...[
                    _buildSectionTitle('Select Length', fontSize: 14),
                    const SizedBox(height: 8),
                    _buildLengthDropdown(),
                    const SizedBox(height: 16),

                    // Hairstyle Selection (Carousel)
                    if (_selectedLength != null) ...[
                      _buildSectionTitle('Select Hairstyle', fontSize: 14),
                      const SizedBox(height: 8),
                      _buildHairstyleCarousel(),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Facial Hair Toggle (only for non-female users)
                  if (!_isFemaleUser()) ...[
                    _buildServiceToggle(
                      title: 'Facial Hair',
                      value: _showFacialHair,
                      onChanged: (value) {
                        setState(() {
                          _showFacialHair = value;
                          if (!value) {
                            _selectedFacialHair = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Facial Hair Carousel (shown when toggle is on)
                    if (_showFacialHair) ...[
                      _buildSectionTitle('Facial Hair', fontSize: 14),
                      const SizedBox(height: 8),
                      _buildFacialHairCarousel(),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Dying Toggle
                  _buildServiceToggle(
                    title: 'Dying',
                    value: _showDying,
                    onChanged: (value) {
                      setState(() {
                        _showDying = value;
                        if (!value) {
                          _selectedDying = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Dying Carousel (shown when toggle is on)
                  if (_showDying) ...[
                    _buildSectionTitle('Dying', fontSize: 14),
                    const SizedBox(height: 8),
                    _buildDyingCarousel(),
                  ],
                  const SizedBox(height: 24),

                  // Price Summary
                  _buildPriceSummary(),
                  const SizedBox(height: 24),

                  // Proceed to Checkout Button
                  _buildCheckoutButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, {double fontSize = 18}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F2937),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildServiceToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? orangePrimary : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getServiceIcon(title),
                color: value ? orangePrimary : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value
                      ? const Color(0xFF1F2937)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: orangePrimary,
            activeTrackColor: orangePrimary.withOpacity(0.5),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String title) {
    switch (title.toLowerCase()) {
      case 'hairstyle':
        return Icons.content_cut_rounded;
      case 'facial hair':
        return Icons.face_rounded;
      case 'dying':
        return Icons.palette_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedDate != null ? orangePrimary : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: _selectedDate != null ? orangePrimary : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!)
                    : 'Select a date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.w400,
                  color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairdresserDropdown() {
    if (_hairdressers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No hairdressers available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BaseDropdown<User>(
      label: 'Hairdresser',
      value: _selectedHairdresser,
      items: _hairdressers.map((hairdresser) {
        return DropdownMenuItem<User>(
          value: hairdresser,
          child: Row(
            children: [
              // Hairdresser Image
              BasePictureCover(
                base64: hairdresser.picture,
                size: 32,
                fallbackIcon: Icons.person_rounded,
                borderColor: Colors.grey[300]!,
                iconColor: Colors.grey[600]!,
                backgroundColor: Colors.grey[100],
                borderWidth: 1.5,
                isCircular: true,
              ),
              const SizedBox(width: 12),
              // Hairdresser Name
              Expanded(
                child: Text(
                  '${hairdresser.firstName} ${hairdresser.lastName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (User? hairdresser) async {
        if (hairdresser != null) {
          final previousHairdresser = _selectedHairdresser;
          setState(() {
            _selectedHairdresser = hairdresser;
            if (previousHairdresser?.id != hairdresser.id) {
              _selectedTime = null; // Reset time when hairdresser changes
            }
          });
          // Load appointments for selected date and hairdresser
          if (_selectedDate != null) {
            await _loadExistingAppointments();
          }
        }
      },
      hintText: 'Select a hairdresser',
      prefixIcon: Icons.person_rounded,
    );
  }

  Widget _buildLengthDropdown() {
    if (_lengths.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No lengths available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BaseDropdown<Length>(
      label: 'Hair Length',
      value: _selectedLength,
      items: _lengths.map((length) {
        return DropdownMenuItem<Length>(
          value: length,
          child: Text(length.name),
        );
      }).toList(),
      onChanged: (Length? length) {
        setState(() {
          _selectedLength = length;
          _selectedHairstyle = null; // Reset selection when length changes
        });
        _filterHairstyles();
      },
      hintText: 'Select a length',
      prefixIcon: Icons.straighten_rounded,
    );
  }

  Widget _buildHairstyleCarousel() {
    if (_filteredHairstyles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No hairstyles available for this length',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PageView.builder(
            controller: _hairstylePageController,
            itemCount: _filteredHairstyles.length,
            onPageChanged: (index) {
              setState(() {
                _selectedHairstyle = _filteredHairstyles[index];
              });
            },
            itemBuilder: (context, index) {
              final hairstyle = _filteredHairstyles[index];
              final isSelected = _selectedHairstyle?.id == hairstyle.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedHairstyle = hairstyle;
                  });
                  if (_hairstylePageController.hasClients) {
                    _hairstylePageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hairstyle Image
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? orangePrimary
                                : Colors.grey[300]!,
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BasePictureCover(
                            base64: hairstyle.image,
                            size: 280,
                            fallbackIcon: Icons.content_cut_rounded,
                            borderColor: Colors.transparent,
                            iconColor: isSelected
                                ? orangePrimary
                                : Colors.grey[600]!,
                            isCircular: false,
                            borderRadius: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hairstyle Name and Price
                      Text(
                        hairstyle.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? orangePrimary
                              : const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${hairstyle.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: orangePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicator
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _filteredHairstyles.length,
              (index) {
                final isCurrentPage = _selectedHairstyle != null &&
                    _filteredHairstyles[index].id == _selectedHairstyle!.id;
                return Container(
                  width: isCurrentPage ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrentPage
                        ? orangePrimary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    if (_isLoadingAppointments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
          ),
        ),
      );
    }

    // Split time slots into rows of 4
    final firstRow = _timeSlots.take(4).toList();
    final secondRow = _timeSlots.skip(4).toList();

    return Column(
      children: [
        // First row: 7:00, 8:00, 9:00, 10:00
        Row(
          children: List.generate(4, (index) {
            if (index < firstRow.length) {
              final timeSlot = firstRow[index];
              final isSelected = _selectedTime?.hour == timeSlot.hour &&
                  _selectedTime?.minute == timeSlot.minute;
              final isAvailable = _isTimeSlotAvailable(timeSlot);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < firstRow.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: isAvailable
                        ? () {
                            setState(() {
                              _selectedTime = timeSlot;
                            });
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? orangePrimary
                            : isAvailable
                                ? Colors.white
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? orangePrimary
                              : isAvailable
                                  ? Colors.grey[300]!
                                  : Colors.grey[400]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: orangePrimary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '${timeSlot.hour.toString().padLeft(2, '0')}:${timeSlot.minute.toString().padLeft(2, '0')}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isAvailable
                                  ? Colors.black87
                                  : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Expanded(child: Container());
            }
          }),
        ),
        // Second row: 14:00 (and any additional times)
        if (secondRow.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (index) {
              if (index < secondRow.length) {
                final timeSlot = secondRow[index];
                final isSelected = _selectedTime?.hour == timeSlot.hour &&
                    _selectedTime?.minute == timeSlot.minute;
                final isAvailable = _isTimeSlotAvailable(timeSlot);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < secondRow.length - 1 ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: isAvailable
                          ? () {
                              setState(() {
                                _selectedTime = timeSlot;
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? orangePrimary
                              : isAvailable
                                  ? Colors.white
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? orangePrimary
                                : isAvailable
                                    ? Colors.grey[300]!
                                    : Colors.grey[400]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: orangePrimary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '${timeSlot.hour.toString().padLeft(2, '0')}:${timeSlot.minute.toString().padLeft(2, '0')}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : isAvailable
                                    ? Colors.black87
                                    : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Expanded(child: Container());
              }
            }),
          ),
        ],
      ],
    );
  }


  Widget _buildFacialHairCarousel() {
    if (_facialHairs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No facial hair options available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Initialize to selected facial hair if one exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedFacialHair != null && _facialHairPageController.hasClients) {
        final index = _facialHairs.indexWhere(
          (fh) => fh.id == _selectedFacialHair!.id,
        );
        if (index >= 0 && _facialHairPageController.page?.round() != index) {
          _facialHairPageController.jumpToPage(index);
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PageView.builder(
            controller: _facialHairPageController,
            itemCount: _facialHairs.length,
            onPageChanged: (index) {
              setState(() {
                _selectedFacialHair = _facialHairs[index];
              });
            },
            itemBuilder: (context, index) {
              final facialHair = _facialHairs[index];
              final isSelected = _selectedFacialHair?.id == facialHair.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFacialHair = facialHair;
                  });
                  if (_facialHairPageController.hasClients) {
                    _facialHairPageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Facial Hair Image
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? orangePrimary
                                : Colors.grey[300]!,
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BasePictureCover(
                            base64: facialHair.image,
                            size: 280,
                            fallbackIcon: Icons.face_rounded,
                            borderColor: Colors.transparent,
                            iconColor: isSelected
                                ? orangePrimary
                                : Colors.grey[600]!,
                            isCircular: false,
                            borderRadius: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Facial Hair Name and Price
                      Text(
                        facialHair.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? orangePrimary
                              : const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${facialHair.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: orangePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicator
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _facialHairs.length,
              (index) {
                final isCurrentPage = _selectedFacialHair != null &&
                    _facialHairs[index].id == _selectedFacialHair!.id;
                return Container(
                  width: isCurrentPage ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrentPage
                        ? orangePrimary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDyingCarousel() {
    if (_dyings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No dying options available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Initialize to selected dying if one exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDying != null && _dyingPageController.hasClients) {
        final index = _dyings.indexWhere(
          (d) => d.id == _selectedDying!.id,
        );
        if (index >= 0 && _dyingPageController.page?.round() != index) {
          _dyingPageController.jumpToPage(index);
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PageView.builder(
            controller: _dyingPageController,
            itemCount: _dyings.length,
            onPageChanged: (index) {
              setState(() {
                _selectedDying = _dyings[index];
              });
            },
            itemBuilder: (context, index) {
              final dying = _dyings[index];
              final isSelected = _selectedDying?.id == dying.id;
              final colorHex = dying.hexCode;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDying = dying;
                  });
                  if (_dyingPageController.hasClients) {
                    _dyingPageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Dying Color Display
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? orangePrimary
                                : Colors.grey[300]!,
                            width: isSelected ? 3 : 2,
                          ),
                          color: colorHex != null
                              ? _hexToColor(colorHex)
                              : Colors.grey[200],
                        ),
                        child: colorHex == null
                            ? Icon(
                                Icons.palette_rounded,
                                size: 80,
                                color: isSelected
                                    ? orangePrimary
                                    : Colors.grey[600],
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Dying Name and Price
                      Text(
                        dying.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? orangePrimary
                              : const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$10.00',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: orangePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicator
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _dyings.length,
              (index) {
                final isCurrentPage = _selectedDying != null &&
                    _dyings[index].id == _selectedDying!.id;
                return Container(
                  width: isCurrentPage ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrentPage
                        ? orangePrimary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }



  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget _buildPriceSummary() {
    final totalPrice = _calculateTotalPrice();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            orangePrimary.withOpacity(0.1),
            orangePrimary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: orangePrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedHairstyle != null)
            _buildPriceRow(
              _selectedHairstyle!.name,
              _selectedHairstyle!.price,
            ),
          if (_selectedFacialHair != null)
            _buildPriceRow(
              _selectedFacialHair!.name,
              _selectedFacialHair!.price,
            ),
          if (_selectedDying != null)
            _buildPriceRow(
              _selectedDying!.name,
              10.0,
            ),
          if (_selectedHairstyle == null &&
              _selectedFacialHair == null &&
              _selectedDying == null)
            const Text(
              'No services selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: orangePrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    final canProceed = _canProceedToCheckout();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canProceed
            ? LinearGradient(
                colors: [orangePrimary, orangeDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: canProceed
            ? [
                BoxShadow(
                  color: orangePrimary.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: canProceed ? _handleProceedToCheckout : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
        child: const Text(
          'Proceed to Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

