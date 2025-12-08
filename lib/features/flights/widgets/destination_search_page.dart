import 'package:flutter/material.dart';
import 'package:phptravels/core/services/airport_service.dart';
import 'package:phptravels/core/services/search_history_model.dart';
import 'package:phptravels/core/services/search_history_service.dart';
import 'package:phptravels/core/theme/app_theme.dart';

class DestinationSearchPage extends StatefulWidget {
  final Function(String destination, String city, String country)
      onDestinationSelected;
  const DestinationSearchPage({super.key, required this.onDestinationSelected});

  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _recentAirports = [];

  // Popular cities to show when no search
  final List<Map<String, dynamic>> _popularCities = [
    {
      'city': 'Jeddah',
      'country': 'Saudi Arabia',
      'code': 'JED',
      'loctype': 'city'
    },
    {
      'city': 'Abha',
      'country': 'Saudi Arabia',
      'code': 'AHB',
      'loctype': 'city'
    },
    {
      'city': 'Amsterdam',
      'country': 'Netherlands',
      'code': 'AMS',
      'loctype': 'city'
    },
    {
      'city': 'Abu Dhabi',
      'country': 'United Arab Emirates',
      'code': 'AUH',
      'loctype': 'city'
    },
    {'city': 'Baku', 'country': 'Azerbaijan', 'code': 'BAK', 'loctype': 'city'},
    {'city': 'Doha', 'country': 'Qatar', 'code': 'DOH', 'loctype': 'city'},
    {
      'city': 'Dubai',
      'country': 'United Arab Emirates',
      'code': 'DXB',
      'loctype': 'city'
    },
    {
      'city': 'Hail',
      'country': 'Saudi Arabia',
      'code': 'HAS',
      'loctype': 'city'
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
    _loadRecentAirports();
  }

  Future<void> _loadRecentAirports() async {
    final flightSearches = await SearchHistoryService.getSearchHistory();

    // Extract unique airports (from/to) from flight search history
    final Map<String, Map<String, dynamic>> uniqueAirports = {};
    for (var search in flightSearches) {
      // Extract airport codes from "City (CODE)" format
      final fromMatch = RegExp(r'\(([^)]+)\)$').firstMatch(search.from);
      final toMatch = RegExp(r'\(([^)]+)\)$').firstMatch(search.to);

      if (fromMatch != null) {
        final code = fromMatch.group(1)!;
        if (!uniqueAirports.containsKey(code)) {
          uniqueAirports[code] = {
            'city': search.from.replaceAll(RegExp(r'\s*\([^)]+\)$'), ''),
            'country': '', // We don't have country in flight history
            'code': code,
            'loctype': 'city',
          };
        }
      }

      if (toMatch != null) {
        final code = toMatch.group(1)!;
        if (!uniqueAirports.containsKey(code)) {
          uniqueAirports[code] = {
            'city': search.to.replaceAll(RegExp(r'\s*\([^)]+\)$'), ''),
            'country': '',
            'code': code,
            'loctype': 'city',
          };
        }
      }
    }

    setState(() {
      _recentAirports = uniqueAirports.values.toList().take(5).toList();
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
      setState(() {
        _searchResults = results;
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

  void _selectDestination(Map<String, dynamic> airport) {
    final destination = '${airport['city']} (${airport['code']})';
    final city = airport['city'] ?? '';
    final country = airport['country'] ?? '';
    widget.onDestinationSelected(destination, city, country);
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
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Where to?',
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
        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
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
      padding: EdgeInsets.only(
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        // Recently searched section (empty for now)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'RECENTLY SEARCHED AIRPORTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Recently searched airports from flight search history
        if (_recentAirports.isNotEmpty) ...[
          ..._recentAirports.map((airport) {
            return _buildAirportItem(context, airport);
          }),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        // Popular cities section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'POPULAR CITIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ..._popularCities.map((city) => _buildAirportItem(context, city)),
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
              Icons.flight_takeoff,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No airports found',
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
              'Type at least 2 characters to search',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Group results by city - show city first, then its airports
    final groupedResults = <Widget>[];
    final processedCities = <String>{};

    for (var result in _searchResults) {
      final city = result['city'] ?? '';
      final country = result['country'] ?? '';
      final code = result['code'] ?? '';
      final cityKey = '$city|$country';

      // Skip if we've already processed this city
      if (processedCities.contains(cityKey)) continue;
      processedCities.add(cityKey);

      // Create a city entry (non-airport version)
      final cityEntry = {
        'city': city,
        'country': country,
        'code': code,
        'loctype': 'city', // Mark as city, not airport
      };

      // Add city first
      groupedResults.add(_buildAirportItem(context, cityEntry));

      // Then add all airports for this city
      final airports = _searchResults
          .where((r) =>
              r['city'] == city &&
              r['country'] == country &&
              r['loctype'] == 'ap')
          .toList();

      for (var airport in airports) {
        groupedResults.add(_buildAirportItem(context, airport));
      }
    }

    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      children: groupedResults,
    );
  }

  Widget _buildAirportItem(BuildContext context, Map<String, dynamic> airport) {
    // Use loctype to determine if this is an airport ('ap') or city
    final bool isAirport = airport['loctype'] == 'ap';

    // For airports, show the actual airport name from fullName
    // For cities, just show the city name
    final String displayName = isAirport
        ? (airport['fullName'] ?? '${airport['city'] ?? ''} Airport')
        : (airport['city'] ?? '');

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDestination(airport),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon - location pin for city, airplane for airport
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      isAirport ? Icons.flight : Icons.location_on_outlined,
                      size: 22,
                      color:
                          Theme.of(context).iconTheme.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Airport/City name and country
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          airport['country'] ?? '',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Airport code in a gray container
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkBorder
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      airport['code'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Very light divider between items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 1,
            thickness: 0.3,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ],
    );
  }
}
