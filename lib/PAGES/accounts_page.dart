import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkBlue = Color(0xFF1D4ED8);
  static const Color lightBlue = Color(0xFFE0F2FE);
  static const Color veryLightBlue = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF22C55E);
}

class AppTextStyles {
  static const TextStyle title = TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter');
  static const TextStyle bodySmall = TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter');
  static const TextStyle bodyMedium = TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Inter');
  static const TextStyle bodyMediumBold = TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter');
  static const TextStyle button = TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter', letterSpacing: 0.2);
}

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLoginPrompt(),
            
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildMyProfile(),
                  const SizedBox(height: 24), // PAGE BREAK AFTER SECTION
                  _buildMyTrips(),
                  const SizedBox(height: 24), // PAGE BREAK AFTER SECTION
                  _buildBusinessTravel(),
                  const SizedBox(height: 24), // PAGE BREAK AFTER SECTION
                  _buildSettings(),
                  const SizedBox(height: 24), // PAGE BREAK AFTER SECTION
                  _buildHelpCenter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
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
        
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 65, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                  child: Icon(Icons.person, size: 35, color: const Color.fromARGB(255, 209, 215, 228)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ready to start your next adventure? Login to book\nfaster with effortless form-filling.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                    child: SizedBox(
                      width: 145,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(91, 229, 231, 235),
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign up / Log in',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                          ),
                        ),
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
  );
}

  Widget _buildMyProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12), 
            child: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(LucideIcons.user, 'Personal Info'),
          const SizedBox(height: 4), 
          _buildMenuCard(LucideIcons.creditCard, 'Preferred Payment Method'),
        ],
      ),
    );
  }

  Widget _buildMyTrips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12), // RIGHT ALIGN WITH TITLE
            child: Text(
              'My Trips',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(LucideIcons.building2, 'Hotel Bookings'),
          const SizedBox(height: 4), // REDUCED GAP BETWEEN OPTIONS
          _buildMenuCard(LucideIcons.plane, 'Flight Bookings'),
          const SizedBox(height: 4), // REDUCED GAP BETWEEN OPTIONS
          _buildMenuCard(LucideIcons.users, 'Add/Edit Traveller'),
        ],
      ),
    );
  }

  Widget _buildBusinessTravel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12), // RIGHT ALIGN WITH TITLE
            child: Text(
              'Business Travel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildBusinessCard(),
        ],
      ),
    );
  }

  Widget _buildBusinessCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(LucideIcons.plus, size: 24, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'PHPTravels',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'New',
                            style: TextStyle(
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
                    const Text(
                      'Sign up for free on phptravels and enjoy\nexclusive savings on your corporate travel\nplans!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12), // RIGHT ALIGN WITH TITLE
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingRow(LucideIcons.globe, 'Language', 'English'),
          const SizedBox(height: 4), // REDUCED GAP BETWEEN OPTIONS
          _buildSettingRow(LucideIcons.wallet, 'Currency', 'PKR'),
          const SizedBox(height: 4), // REDUCED GAP BETWEEN OPTIONS
          _buildSettingRow(LucideIcons.globe, 'Region', 'Pakistan'),
          const SizedBox(height: 4), // REDUCED GAP BETWEEN OPTIONS
          _buildSettingRow(LucideIcons.moon, 'Display', 'Automatic'),
          const SizedBox(height: 4), // REDUCED GAP BETWEEN OPTIONS
          _buildMenuCard(LucideIcons.lock, 'Qibla & Prayer Times'),
        ],
      ),
    );
  }

  Widget _buildHelpCenter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12), // RIGHT ALIGN WITH TITLE
            child: Text(
              'Help Center',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(Icons.help_outline, 'FAQs'),
          const SizedBox(height: 4), // REDUCED GAP BETWEEN OPTIONS
          _buildMenuCard(LucideIcons.headphones, 'Contact Us'),
        ],
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String title, String value) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}