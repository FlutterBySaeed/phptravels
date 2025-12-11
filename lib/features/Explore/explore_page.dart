import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import 'explore_search_page.dart';
import 'trip_ideas_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _selectedCity = 'Lahore';

  final List<_Destination> _popularRow1 = const [
    _Destination(
      city: 'Karachi',
      country: 'Pakistan',
      rawPricePKR: 36700, // ~US$ 132
      imageUrl:
          'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400',
    ),
    _Destination(
      city: 'Ras al Khaimah',
      country: 'United Arab Emirates',
      rawPricePKR: 48600, // ~US$ 175
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
    ),
    _Destination(
      city: 'Quetta',
      country: 'Pakistan',
      rawPricePKR: 42500, // ~US$ 153
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    ),
  ];

  final List<_Destination> _popularRow2 = const [
    _Destination(
      city: 'Skardu',
      country: 'Pakistan',
      rawPricePKR: 52200, // ~US$ 188
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    ),
    _Destination(
      city: 'Dubai',
      country: 'United Arab Emirates',
      rawPricePKR: 54200, // ~US$ 195
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
    ),
    _Destination(
      city: 'Istanbul',
      country: 'Turkey',
      rawPricePKR: 61100, // ~US$ 220
      imageUrl:
          'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=400',
    ),
  ];

  final List<_Destination> _visaFreeRow1 = const [
    _Destination(
      city: 'Malaysia',
      country: 'Visa-free',
      rawPricePKR: 126400, // ~US$ 455
      imageUrl:
          'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?w=400',
    ),
    _Destination(
      city: 'Morocco',
      country: 'Visa-free',
      rawPricePKR: 187000, // ~US$ 673
      imageUrl:
          'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=400',
    ),
  ];

  final List<_Destination> _visaFreeRow2 = const [
    _Destination(
      city: 'Indonesia',
      country: 'Visa-free',
      rawPricePKR: 157000, // ~US$ 565
      imageUrl:
          'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400',
    ),
    _Destination(
      city: 'Thailand',
      country: 'Visa-free',
      rawPricePKR: 144500, // ~US$ 520
      imageUrl:
          'https://images.unsplash.com/photo-1494949360228-4e9bde560065?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHRoYWlsYW5kfGVufDB8fDB8fHww',
    ),
  ];

  final List<_Airline> _popularAirlines = const [
    _Airline(name: 'Pakistan International', logo: '🛫'),
    _Airline(name: 'Saudia', logo: '✈️'),
    _Airline(name: 'Emirates', logo: '🛩️'),
    _Airline(name: 'Airblue', logo: '🛫'),
    _Airline(name: 'Air Arabia', logo: '✈️'),
    _Airline(name: 'Qatar Airways', logo: '🛩️'),
  ];

  final List<_TripIdea> _tripIdeas = const [
    _TripIdea(
      title: 'Halal-friendly',
      description: '87 Destinations from',
      rawPricePKR: 55300, // ~US$ 199
      imageUrls: [
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
        'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      ],
    ),
    _TripIdea(
      title: 'Nature',
      description: '25 Destinations from',
      rawPricePKR: 89400, // ~US$ 322
      imageUrls: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400',
        'https://images.unsplash.com/photo-1505765050516-f72dcac9c60b?w=400',
      ],
    ),
    _TripIdea(
      title: 'Culture',
      description: '45 Destinations from',
      rawPricePKR: 68000, // ~US$ 245
      imageUrls: [
        'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=400',
        'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?w=400',
        'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=400',
      ],
    ),
    _TripIdea(
      title: 'Romantic',
      description: '32 Destinations from',
      rawPricePKR: 80200, // ~US$ 289
      imageUrls: [
        'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?w=400',
        'https://images.unsplash.com/photo-1558005530-a7958896ec60?w=400',
        'https://images.unsplash.com/photo-1503891617560-5b8c2e28cbf6?w=400',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          'Explore',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.iconTheme.color),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Location chip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExploreSearchPage(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedCity = result['city'] ?? 'Lahore';
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: primaryColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'From $_selectedCity',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Popular Destinations Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popular Destinations',
                        style:
                            theme.textTheme.titleMedium?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estimated lowest fares ',
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: theme.iconTheme.color),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _horizontalDestinations(context, _popularRow1, primaryColor),
            const SizedBox(height: 12),
            _horizontalDestinations(context, _popularRow2, primaryColor),

            const SizedBox(height: 32),

            // Featured Destinations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Featured Destinations',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildFeaturedCard(context, primaryColor),
            ),

            const SizedBox(height: 32),

            // Plan Your Getaway
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Your Getaway',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Our suggestions to maximize your public holidays',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 400,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final now = DateTime.now();
                  final monthDate = DateTime(now.year, now.month + index, 1);
                  return Padding(
                    padding: EdgeInsets.only(right: index < 11 ? 16 : 0),
                    child: _buildCalendarCard(context, monthDate),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Visa-Free Regions section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visa-Free Regions',
                        style:
                            theme.textTheme.titleMedium?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Easier trips without visa hassle',
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: theme.iconTheme.color),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _horizontalDestinations(
              context,
              _visaFreeRow1,
              primaryColor,
            ),
            const SizedBox(height: 12),
            _horizontalDestinations(
              context,
              _visaFreeRow2,
              primaryColor,
            ),
            const SizedBox(height: 40),

            // Popular Airlines section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Popular Airlines',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _popularAirlines.length,
                itemBuilder: (context, index) {
                  final airline = _popularAirlines[index];
                  return _buildAirlineCard(context, airline);
                },
              ),
            ),

            const SizedBox(height: 32),

            // Trip Ideas section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trip Ideas',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
                  ),
                  Icon(Icons.chevron_right, color: theme.iconTheme.color),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tripIdeas.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final trip = _tripIdeas[index];
                  return _buildTripIdeaCard(context, trip);
                },
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _horizontalDestinations(
    BuildContext context,
    List<_Destination> destinations,
    Color priceColor,
  ) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final d = destinations[index];
          return _buildDestinationCard(
            context,
            d.city,
            d.country,
            d.rawPricePKR,
            d.imageUrl,
            priceColor,
          );
        },
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    String city,
    String country,
    double rawPricePKR,
    String imageUrl,
    Color priceColor,
  ) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return SizedBox(
      width: 160,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay text
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          country,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Price section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Round-trip from',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyProvider.formatPrice(rawPricePKR, compact: true),
                    style: TextStyle(
                      color: priceColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Color priceColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    const featuredPricePKR = 56700.0; // ~US$ 204

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo and title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saudi Logo Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Saudi',
                      style: TextStyle(
                        color: Colors.pink[300],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Saudi',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This Land is Calling you to discover a story where legends meet wonders.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Featured Image
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Price section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '185 Destinations from',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyProvider.formatPrice(featuredPricePKR, compact: true),
                  style: TextStyle(
                    color: priceColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context, DateTime monthDate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return Container(
      width: 290,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Month and Year
          Text(
            '${monthNames[monthDate.month - 1]} ${monthDate.year}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
          ),
          const SizedBox(height: 16),

          // Legend
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(context, Icons.circle_outlined, 'Take Leave',
                      Colors.green),
                  const SizedBox(width: 24),
                  _buildLegendItem(
                      context, Icons.ac_unit, 'Public Holiday', Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                  context, Icons.circle, 'Suggested Itinerary', Colors.grey),
            ],
          ),

          const SizedBox(height: 20),

          // Calendar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayHeader(context, 'Mon'),
              _buildDayHeader(context, 'Tue'),
              _buildDayHeader(context, 'Wed'),
              _buildDayHeader(context, 'Thu'),
              _buildDayHeader(context, 'Fri'),
              _buildDayHeader(context, 'Sat'),
              _buildDayHeader(context, 'Sun'),
            ],
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          SizedBox(
            height: 200,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
              ),
              itemCount: 35, // 5 weeks max
              itemBuilder: (context, index) {
                final dayNumber = index - startWeekday + 2;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox();
                }

                final isWeekend = (index % 7 == 5 || index % 7 == 6);

                return Center(
                  child: Text(
                    '$dayNumber',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: isWeekend
                              ? Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.5)
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Bottom text
          Text(
            'Choose any dates to plan holidays',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(BuildContext context, String day) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          day,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      ),
    );
  }

  Widget _buildAirlineCard(BuildContext context, _Airline airline) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            airline.logo,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              airline.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripIdeaCard(BuildContext context, _TripIdea trip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripIdeasPage(
              initialCategory: trip.title,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        height: 310,
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collage Image Layout
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  // Large image on the left
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(trip.imageUrls[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Two smaller images stacked on the right
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(trip.imageUrls[1]),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(trip.imageUrls[2]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyProvider.formatPrice(trip.rawPricePKR,
                        compact: true),
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Destination {
  final String city;
  final String country;
  final double rawPricePKR;
  final String imageUrl;
  const _Destination({
    required this.city,
    required this.country,
    required this.rawPricePKR,
    required this.imageUrl,
  });
}

class _Airline {
  final String name;
  final String logo;
  const _Airline({
    required this.name,
    required this.logo,
  });
}

class _TripIdea {
  final String title;
  final String description;
  final double rawPricePKR;
  final List<String> imageUrls;
  const _TripIdea({
    required this.title,
    required this.description,
    required this.rawPricePKR,
    required this.imageUrls,
  });
}
