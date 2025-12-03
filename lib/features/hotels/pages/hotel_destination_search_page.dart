import 'package:flutter/material.dart';
import 'package:phptravels/core/services/airport_service.dart';
import 'package:phptravels/core/services/hotel_search_history_model.dart';
import 'package:phptravels/core/services/search_history_service.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class HotelDestinationSearchPage extends StatefulWidget {
  final Function(String city, String country) onDestinationSelected;
  const HotelDestinationSearchPage(
      {super.key, required this.onDestinationSelected});

  @override
  State<HotelDestinationSearchPage> createState() =>
      _HotelDestinationSearchPageState();
}

class _HotelDestinationSearchPageState
    extends State<HotelDestinationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _recentDestinations = [];

  // Popular cities
  final List<Map<String, dynamic>> _popularCities = [
    {'city': 'Dubai', 'country': 'United Arab Emirates', 'code': 'DXB'},
    {'city': 'London', 'country': 'United Kingdom', 'code': 'LON'},
    {'city': 'New York', 'country': 'United States', 'code': 'NYC'},
    {'city': 'Paris', 'country': 'France', 'code': 'PAR'},
    {'city': 'Tokyo', 'country': 'Japan', 'code': 'TYO'},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
    _loadRecentDestinations();
  }

  Future<void> _loadRecentDestinations() async {
    final hotelSearches = await SearchHistoryService.getHotelSearchHistory();

    // Extract unique locations from hotel search history
    final Map<String, Map<String, dynamic>> uniqueLocations = {};
    for (var search in hotelSearches) {
      final parts = search.location.split(', ');
      final city = parts.isNotEmpty ? parts[0] : search.location;
      final country = parts.length > 1 ? parts[1] : '';
      final key = '${city}_$country';

      if (!uniqueLocations.containsKey(key)) {
        uniqueLocations[key] = {
          'city': city,
          'country': country,
          'code': null,
        };
      }
    }

    setState(() {
      _recentDestinations = uniqueLocations.values.toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.length >= 2) {
      setState(() {
        _isLoading = true;
      });

      final results = await AirportService.fetchAirports(query);

      // Group by city to show unique cities only (not individual airports)
      final Map<String, Map<String, dynamic>> uniqueCities = {};
      for (var airport in results) {
        final city = airport['city'] ?? '';
        final country = airport['country'] ?? '';
        final key = '$city|$country'; // Unique key for city+country combination

        // Only add if we haven't seen this city yet
        if (city.isNotEmpty && !uniqueCities.containsKey(key)) {
          uniqueCities[key] = airport;
        }
      }

      setState(() {
        _searchResults = uniqueCities.values.toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
  }

  void _selectDestination(Map<String, dynamic> city) {
    final cityName = city['city'] ?? '';
    final country = city['country'] ?? '';
    widget.onDestinationSelected(cityName, country);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar with close button and search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            children: [
              // Close button
              IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              // Search field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context).whereTo,
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  onChanged: _performSearch,
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Theme.of(context).hintColor,
                  ),
                  onPressed: _clearSearch,
                ),
            ],
          ),
        ),
        // Divider
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        // Content
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    // Show search results if user is searching
    if (_searchController.text.length >= 2) {
      return _buildSearchResults(context);
    }

    // Otherwise show popular cities
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Recently searched section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppLocalizations.of(context).recentlySearchedCities,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Recent destinations from hotel search history
        if (_recentDestinations.isNotEmpty)
          ..._recentDestinations.map((cityMap) {
            return _buildCityItem(context, cityMap);
          }),
        if (_recentDestinations.isNotEmpty) const SizedBox(height: 8),
        const SizedBox(height: 8),
        // Popular cities section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppLocalizations.of(context).popularCities,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ..._popularCities.map((city) => _buildCityItem(context, city)),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.length >= 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noCitiesFound,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).typeAtLeastTwoChars,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return _buildCityItem(context, city);
      },
    );
  }

  Widget _buildCityItem(BuildContext context, Map<String, dynamic> city) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDestination(city),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Location pin icon
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 24,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // City name and country
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city['city'] ?? '',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          city['country'] ?? '',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Country code in gray box
                  if (city['code'] != null && city['code'].isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        city['code'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Light divider between items
        Padding(
          padding: const EdgeInsets.only(left: 68),
          child: Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
        ),
      ],
    );
  }
}
