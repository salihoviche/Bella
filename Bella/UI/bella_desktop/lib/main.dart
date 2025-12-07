import 'package:bella_desktop/screens/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:bella_desktop/providers/auth_provider.dart';
import 'package:bella_desktop/providers/city_provider.dart';
import 'package:bella_desktop/providers/category_provider.dart';
import 'package:bella_desktop/providers/appointment_provider.dart';
import 'package:bella_desktop/providers/order_provider.dart';
import 'package:bella_desktop/providers/product_provider.dart';
import 'package:bella_desktop/providers/user_provider.dart';
import 'package:bella_desktop/providers/gender_provider.dart';
import 'package:bella_desktop/providers/review_provider.dart';
import 'package:bella_desktop/providers/manufacturer_provider.dart';
import 'package:bella_desktop/providers/length_provider.dart';
import 'package:bella_desktop/providers/hairstyle_provider.dart';
import 'package:bella_desktop/providers/facial_hair_provider.dart';
import 'package:bella_desktop/providers/dying_provider.dart';
import 'package:bella_desktop/providers/analytics_provider.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CityProvider>(
          create: (context) => CityProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<GenderProvider>(
          create: (context) => GenderProvider(),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (context) => ReviewProvider(),
        ),
        ChangeNotifierProvider<AppointmentProvider>(
          create: (context) => AppointmentProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider<ManufacturerProvider>(
          create: (context) => ManufacturerProvider(),
        ),
        ChangeNotifierProvider<LengthProvider>(
          create: (context) => LengthProvider(),
        ),
        ChangeNotifierProvider<HairstyleProvider>(
          create: (context) => HairstyleProvider(),
        ),
        ChangeNotifierProvider<FacialHairProvider>(
          create: (context) => FacialHairProvider(),
        ),
        ChangeNotifierProvider<DyingProvider>(
          create: (context) => DyingProvider(),
        ),
        ChangeNotifierProvider<AnalyticsProvider>(
          create: (context) => AnalyticsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bella Salon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C42), // Orange
          primary: const Color(0xFFFF8C42),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
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
  late AnimationController _leftShapeAnimationController;
  late AnimationController _rightShapeAnimationController;
  late AnimationController _colorSwapAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _leftShapeAnimation;
  late Animation<double> _rightShapeAnimation;
  late Animation<double> _colorSwapAnimation;

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
    
    // Left side shape animations
    _leftShapeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _leftShapeAnimation = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(parent: _leftShapeAnimationController, curve: Curves.easeInOut),
    );
    
    // Right side shape animations
    _rightShapeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);
    _rightShapeAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _rightShapeAnimationController, curve: Curves.easeInOut),
    );
    
    // Color swap animation with sliding effect
    _colorSwapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _colorSwapAnimation = CurvedAnimation(
      parent: _colorSwapAnimationController,
      curve: Curves.easeInOutCubic,
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
    _leftShapeAnimationController.dispose();
    _rightShapeAnimationController.dispose();
    _colorSwapAnimationController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  // Orange color scheme
  const Color orangePrimary = Color(0xFFFF8C42);
  const Color orangeDark = Color(0xFFFF6B1A);
  const Color yellowOrange = Color(0xFFFFA500);

  return Scaffold(
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _colorSwapAnimation,
        builder: (context, child) {
          // Interpolate text colors
          final leftTextColor = Color.lerp(
            Colors.black87,
            Colors.white,
            _colorSwapAnimation.value,
          )!;

          final rightTextColor = Color.lerp(
            Colors.white,
            Colors.black87,
            _colorSwapAnimation.value,
          )!;

          return Row(
            children: [
              // LEFT SIDE
              Expanded(
                child: Stack(
                  children: [
                    // Base layer
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[50]!,
                            Colors.white,
                            Colors.grey[100]!,
                          ],
                        ),
                      ),
                    ),

                    // Sliding orange layer
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _colorSwapAnimation.value,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.lerp(yellowOrange, orangePrimary, 0.3)!,
                                orangePrimary,
                                orangeDark,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Stack(
                      children: [
                        // Decorative shapes
                        AnimatedBuilder(
                          animation: _leftShapeAnimation,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Positioned(
                                  top: 80 + _leftShapeAnimation.value * 0.5,
                                  right: 60 + _leftShapeAnimation.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _colorSwapAnimation.value > 0.5
                                          ? Colors.white.withOpacity(0.1)
                                          : orangePrimary.withOpacity(0.08),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 150 - _leftShapeAnimation.value * 0.7,
                                  left: 40 - _leftShapeAnimation.value * 0.5,
                                  child: Transform.rotate(
                                    angle:
                                        0.3 + _leftShapeAnimation.value * 0.01,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: _colorSwapAnimation.value > 0.5
                                            ? Colors.white.withOpacity(0.08)
                                            : yellowOrange.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 300 + _leftShapeAnimation.value * 0.3,
                                  left: 100 + _leftShapeAnimation.value * 0.4,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _colorSwapAnimation.value > 0.5
                                          ? Colors.white.withOpacity(0.06)
                                          : orangeDark.withOpacity(0.05),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 250 - _leftShapeAnimation.value * 0.6,
                                  right: 80 + _leftShapeAnimation.value * 0.8,
                                  child: Transform.rotate(
                                    angle: -0.5 +
                                        _leftShapeAnimation.value * 0.02,
                                    child: Container(
                                      width: 100,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: _colorSwapAnimation.value > 0.5
                                            ? Colors.white.withOpacity(0.12)
                                            : orangePrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // MAIN LOGIN FORM
                        Center(
                          child: SingleChildScrollView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 80),
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 480),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Small logo
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _colorSwapAnimation.value > 0.5
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _colorSwapAnimation.value > 0.5
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.transparent,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _colorSwapAnimation.value > 0.5
                                              ? Colors.black.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/logo_small.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Bella Salon",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: leftTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 80),

                                  // title
                                  Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: leftTextColor,
                                    ),
                                  ),

                                  const SizedBox(height: 60),

                                  // Username
                                  TextField(
                                    controller: usernameController,
                                    focusNode: _usernameFocusNode,
                                    style: TextStyle(
                                      color: _colorSwapAnimation.value > 0.5
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    decoration: customTextFieldDecoration(
                                      "Username",
                                      prefixIcon: Icons.person_outline,
                                      hintText: "Username",
                                    ).copyWith(
                                      fillColor: _colorSwapAnimation.value > 0.5
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.grey[50],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Password
                                  TextField(
                                    controller: passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: !_isPasswordVisible,
                                    style: TextStyle(
                                      color: _colorSwapAnimation.value > 0.5
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    decoration: customTextFieldDecoration(
                                      "Password",
                                      prefixIcon: Icons.lock_outline,
                                      hintText: "Password",
                                    ).copyWith(
                                      fillColor: _colorSwapAnimation.value > 0.5
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.grey[50],
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  // SIGN IN BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _colorSwapAnimation.value > 0.5
                                                ? Colors.white
                                                : orangePrimary,
                                        foregroundColor:
                                            _colorSwapAnimation.value > 0.5
                                                ? orangePrimary
                                                : Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                  _colorSwapAnimation.value > 0.5
                                                      ? orangePrimary
                                                      : Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              "Sign in",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // RIGHT SIDE
              Expanded(
                child: Stack(
                  children: [
                    // Base orange
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            yellowOrange,
                            orangePrimary,
                            orangeDark,
                          ],
                        ),
                      ),
                    ),

                    // Sliding white overlay
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor: _colorSwapAnimation.value,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey[50]!,
                                Colors.white,
                                Colors.grey[100]!,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _rightShapeAnimation,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Positioned(
                                  top: -50 + _rightShapeAnimation.value * 0.3,
                                  right: -50 + _rightShapeAnimation.value * 0.5,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: rightTextColor.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom:
                                      100 - _rightShapeAnimation.value * 0.4,
                                  left:
                                      -30 - _rightShapeAnimation.value * 0.3,
                                  child: Transform.rotate(
                                    angle: 0.5 +
                                        _rightShapeAnimation.value * 0.02,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: rightTextColor.withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(60),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: _colorSwapAnimation.value > 0.5
                                        ? Color(0xFFFFA500).withOpacity(0.1)
                                        : rightTextColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo_small.png',
                                    width: 180,
                                    height: 180,
                                  ),
                                ),

                                const SizedBox(height: 50),

                                Text(
                                  "Welcome to\nBella Salon",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: rightTextColor,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    "Experience premium hairdressing and beauty services.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: rightTextColor.withOpacity(0.8),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
      final userProvider = context.read<UserProvider>();
      final user = await userProvider.authenticate(username, password);

      if (user != null) {
        // Check if user has admin role (roleId = 1)
        bool hasAdminRole = user.roles.any((role) => role.id == 1);

        print(
          "User roles: ${user.roles.map((r) => '${r.name} (ID: ${r.id})').join(', ')}",
        );
        print("Has admin role: $hasAdminRole");

        if (hasAdminRole) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnalyticsScreen(),
                settings: const RouteSettings(name: 'AnalyticsScreen'),
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
    const Color orangePrimary = Color(0xFFFF8C42);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            const SizedBox(width: 12),
            const Text(
              "Login Failed",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black87),
        ),
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

  void _showAccessDeniedDialog() {
    const Color orangePrimary = Color(0xFFFF8C42);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red[600]),
            const SizedBox(width: 12),
            const Text(
              "Access Denied",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You do not have administrator privileges.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "This application is restricted to administrators only. Please contact your system administrator if you believe you should have access.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
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
              foregroundColor: orangePrimary,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
