import 'package:flutter/material.dart';
import 'package:phptravels/core/theme/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class LanguageSettingsSheet extends StatefulWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSettingsSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageSettingsSheet> createState() => _LanguageSettingsSheetState();
}

class _LanguageSettingsSheetState extends State<LanguageSettingsSheet> {
  late TextEditingController _searchController;
  late String _selectedLanguage;
  List<Map<String, String>> _filteredLanguages = [];

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en', 'displayCode': 'EN'},
    {'name': 'Español', 'code': 'es', 'displayCode': 'ES'},
    {'name': 'العربية', 'code': 'ar', 'displayCode': 'AR'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
    _searchController = TextEditingController();
    _filteredLanguages = languages;
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLanguages = languages
          .where((lang) =>
              lang['name']!.toLowerCase().contains(query) ||
              lang['code']!.toLowerCase().contains(query) ||
              lang['displayCode']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          _buildSearchBar(context, l10n),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._filteredLanguages.map((language) {
                    final isSelected = _selectedLanguage == language['code'];
                    return _buildLanguageOption(
                      context,
                      _resolveLanguageName(
                          language['name']!, language['code']!, l10n),
                      language['code']!,
                      language['displayCode']!,
                      isSelected,
                      () {
                        setState(() {
                          _selectedLanguage = language['code']!;
                        });
                        widget.onLanguageChanged(language['code']!);
                        Navigator.pop(context);
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveLanguageName(
      String fallback, String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'es':
        return l10n.spanish;
      case 'ar':
        return l10n.arabic;
      default:
        return fallback;
    }
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
            l10n.language,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchLanguage,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                  },
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
              Colors.grey.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String languageCode,
    String displayCode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayCode,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
