import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:bella_client_mobile/model/user.dart';
import 'package:bella_client_mobile/model/hairstyle.dart';
import 'package:bella_client_mobile/model/facial_hair.dart';
import 'package:bella_client_mobile/model/dying.dart';
import 'package:bella_client_mobile/providers/appointment_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/layouts/master_screen.dart';
import 'package:flutter/widgets.dart';

class AppointmentCheckoutScreen extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime selectedTime; // This is actually the combined DateTime
  final User selectedHairdresser;
  final Hairstyle? selectedHairstyle;
  final FacialHair? selectedFacialHair;
  final Dying? selectedDying;
  final double totalPrice;
  final VoidCallback? onNavigateToHome; // Callback to navigate to home

  const AppointmentCheckoutScreen({
    super.key,
    required this.selectedDate,
    required this.selectedTime, // Combined DateTime (date + time)
    required this.selectedHairdresser,
    this.selectedHairstyle,
    this.selectedFacialHair,
    this.selectedDying,
    required this.totalPrice,
    this.onNavigateToHome,
  });

  @override
  State<AppointmentCheckoutScreen> createState() => _AppointmentCheckoutScreenState();
}

class _AppointmentCheckoutScreenState extends State<AppointmentCheckoutScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _paymentCompleted = false;
  String? _generatedAppointmentId;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);
  static const Color orangeDark = Color(0xFFFF6B1A);

  final commonDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: orangePrimary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  // Get appointment DateTime (already combined)
  DateTime get _appointmentDateTime {
    return widget.selectedTime;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Appointment Checkout',
      showBackButton: true,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
              ),
            )
          : _paymentCompleted
              ? _buildPaymentSuccessScreen()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildCheckoutForm(context),
                ),
    );
  }

  Widget _buildPaymentSuccessScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Success message
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: orangePrimary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        orangePrimary.withOpacity(0.2),
                        orangeDark.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: orangePrimary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Appointment Booked!',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your appointment has been confirmed.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (_generatedAppointmentId != null)
                  Text(
                    'Appointment ID: $_generatedAppointmentId',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appointment details card
          _buildAppointmentDetailsCard(),

          const SizedBox(height: 32),

          // Action buttons
          Column(
            children: [
              Container(
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
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _navigateToHome();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.home_rounded, size: 22),
                    label: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: orangePrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: orangePrimary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Hairdresser',
                  '${widget.selectedHairdresser.firstName} ${widget.selectedHairdresser.lastName}',
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Date & Time',
                  DateFormat('MMM dd, yyyy • hh:mm a').format(_appointmentDateTime),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Services',
                  _getServicesList(),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Total Amount',
                  '\$${widget.totalPrice.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We look forward to seeing you at your appointment!',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getServicesList() {
    List<String> services = [];
    if (widget.selectedHairstyle != null) {
      services.add(widget.selectedHairstyle!.name);
    }
    if (widget.selectedFacialHair != null) {
      services.add(widget.selectedFacialHair!.name);
    }
    if (widget.selectedDying != null) {
      services.add(widget.selectedDying!.name);
    }
    return services.isEmpty ? 'None' : services.join(', ');
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF1F2937) : Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? orangePrimary : const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutForm(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 24),
          _buildAppointmentSummaryCard(),
          const SizedBox(height: 24),
          _buildBillingSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: orangePrimary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Appointment Payment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '\$${widget.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(_appointmentDateTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: orangePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: orangePrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Appointment Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Hairdresser',
              '${widget.selectedHairdresser.firstName} ${widget.selectedHairdresser.lastName}'),
          if (widget.selectedHairstyle != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('Hairstyle', widget.selectedHairstyle!.name),
          ],
          if (widget.selectedFacialHair != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('Facial Hair', widget.selectedFacialHair!.name),
          ],
          if (widget.selectedDying != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('Dying', widget.selectedDying!.name),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Date & Time',
            DateFormat('MMM dd, yyyy • hh:mm a').format(_appointmentDateTime),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: orangePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: orangePrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Billing Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'name',
            'Full Name',
            initialValue: _getUserFullName(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'address',
            'Address',
            initialValue: '123 Main Street',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'city',
                  'City',
                  initialValue: 'New York',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('state', 'State', initialValue: 'NY'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'country',
                  'Country',
                  initialValue: 'United States',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'pincode',
                  'ZIP Code',
                  keyboardType: TextInputType.number,
                  isNumeric: true,
                  initialValue: '10001',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserFullName() {
    final user = UserProvider.currentUser;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'John Doe';
  }

  Widget _buildTextField(
    String name,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
    String? initialValue,
  }) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: commonDecoration.copyWith(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      validator: isNumeric
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
              FormBuilderValidators.numeric(
                errorText: 'This field must be numeric',
              ),
            ])
          : FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
            ]),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
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
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.lock_outline_rounded, size: 22),
          label: const Text(
            "Proceed to Payment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            if (formKey.currentState?.saveAndValidate() ?? false) {
              final formData = formKey.currentState?.value;

              try {
                await _processStripePayment(formData!);
              } catch (e) {
                _showErrorSnackbar('Payment failed: ${e.toString()}');
              }
            }
          },
        ),
      ),
    );
  }

  // Stripe Payment Methods (same as payment_screen.dart)
  Future<void> _initPaymentSheet(Map<String, dynamic> formData) async {
    try {
      final data = await _createPaymentIntent(
        amount: (widget.totalPrice * 100).round().toString(),
        currency: 'USD',
        name: formData['name'] ?? 'John Doe',
        address: formData['address'] ?? '123 Main Street',
        pin: formData['pincode'] ?? '10001',
        city: formData['city'] ?? 'New York',
        state: formData['state'] ?? 'NY',
        country: formData['country'] ?? 'United States',
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Bella Salon',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.light,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required String amount,
    required String currency,
    required String name,
    required String address,
    required String pin,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      final secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? 
          'sk_test_51QJ8XxExampleKeyForDemoPurposesOnly';

      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': UserProvider.currentUser?.email ?? 'demo@bella.com',
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
        },
      );

      if (customerResponse.statusCode != 200) {
        return _createMockPaymentIntent(amount, currency);
      }

      final customerData = jsonDecode(customerResponse.body);
      final customerId = customerData['id'];

      final ephemeralKeyResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Stripe-Version': '2023-10-16',
        },
        body: {'customer': customerId},
      );

      if (ephemeralKeyResponse.statusCode != 200) {
        return _createMockPaymentIntent(amount, currency);
      }

      final ephemeralKeyData = jsonDecode(ephemeralKeyResponse.body);

      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency.toLowerCase(),
          'customer': customerId,
          'payment_method_types[]': 'card',
          'description': 'Bella Salon Appointment Booking',
          'metadata[name]': name,
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
          'metadata[appointment_date]': _appointmentDateTime.toIso8601String(),
        },
      );

      if (paymentIntentResponse.statusCode == 200) {
        final paymentIntentData = jsonDecode(paymentIntentResponse.body);
        return {
          'client_secret': paymentIntentData['client_secret'],
          'ephemeralKey': ephemeralKeyData['secret'],
          'id': customerId,
          'amount': amount,
          'currency': currency,
        };
      } else {
        return _createMockPaymentIntent(amount, currency);
      }
    } catch (e) {
      return _createMockPaymentIntent(amount, currency);
    }
  }

  Map<String, dynamic> _createMockPaymentIntent(String amount, String currency) {
    return {
      'client_secret': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}_secret_mock',
      'ephemeralKey': 'ek_mock_${DateTime.now().millisecondsSinceEpoch}',
      'id': 'cus_mock_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'currency': currency,
    };
  }

  Future<void> _processStripePayment(Map<String, dynamic> formData) async {
    setState(() => _isLoading = true);

    try {
      await _initPaymentSheet(formData);
      
      await stripe.Stripe.instance.presentPaymentSheet();

      // Create appointment after successful payment
      final appointmentData = await _createAppointment();

      setState(() {
        _paymentCompleted = true;
        _generatedAppointmentId = appointmentData['id'].toString();
        _isLoading = false;
      });

      _showSuccessSnackbar('Payment successful! Appointment booked.');
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (e.toString().contains('canceled') || e.toString().contains('User canceled')) {
        _showInfoSnackbar('Payment was canceled');
      } else {
        // For demo: if Stripe fails, still create appointment (for testing)
        try {
          final appointmentData = await _createAppointment();
          setState(() {
            _paymentCompleted = true;
            _generatedAppointmentId = appointmentData['id'].toString();
            _isLoading = false;
          });
          _showSuccessSnackbar('Appointment created successfully (demo mode)');
        } catch (appointmentError) {
          _showErrorSnackbar('Payment failed: ${e.toString()}');
        }
      }
    }
  }

  Future<Map<String, dynamic>> _createAppointment() async {
    try {
      final user = UserProvider.currentUser;
      if (user == null) throw Exception('User not found');

      // Create appointment request
      final appointmentRequest = {
        'userId': user.id,
        'hairdresserId': widget.selectedHairdresser.id,
        'appointmentDate': _appointmentDateTime.toIso8601String(),
        'hairstyleId': widget.selectedHairstyle?.id,
        'facialHairId': widget.selectedFacialHair?.id,
        'dyingId': widget.selectedDying?.id,
        'isActive': true,
      };

      // Create appointment using the backend endpoint
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final result = await appointmentProvider.insert(appointmentRequest);

      return {
        'id': result.id,
      };
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: orangePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToHome() {
    // Replace the entire navigation stack with a new MasterScreen instance
    // MasterScreen initializes at index 2 (home) by default, so no need to navigate
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MasterScreen(
          child: SizedBox.shrink(),
          title: 'Bella',
        ),
        settings: const RouteSettings(name: 'MasterScreen'),
      ),
      (route) => false, // Remove all previous routes
    );
  }
}

