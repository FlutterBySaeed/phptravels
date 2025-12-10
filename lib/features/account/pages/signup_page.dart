import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/account/pages/login_page.dart';
import 'package:phptravels/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityCheckController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // Error states
  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _securityCheckError = false;

  // Animation controllers
  late AnimationController _firstNameShakeController;
  late AnimationController _lastNameShakeController;
  late AnimationController _emailShakeController;
  late AnimationController _passwordShakeController;
  late AnimationController _confirmPasswordShakeController;
  late AnimationController _securityCheckShakeController;

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
  }

  void _initializeAnimationControllers() {
    _firstNameShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _lastNameShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _emailShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _passwordShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _confirmPasswordShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _securityCheckShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityCheckController.dispose();
    _firstNameShakeController.dispose();
    _lastNameShakeController.dispose();
    _emailShakeController.dispose();
    _passwordShakeController.dispose();
    _confirmPasswordShakeController.dispose();
    _securityCheckShakeController.dispose();
  }

  void _shakeField(AnimationController controller) {
    controller.reset();
    controller.forward();
  }

  Future<void> _handleSignUp() async {
    _resetErrorStates();

    final hasError = _validateForm();
    if (hasError) return;

    if (!_agreeToTerms) {
      _showSnackBar('Please agree to the terms and conditions', Colors.red);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.signup(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      _showSnackBar('Account created successfully!', AppColors.successGreen);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (_) {
      if (!mounted) return;
      final errorMessage =
          authProvider.error ?? 'Signup failed. Please try again.';
      _showSnackBar(errorMessage, AppColors.errorRed);
    }
  }

  void _resetErrorStates() {
    setState(() {
      _firstNameError = false;
      _lastNameError = false;
      _emailError = false;
      _passwordError = false;
      _confirmPasswordError = false;
      _securityCheckError = false;
    });
  }

  bool _validateForm() {
    bool hasError = false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    // Validate each field
    final validations = [
      (
        _firstNameController.text.isEmpty,
        () {
          setState(() => _firstNameError = true);
          _shakeField(_firstNameShakeController);
        }
      ),
      (
        _lastNameController.text.isEmpty,
        () {
          setState(() => _lastNameError = true);
          _shakeField(_lastNameShakeController);
        }
      ),
      (
        _emailController.text.isEmpty ||
            !emailRegex.hasMatch(_emailController.text),
        () {
          setState(() => _emailError = true);
          _shakeField(_emailShakeController);
        }
      ),
      (
        _passwordController.text.isEmpty || _passwordController.text.length < 8,
        () {
          setState(() => _passwordError = true);
          _shakeField(_passwordShakeController);
        }
      ),
      (
        _confirmPasswordController.text.isEmpty ||
            _confirmPasswordController.text != _passwordController.text,
        () {
          setState(() => _confirmPasswordError = true);
          _shakeField(_confirmPasswordShakeController);
        }
      ),
      (
        _securityCheckController.text.isEmpty ||
            _securityCheckController.text.toUpperCase() != 'PHPTRAVELS',
        () {
          setState(() => _securityCheckError = true);
          _shakeField(_securityCheckShakeController);
        }
      ),
    ];

    for (var validation in validations) {
      if (validation.$1) {
        validation.$2();
        hasError = true;
      }
    }

    return hasError;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  double _calculateShakeOffset(AnimationController controller) {
    final tween = Tween<double>(begin: -8, end: 8);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    return tween.transform(animation.value) * (controller.value < 0.5 ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue Curved Background Header
            Stack(
              children: [
                ClipPath(
                  clipper: _WaveClipper(),
                  child: Container(
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                const Color(0xFF1E3A8A),
                                const Color(0xFF2563EB),
                              ]
                            : [
                                AppColors.primaryBlue,
                                AppColors.primaryBlue.withOpacity(0.85),
                              ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative patterns
                        Positioned(
                          top: 60,
                          right: 40,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 80,
                          left: 30,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 120,
                          right: 100,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Back Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Form Content
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sign up Title
                    const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // First Name Field
                    _buildInputField(
                      controller: _firstNameController,
                      shakeController: _firstNameShakeController,
                      label: 'First Name',
                      hint: 'Enter your first name',
                      icon: Icons.person_outline_rounded,
                      hasError: _firstNameError,
                      onChanged: (value) {
                        if (_firstNameError && value.isNotEmpty) {
                          setState(() => _firstNameError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name Field
                    _buildInputField(
                      controller: _lastNameController,
                      shakeController: _lastNameShakeController,
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      icon: Icons.person_outline_rounded,
                      hasError: _lastNameError,
                      onChanged: (value) {
                        if (_lastNameError && value.isNotEmpty) {
                          setState(() => _lastNameError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    _buildInputField(
                      controller: _emailController,
                      shakeController: _emailShakeController,
                      label: 'Email',
                      hint: 'your.email@example.com',
                      icon: Icons.email_outlined,
                      hasError: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        if (_emailError) {
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (value.isNotEmpty && emailRegex.hasMatch(value)) {
                            setState(() => _emailError = false);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildInputField(
                      controller: _passwordController,
                      shakeController: _passwordShakeController,
                      label: 'Password',
                      hint: 'Minimum 8 characters',
                      icon: Icons.lock_outline_rounded,
                      hasError: _passwordError,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        splashRadius: 20,
                      ),
                      onChanged: (value) {
                        if (_passwordError && value.length >= 8) {
                          setState(() => _passwordError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    _buildInputField(
                      controller: _confirmPasswordController,
                      shakeController: _confirmPasswordShakeController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline_rounded,
                      hasError: _confirmPasswordError,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        splashRadius: 20,
                      ),
                      onChanged: (value) {
                        if (_confirmPasswordError &&
                            value.isNotEmpty &&
                            value == _passwordController.text) {
                          setState(() => _confirmPasswordError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Security Check Field
                    _buildInputField(
                      controller: _securityCheckController,
                      shakeController: _securityCheckShakeController,
                      label: 'Security Check',
                      hint: 'Type: PHPTRAVELS',
                      icon: Icons.verified_outlined,
                      hasError: _securityCheckError,
                      onChanged: (value) {
                        if (_securityCheckError &&
                            value.toUpperCase() == 'PHPTRAVELS') {
                          setState(() => _securityCheckError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Terms Agreement
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            activeColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A5568),
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'By creating an account, you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' and ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Create Account Button
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            authProvider.isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required AnimationController shakeController,
    required String label,
    required String hint,
    required IconData icon,
    required bool hasError,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return AnimatedBuilder(
      animation: shakeController,
      builder: (context, child) {
        final offset = _calculateShakeOffset(shakeController);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A5568),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        hasError ? AppColors.errorRed : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        icon,
                        color: hasError
                            ? AppColors.errorRed
                            : const Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        obscureText: obscureText,
                        keyboardType: keyboardType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1A202C),
                        ),
                        onChanged: onChanged,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFCBD5E0),
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 0,
                          ),
                          isDense: true,
                          suffixIcon: suffixIcon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80);

    // Create smooth wave curve
    var firstControlPoint = Offset(size.width / 4, size.height - 40);
    var firstEndPoint = Offset(size.width / 2, size.height - 60);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
