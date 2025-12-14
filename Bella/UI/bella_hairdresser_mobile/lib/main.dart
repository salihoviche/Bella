
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:bella_hairdresser_mobile/layouts/master_screen.dart';
import 'package:bella_hairdresser_mobile/providers/auth_provider.dart';
import 'package:bella_hairdresser_mobile/providers/city_provider.dart';
import 'package:bella_hairdresser_mobile/providers/gender_provider.dart';
import 'package:bella_hairdresser_mobile/providers/review_provider.dart';
import 'package:bella_hairdresser_mobile/providers/user_provider.dart';
import 'package:bella_hairdresser_mobile/providers/appointment_provider.dart';
import 'package:bella_hairdresser_mobile/providers/hairstyle_provider.dart';
import 'package:bella_hairdresser_mobile/providers/facial_hair_provider.dart';
import 'package:bella_hairdresser_mobile/providers/dying_provider.dart';
import 'package:bella_hairdresser_mobile/providers/length_provider.dart';
import 'package:bella_hairdresser_mobile/providers/hairdresser_analytics_provider.dart';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider()),
        ChangeNotifierProvider<CityProvider>(create: (_) => CityProvider()),
        ChangeNotifierProvider<GenderProvider>(create: (_) => GenderProvider()),
        ChangeNotifierProvider<AppointmentProvider>(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider<HairstyleProvider>(create: (_) => HairstyleProvider()),
        ChangeNotifierProvider<FacialHairProvider>(create: (_) => FacialHairProvider()),
        ChangeNotifierProvider<DyingProvider>(create: (_) => DyingProvider()),
        ChangeNotifierProvider<LengthProvider>(create: (_) => LengthProvider()),
        ChangeNotifierProvider<HairdresserAnalyticsProvider>(create: (_) => HairdresserAnalyticsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bella Hairdresser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6), // Purple for hairdresser app
          primary: const Color(0xFF8B5CF6),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _fadeAnimationController;
  late AnimationController _shapeAnimationController;
  late AnimationController _colorSwapAnimationController;
  late AnimationController _logoPulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shapeAnimation;
  late Animation<double> _colorSwapAnimation;
  late Animation<double> _logoPulseAnimation;

  // Purple color scheme for hairdresser app (distinct from client app)
  static const Color purplePrimary = Color(0xFF8B5CF6); // Purple
  static const Color purpleDark = Color(0xFF6D28D9); // Dark purple

  @override
  void initState() {
    super.initState();
    // Fade animation
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );
    
    // Shape animation
    _shapeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _shapeAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _shapeAnimationController, curve: Curves.easeInOut),
    );
    
    // Color swap animation
    _colorSwapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _colorSwapAnimation = CurvedAnimation(
      parent: _colorSwapAnimationController,
      curve: Curves.easeInOutCubic,
    );
    
    // Logo pulse animation
    _logoPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _logoPulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoPulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Listen to focus changes
    _usernameFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
    
    _fadeAnimationController.forward();
  }

  void _handleFocusChange() {
    if (_usernameFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      _colorSwapAnimationController.forward();
    } else {
      _colorSwapAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _usernameFocusNode.removeListener(_handleFocusChange);
    _passwordFocusNode.removeListener(_handleFocusChange);
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeAnimationController.dispose();
    _shapeAnimationController.dispose();
    _colorSwapAnimationController.dispose();
    _logoPulseController.dispose();
    super.dispose();
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
          color: purplePrimary,
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
            // Top Section - Dark background with icon and curved bottom
            Expanded(
              flex: 1,
              child: AnimatedBuilder(
                animation: _colorSwapAnimation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: _CurvedBottomClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(purpleDark, purpleDark, _colorSwapAnimation.value * 0.1)!,
                            Color.lerp(Colors.grey[800]!, purplePrimary, _colorSwapAnimation.value * 0.9)!,
                          ],
                        ),
                      ),
                    child: Stack(
                      children: [
                        // Decorative animated shapes
                        AnimatedBuilder(
                          animation: _shapeAnimation,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Positioned(
                                  top: 40 + _shapeAnimation.value * 0.5,
                                  right: 30 + _shapeAnimation.value,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 100 - _shapeAnimation.value * 0.7,
                                  left: 20 - _shapeAnimation.value * 0.5,
                                  child: Transform.rotate(
                                    angle: 0.3 + _shapeAnimation.value * 0.01,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Center logo and title with decorative elements
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo with circular background - more prominent and animated
                              AnimatedBuilder(
                                animation: Listenable.merge([_shapeAnimation, _logoPulseAnimation]),
                                builder: (context, child) {
                                  return TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 1000),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.elasticOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale * _logoPulseAnimation.value * (1.0 + _shapeAnimation.value * 0.03),
                                        child: Transform.rotate(
                                          angle: _shapeAnimation.value * 0.15,
                                          child: Container(
                                            width: 160,
                                            height: 160,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              border: Border.all(
                                                color: purplePrimary.withOpacity(0.4 + _logoPulseAnimation.value * 0.2),
                                                width: 4,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 35,
                                                  spreadRadius: 10,
                                                ),
                                                BoxShadow(
                                                  color: purplePrimary.withOpacity(0.3 * _logoPulseAnimation.value),
                                                  blurRadius: 25,
                                                  spreadRadius: 8,
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(24),
                                            child: Image.asset(
                                              'assets/images/logo_small.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              // Welcome Back title
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, opacity, child) {
                                  return Opacity(
                                    opacity: opacity,
                                    child: const Text(
                                      "Welcome Back!",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              // Subtitle
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, opacity, child) {
                                  return Opacity(
                                    opacity: opacity,
                                    child: Text(
                                      "Sign in to manage appointments",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        // Additional decorative elements
                        Positioned(
                          top: 120,
                          left: 40,
                          child: AnimatedBuilder(
                            animation: _shapeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shapeAnimation.value * 0.3, _shapeAnimation.value * 0.2),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 80,
                          right: 50,
                          child: AnimatedBuilder(
                            animation: _shapeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(-_shapeAnimation.value * 0.4, _shapeAnimation.value * 0.3),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 180,
                          right: 60,
                          child: AnimatedBuilder(
                            animation: _shapeAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _shapeAnimation.value * 0.02,
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Section - White form with rounded top corners
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username field
                        TextField(
                          controller: usernameController,
                          focusNode: _usernameFocusNode,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _underlineTextFieldDecoration(
                            "Username",
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Password field
                        TextField(
                          controller: passwordController,
                          focusNode: _passwordFocusNode,
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
                        const SizedBox(height: 50),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purplePrimary,
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
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40),

                  
                      
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

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final username = usernameController.text;
      final password = passwordController.text;

      // Set basic auth for subsequent requests
      AuthProvider.username = username;
      AuthProvider.password = password;

      // Authenticate and set current user
      final userProvider = UserProvider();
      final user = await userProvider.authenticate(username, password);

      if (user != null) {
        // Check if user has hairdresser role (roleId = 3)
        bool hasHairdresserRole = user.roles.any((role) => role.id == 3);

        print(
          "User roles: ${user.roles.map((r) => '${r.name} (ID: ${r.id})').join(', ')}",
        );
        print("Has hairdresser role: $hasHairdresserRole");

        if (hasHairdresserRole) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MasterScreen(
                  child: SizedBox.shrink(),
                  title: 'Bella Hairdresser',
                ),
                settings: const RouteSettings(name: 'MasterScreen'),
              ),
            );
          }
        } else {
          if (mounted) {
            _showAccessDeniedDialog();
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog("Invalid username or password.");
        }
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Login Failed"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: purplePrimary,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Access Denied"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You do not have hairdresser privileges.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text(
              "This application is restricted to hairdressers only. Please contact your system administrator if you believe you should have access.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear the form and reset state
              usernameController.clear();
              passwordController.clear();
              // Clear authentication credentials
              AuthProvider.username = '';
              AuthProvider.password = '';
              setState(() {
                _isLoading = false;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: purplePrimary,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
