import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/account/pages/signup_page.dart';
import 'package:phptravels/features/account/pages/password_reset.dart';
import 'package:phptravels/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _emailError = false;
  bool _passwordError = false;

  late AnimationController _emailShakeController;
  late AnimationController _passwordShakeController;

  @override
  void initState() {
    super.initState();
    _emailShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _passwordShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailShakeController.dispose();
    _passwordShakeController.dispose();
    super.dispose();
  }

  void _shakeField(AnimationController controller) {
    controller.reset();
    controller.forward();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = false;
      _passwordError = false;
    });

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    bool hasError = false;

    if (_emailController.text.isEmpty ||
        !emailRegex.hasMatch(_emailController.text)) {
      setState(() => _emailError = true);
      _shakeField(_emailShakeController);
      hasError = true;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = true);
      _shakeField(_passwordShakeController);
      hasError = true;
    }

    if (hasError) return;

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) Navigator.of(context).maybePop();
    } catch (_) {
      final errorMessage =
          authProvider.error ?? AppLocalizations.of(context)!.loginFailed;
      _showSnackBar(errorMessage, AppColors.errorRed);
    }
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
        margin: const EdgeInsets.all(16),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button Section - Container with exact padding
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
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title - Container to control exact boundaries
                      Container(
                          child: Transform.translate(
                        offset: const Offset(-8, 0),
                        child: Text(
                          l10n.loginTitle,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                            height: 1.2,
                          ),
                        ),
                      )),
                      const SizedBox(height: 32),

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
                        hint: l10n.emailPlaceholder,
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        shakeController: _emailShakeController,
                        hasError: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (_emailError && value.isNotEmpty) {
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (emailRegex.hasMatch(value)) {
                              setState(() => _emailError = false);
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Label - Container to control exact boundaries
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
                        hint: l10n.passwordPlaceholder,
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        shakeController: _passwordShakeController,
                        hasError: _passwordError,
                        obscureText: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        onChanged: (value) {
                          if (_passwordError && value.isNotEmpty) {
                            setState(() => _passwordError = false);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Remember Me & Forgot Password - Container wrapper
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false),
                                  activeColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.rememberMe,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A5568),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ResetPasswordPage(),
                                  ),
                                ),
                                child: Text(
                                  l10n.forgotPassword,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button - Container wrapper
                      Container(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleLogin,
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
                                  l10n.loginButton,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Up Link - Container wrapper
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.dontHaveAccount,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              ),
                              child: Text(
                                l10n.signUpButton,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required AnimationController shakeController,
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
