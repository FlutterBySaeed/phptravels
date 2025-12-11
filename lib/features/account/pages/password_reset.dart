import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/features/account/pages/login_page.dart';
import 'package:phptravels/features/account/pages/signup_page.dart';
import 'package:phptravels/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  bool _emailError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    setState(() => _emailError = false);

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (_emailController.text.isEmpty ||
        !emailRegex.hasMatch(_emailController.text)) {
      setState(() => _emailError = true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context
          .read<AuthProvider>()
          .resetPassword(_emailController.text.trim());

      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToSendReset),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppLocalizations.of(context).checkYourEmail,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 48,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).resetEmailSent,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context).backToLogin,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button Section
            Container(
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
                          offset: const Offset(-8, 0),
                          child: Text(
                            l10n.resetPasswordTitle,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Text(
                            l10n.resetPasswordSubtitle,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Label
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-7, 0),
                          child: Text(
                            l10n.emailAddress,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey[300]
                                  : const Color(0xFF344054),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email Field
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-9, 0),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _emailError
                                    ? AppColors.errorRed
                                    : isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFD0D5DD),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(
                                      left: 14, right: 12),
                                  child: Icon(
                                    Icons.email_outlined,
                                    color: _emailError
                                        ? AppColors.errorRed
                                        : const Color(0xFF667085),
                                    size: 20,
                                  ),
                                ),

                                // Text Field
                                Expanded(
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _emailError
                                          ? AppColors.errorRed
                                          : isDark
                                              ? Colors.white
                                              : const Color(0xFF101828),
                                    ),
                                    onChanged: (value) {
                                      if (_emailError && value.isNotEmpty) {
                                        final emailRegex = RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (emailRegex.hasMatch(value)) {
                                          setState(() => _emailError = false);
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: l10n.enterYourEmail,
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: _emailError
                                            ? AppColors.errorRed
                                                .withOpacity(0.6)
                                            : const Color(0xFF98A2B3),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (_emailError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            l10n.validEmailError,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Send Reset Instructions Button
                      Container(
                        child: Transform.translate(
                          offset: const Offset(-10, 0),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _handleResetPassword,
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
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.sendResetInstructions,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Remember your password? text
                      Center(
                        child: Text(
                          l10n.rememberYourPassword,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Back to Login Button (Outlined)
                          SizedBox(
                            width: 120,
                            height: 36,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                l10n.backToLogin,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Create Account Button (Filled)
                          SizedBox(
                            width: 120,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                l10n.createAccountButton,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
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
            ),
          ],
        ),
      ),
    );
  }
}
