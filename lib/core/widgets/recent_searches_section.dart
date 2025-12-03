// lib/widgets/recent_searches_section.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/l10n/app_localizations.dart';

import 'package:phptravels/core/services/search_history_model.dart';
import 'package:phptravels/core/services/search_history_service.dart';

class RecentSearchesSection extends StatefulWidget {
  final Function(FlightSearchHistory) onSearchSelected;

  const RecentSearchesSection({
    super.key,
    required this.onSearchSelected,
  });

  @override
  State<RecentSearchesSection> createState() => _RecentSearchesSectionState();
}

class _RecentSearchesSectionState extends State<RecentSearchesSection> {
  late Future<List<FlightSearchHistory>> _searchHistory;

  @override
  void initState() {
    super.initState();
    _searchHistory = SearchHistoryService.getSearchHistory();
  }

  void _refreshHistory() {
    setState(() {
      _searchHistory = SearchHistoryService.getSearchHistory();
    });
  }

  void _deleteSearch(String id) {
    SearchHistoryService.deleteSearch(id).then((_) {
      _refreshHistory();
    });
  }

  void _clearAllHistory() {
    SearchHistoryService.clearHistory().then((_) {
      _refreshHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlightSearchHistory>>(
      future: _searchHistory,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final searches = snapshot.data!;
        final l10n = AppLocalizations.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recentSearchesTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearAllHistory,
                    child: Text(
                      l10n.clearAll,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searches.length,
              itemBuilder: (context, index) => _buildSearchItem(
                context,
                searches[index],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchItem(BuildContext context, FlightSearchHistory search) {
    return GestureDetector(
      onTap: () => widget.onSearchSelected(search),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    search.displayRoute,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        search.formattedDateRange,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 12,
                        color: Theme.of(context).dividerColor,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.users,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${search.passengers}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _deleteSearch(search.id),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.x,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
