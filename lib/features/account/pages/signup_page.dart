import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/account/pages/login_page.dart';
import 'package:phptravels/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/l10n/app_localizations.dart';

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

  bool _handledAuthRedirect = false;

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
      _showSnackBar(AppLocalizations.of(context).agreeToTermsError, Colors.red);
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
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (_) {
      if (!mounted) return;
      final errorMessage =
          authProvider.error ?? AppLocalizations.of(context).signupFailed;
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
    final l10n = AppLocalizations.of(context);

    if (authProvider.isAuthenticated && !_handledAuthRedirect) {
      _handledAuthRedirect = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button Section
            Container(
                child: Transform.translate(
              offset: const Offset(-3, 0),
              child: Container(
                width: double.infinity,
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_forward
                          : Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ),
            )),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-9, 0),
                          child: Text(
                            l10n.signUpTitle,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // First Name Label
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Text(
                            l10n.firstName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // First Name Field
                      _buildInputField(
                        controller: _firstNameController,
                        shakeController: _firstNameShakeController,
                        hint: l10n.firstNamePlaceholder,
                        icon: Icons.person_outline_rounded,
                        hasError: _firstNameError,
                        onChanged: (value) {
                          if (_firstNameError && value.isNotEmpty) {
                            setState(() => _firstNameError = false);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Last Name Label
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Text(
                            l10n.lastName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Last Name Field
                      _buildInputField(
                        controller: _lastNameController,
                        shakeController: _lastNameShakeController,
                        hint: l10n.lastNamePlaceholder,
                        icon: Icons.person_outline_rounded,
                        hasError: _lastNameError,
                        onChanged: (value) {
                          if (_lastNameError && value.isNotEmpty) {
                            setState(() => _lastNameError = false);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Label
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Text(
                            l10n.email,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email Field
                      _buildInputField(
                        controller: _emailController,
                        shakeController: _emailShakeController,
                        hint: l10n.emailPlaceholder,
                        icon: Icons.email_outlined,
                        hasError: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (_emailError) {
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (value.isNotEmpty &&
                                emailRegex.hasMatch(value)) {
                              setState(() => _emailError = false);
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Label
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Text(
                            l10n.password,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Password Field
                      _buildInputField(
                        controller: _passwordController,
                        shakeController: _passwordShakeController,
                        hint: l10n.minimumCharacters,
                        icon: Icons.lock_outline_rounded,
                        hasError: _passwordError,
                        obscureText: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        onChanged: (value) {
                          if (_passwordError && value.length >= 8) {
                            setState(() => _passwordError = false);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Label
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Text(
                            l10n.confirmPassword,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Confirm Password Field
                      _buildInputField(
                        controller: _confirmPasswordController,
                        shakeController: _confirmPasswordShakeController,
                        hint: l10n.confirmPasswordPlaceholder,
                        icon: Icons.lock_outline_rounded,
                        hasError: _confirmPasswordError,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          child: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
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

                      // Security Check Label
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Text(
                            l10n.securityCheck,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Security Check Field
                      _buildInputField(
                        controller: _securityCheckController,
                        shakeController: _securityCheckShakeController,
                        hint: l10n.securityCheckPlaceholder,
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
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-6, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
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
                                  visualDensity: VisualDensity.compact,
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
                                      TextSpan(
                                        text: '${l10n.agreeToTermsText} ',
                                      ),
                                      TextSpan(
                                        text: l10n.termsAndConditions,
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ${l10n.and} ',
                                      ),
                                      TextSpan(
                                        text: l10n.privacyPolicy,
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
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Create Account Button
                      Container(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.primaryBlue.withOpacity(0.6),
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
                              : Text(
                                  l10n.signUpButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login link
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${l10n.alreadyHaveAccount} ',
                              style: const TextStyle(
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
                                l10n.signIn,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
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
        return Transform.translate(
          offset: Offset(_calculateShakeOffset(shakeController), 0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? AppColors.errorRed : const Color(0xFFD0D5DD),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(left: 14, right: 12),
                  child: Icon(
                    icon,
                    color: hasError ? AppColors.errorRed : Colors.black,
                    size: 20,
                  ),
                ),

                // Text Field
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF101828),
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF98A2B3),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),

                // Suffix Icon
                if (suffixIcon != null)
                  Container(
                    margin: const EdgeInsets.only(right: 14),
                    child: suffixIcon,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
