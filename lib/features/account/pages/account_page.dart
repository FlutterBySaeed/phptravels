import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/theme_provider.dart';
import 'package:phptravels/providers/language_provider.dart';
import 'package:phptravels/providers/currency_provider.dart';
import 'package:phptravels/providers/auth_provider.dart';
import 'package:phptravels/features/account/pages/display_settings_page.dart';
import 'package:phptravels/features/account/pages/payment_methods_page.dart';
import 'package:phptravels/features/account/pages/language_settings_page.dart';
import 'package:phptravels/features/account/pages/currency_settings_page.dart';
import 'package:phptravels/features/account/pages/login_page.dart';
import 'package:phptravels/features/account/pages/signup_page.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  String _selectedCountry = 'Pakistan';

  String _getLanguageDisplayName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'es':
        return l10n.spanish;
      case 'ar':
        return l10n.arabic;
      default:
        return l10n.english;
    }
  }

  String _getCurrentThemeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    switch (themeProvider.themeMode) {
      case AppThemeMode.light:
        return l10n.light;
      case AppThemeMode.dark:
        return l10n.dark;
      case AppThemeMode.system:
        return l10n.automatic;
    }
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country.name;
        });
      },
      countryListTheme: CountryListThemeData(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.8,
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildLoginPrompt(authProvider),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildMyProfile(context),
                      _buildDivider(context),
                      _buildMyTrips(context),
                      _buildDivider(context),
                      _buildBusinessTravel(context),
                      _buildDivider(context),
                      _buildSettings(context),
                      _buildDivider(context),
                      _buildHelpCenter(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt(AuthProvider authProvider) {
    if (authProvider.isAuthenticated && authProvider.user != null) {
      final user = authProvider.user!;
      final name = user['name']?.toString() ?? 'Traveler';
      final email = user['email']?.toString() ?? '';

      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding:
            const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.white.withOpacity(0.9),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hi, $name!',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        await authProvider.logout();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: 10,
            bottom: 0,
            child: Center(
              child: Icon(
                LucideIcons.plane,
                size: 115,
                color: AppColors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Inner rounded white container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                height: 30, // Adjust height as needed
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          // Your content positioned above the inner rounded part
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 30), // Match the height above
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 65,
                  bottom: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ... your existing content
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Color.fromARGB(255, 209, 215, 228),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).readyToStart,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromARGB(158, 255, 255, 255),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Transform.scale(
                        scale: 0.85,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () {
                                  final auth = Provider.of<AuthProvider>(
                                      context,
                                      listen: false);
                                  if (auth.isAuthenticated) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('You are already signed in'),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(91, 229, 231, 235),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context).login,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () {
                                  final auth = Provider.of<AuthProvider>(
                                      context,
                                      listen: false);
                                  if (auth.isAuthenticated) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('You are already signed in'),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const SignUpPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(91, 229, 231, 235),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context).signUp,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Inter',
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 6,
        color: Colors.black,
      ),
    );
  }

  Widget _buildMyProfile(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              l10n.myProfile,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          _buildMenuCard(context, LucideIcons.user, l10n.personalInfo),
          const SizedBox(height: 0),
          _buildMenuCardWithAction(
            context,
            LucideIcons.creditCard,
            l10n.preferredPaymentMethod,
            onTap: _showPaymentMethodSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildMyTrips(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myTrips,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          _buildMenuCard(context, LucideIcons.building2, l10n.hotelBookings),
          const SizedBox(height: 2),
          _buildMenuCard(context, LucideIcons.plane, l10n.flightBookings),
          const SizedBox(height: 2),
          _buildMenuCard(
            context,
            LucideIcons.users,
            l10n.addEditTraveller,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTravel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.businessTravel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          _buildBusinessCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.plus,
                  size: 26,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PHPTravels',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            l10n.newLabel,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.businessTravelDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Consumer2<LanguageProvider, CurrencyProvider>(
      builder: (context, languageProvider, currencyProvider, child) {
        final l10n = AppLocalizations.of(context);
        return Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              _buildSettingRowWithAction(
                context,
                LucideIcons.globe,
                l10n.language,
                _getLanguageDisplayName(
                    context, languageProvider.currentLanguageCode),
                onTap: _showLanguageSettings,
              ),
              const SizedBox(height: 2),
              _buildSettingRowWithAction(
                context,
                LucideIcons.wallet,
                l10n.currency,
                currencyProvider.currencyCode,
                onTap: _showCurrencySettings,
              ),
              const SizedBox(height: 2),
              _buildSettingRowWithAction(
                context,
                LucideIcons.globe,
                l10n.region,
                _selectedCountry,
                onTap: () => _showCountryPicker(context),
              ),
              const SizedBox(height: 2),
              _buildSettingRowWithAction(
                context,
                LucideIcons.moon,
                l10n.display,
                _getCurrentThemeLabel(context),
                onTap: _showDisplaySettings,
              ),
              const SizedBox(height: 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpCenter(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.helpCenter,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          _buildMenuCard(context, Icons.help_outline, l10n.faqs),
          const SizedBox(height: 2),
          _buildMenuCard(
            context,
            LucideIcons.headphones,
            l10n.contactUs,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(icon,
                    size: 24, color: Theme.of(context).iconTheme.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCardWithAction(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(icon,
                    size: 24, color: Theme.of(context).iconTheme.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRowWithAction(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(icon,
                    size: 24, color: Theme.of(context).iconTheme.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: const PaymentPickerBottomSheet(),
      ),
    );
  }

  void _showLanguageSettings() {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: LanguageSettingsSheet(
          currentLanguage: languageProvider.currentLanguageCode,
          onLanguageChanged: (languageCode) {
            languageProvider.setLanguage(languageCode);
          },
        ),
      ),
    );
  }

  void _showDisplaySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: const DisplaySettingsSheet(),
      ),
    );
  }

  void _showCurrencySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: const CurrencySettingsSheet(),
      ),
    );
  }
}
