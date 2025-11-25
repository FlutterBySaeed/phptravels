import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/theme_provider.dart';
import 'package:phptravels/THEMES/app_theme.dart'; 
import 'package:phptravels/l10n/app_localizations.dart';

class DisplaySettingsSheet extends StatelessWidget {
  const DisplaySettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final l10n = AppLocalizations.of(context);
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, l10n),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reordered options: Automatic first, then Light, then Dark
                      _buildThemeOption(
                        context,
                        title: l10n.automatic,
                        subtitle: l10n.followSystemSettings,
                        icon: LucideIcons.settings2,
                        mode: AppThemeMode.system,
                        isSelected:
                            themeProvider.themeMode == AppThemeMode.system,
                        onTap: () => _changeThemeAndRestart(
                          context, 
                          AppThemeMode.system,
                          themeProvider,
                        ),
                      ),
                      _buildThemeOption(
                        context,
                        title: l10n.light,
                        subtitle: l10n.lightDescription,
                        icon: LucideIcons.sun,
                        mode: AppThemeMode.light,
                        isSelected:
                            themeProvider.themeMode == AppThemeMode.light,
                        onTap: () => _changeThemeAndRestart(
                          context, 
                          AppThemeMode.light,
                          themeProvider,
                        ),
                      ),
                      _buildThemeOption(
                        context,
                        title: l10n.dark,
                        subtitle: l10n.darkDescription,
                        icon: LucideIcons.moon,
                        mode: AppThemeMode.dark,
                        isSelected:
                            themeProvider.themeMode == AppThemeMode.dark,
                        onTap: () => _changeThemeAndRestart(
                          context, 
                          AppThemeMode.dark,
                          themeProvider,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeThemeAndRestart(BuildContext context, AppThemeMode mode, ThemeProvider themeProvider) {
    themeProvider.setThemeMode(mode);
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), // Added top padding for space
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back, 
                size: 20, 
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Text(
            l10n.appearance,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 40), // For balance
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required AppThemeMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Icon without container/box
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.primaryBlue
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? AppColors.primaryBlue 
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected 
                                ? AppColors.primaryBlue.withOpacity(0.7)
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
              // Blue tick only for selected option
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 24,
                  color: AppColors.primaryBlue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}