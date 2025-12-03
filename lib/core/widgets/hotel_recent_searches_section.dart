import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:phptravels/core/services/hotel_search_history_model.dart';
import 'package:phptravels/core/services/search_history_service.dart';

class HotelRecentSearchesSection extends StatefulWidget {
  final Function(HotelSearchHistory) onSearchSelected;

  const HotelRecentSearchesSection({
    super.key,
    required this.onSearchSelected,
  });

  @override
  State<HotelRecentSearchesSection> createState() =>
      _HotelRecentSearchesSectionState();
}

class _HotelRecentSearchesSectionState
    extends State<HotelRecentSearchesSection> {
  late Future<List<HotelSearchHistory>> _searchHistory;

  @override
  void initState() {
    super.initState();
    _searchHistory = SearchHistoryService.getHotelSearchHistory();
  }

  void _refreshHistory() {
    setState(() {
      _searchHistory = SearchHistoryService.getHotelSearchHistory();
    });
  }

  void _deleteSearch(String id) {
    SearchHistoryService.deleteHotelSearch(id).then((_) {
      _refreshHistory();
    });
  }

  void _clearAllHistory() {
    SearchHistoryService.clearHotelHistory().then((_) {
      _refreshHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HotelSearchHistory>>(
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
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
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

  Widget _buildSearchItem(BuildContext context, HotelSearchHistory search) {
    return GestureDetector(
      onTap: () => widget.onSearchSelected(search),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    search.displayLocation,
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
                        Icons.person_outline,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${search.guests}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.door_front_door_outlined,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${search.rooms}',
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
