import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/providers/city_provider.dart';
import 'package:bella_client_mobile/providers/gender_provider.dart';
import 'package:bella_client_mobile/model/city.dart';
import 'package:bella_client_mobile/model/gender.dart';
import 'package:provider/provider.dart';

// Custom clipper for curved bottom edge
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    
    // Left curve
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height - 20,
      size.width * 0.3,
      size.height - 20,
    );
    
    // Right curve
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height - 20,
      size.width * 0.85,
      size.height - 20,
    );
    
    // Final curve to right edge
    path.quadraticBezierTo(
      size.width,
      size.height - 20,
      size.width,
      size.height,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isLoadingCities = true;
  bool _isLoadingGenders = true;

  City? _selectedCity;
  Gender? _selectedGender;
  List<City> _cities = [];
  List<Gender> _genders = [];

  // Picture upload
  File? _image;
  String? _pictureBase64;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);
  static const Color orangeDark = Color(0xFFFF6B1A);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final cityProvider = Provider.of<CityProvider>(context, listen: false);
      final genderProvider = Provider.of<GenderProvider>(
        context,
        listen: false,
      );

      final citiesResult = await cityProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000, // Get all cities
          'includeTotalCount': false,
        },
      );
      final gendersResult = await genderProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000, // Get all genders
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _cities = citiesResult.items ?? [];
          _genders = gendersResult.items ?? [];
          _isLoadingCities = false;
          _isLoadingGenders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
          _isLoadingGenders = false;
        });
        _showErrorDialog("Failed to load registration data: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _pictureBase64 = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  // Custom underline text field decoration
  InputDecoration _underlineTextFieldDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: orangePrimary,
          width: 2,
        ),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: Colors.grey[600],
              size: 20,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Top Section - Orange header with back button and title
            Expanded(
              flex: 0,
              child: ClipPath(
                clipper: _CurvedBottomClipper(),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 184, 102, 2),
                        orangeDark,
                        orangePrimary,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          // Back button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: orangePrimary,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title
                          const Expanded(
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Section - White form
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
        

                        // Name field

                        TextField(
                          controller: firstNameController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Name",
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Surname field
                        TextField(
                          controller: lastNameController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Surname",
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),

   // Username field
                        TextField(
                          controller: usernameController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Username",
                            prefixIcon: Icons.account_circle_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email field
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Email",
                            prefixIcon: Icons.email_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Phone field
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Phone",
                            prefixIcon: Icons.phone_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),

                

                        // Password field
                        TextField(
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Password",
                            prefixIcon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Confirm Password field
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Confirm Password",
                            prefixIcon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

             

                        // Gender dropdown
                        DropdownButtonFormField<Gender>(
                          value: _selectedGender,
                          decoration: _underlineTextFieldDecoration(
                            "Gender",
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          items: _genders.map((Gender gender) {
                            return DropdownMenuItem<Gender>(
                              value: gender,
                              child: Text(gender.name),
                            );
                          }).toList(),
                          onChanged: (Gender? newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // City dropdown
                        DropdownButtonFormField<City>(
                          value: _selectedCity,
                          decoration: _underlineTextFieldDecoration(
                            "City",
                            prefixIcon: Icons.location_city_rounded,
                          ),
                          items: _cities.map((City city) {
                            return DropdownMenuItem<City>(
                              value: city,
                              child: Text(
                                city.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (City? newValue) {
                            setState(() {
                              _selectedCity = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 32),

                        // Profile picture section (optional, can be hidden or shown)
                        if (_pictureBase64 != null) ...[
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: orangePrimary,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.memory(
                                  base64Decode(_pictureBase64!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                              label: const Text("Change Picture"),
                              style: TextButton.styleFrom(
                                foregroundColor: orangePrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          Center(
                            child: TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                              label: const Text("Add Profile Picture (Optional)"),
                              style: TextButton.styleFrom(
                                foregroundColor: orangePrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _isLoadingCities || _isLoadingGenders)
                                ? null
                                : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orangePrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "CREATE ACCOUNT",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "LOG IN",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: orangePrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Validate form
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Create registration request
      final registrationData = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "username": usernameController.text.trim(),
        "password": passwordController.text,
        "phoneNumber": phoneController.text.trim(),
        "genderId": _selectedGender!.id,
        "cityId": _selectedCity!.id,
        "isActive": true,
        "roleIds": [2], // Standard user role
        "picture": _pictureBase64,
      };

      await userProvider.insert(registrationData);

      if (mounted) {
        _showSuccessDialog();
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      _showErrorDialog("Name is required.");
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showErrorDialog("Surname is required.");
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showErrorDialog("Email is required.");
      return false;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      _showErrorDialog("Please enter a valid email address.");
      return false;
    }
    if (usernameController.text.trim().isEmpty) {
      _showErrorDialog("Username is required.");
      return false;
    }
    if (passwordController.text.length < 4) {
      _showErrorDialog("Password must be at least 4 characters long.");
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match.");
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      _showErrorDialog("Phone number is required.");
      return false;
    }
    // Basic phone number validation (at least 10 digits)
    final phoneRegex = RegExp(r'^[+]?[\d\s\-()]{9,}$');
    if (!phoneRegex.hasMatch(phoneController.text.trim())) {
      _showErrorDialog("Please enter a valid phone number (at least 9 digits).");
      return false;
    }
    if (_selectedGender == null) {
      _showErrorDialog("Please select a gender.");
      return false;
    }
    if (_selectedCity == null) {
      _showErrorDialog("Please select a city.");
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Registration Failed"),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text("Registration Success!"),
          ],
        ),
        content: const Text(
          "Your account has been created successfully! You can now sign in with your credentials.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to login screen
            },
            style: TextButton.styleFrom(
              foregroundColor: orangePrimary,
            ),
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }
}
