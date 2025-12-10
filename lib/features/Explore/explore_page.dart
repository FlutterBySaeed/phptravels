import 'package:flutter/material.dart';
import 'explore_search_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchIcon = false;
  String _selectedCity = 'Lahore';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Show search icon when scrolled past location selector
      final shouldShow =
          _scrollController.hasClients && _scrollController.offset > 60;
      if (shouldShow != _showSearchIcon) {
        setState(() {
          _showSearchIcon = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Collapsing App Bar - Title fixed, Location selector scrolls
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 12,
              shadowColor: Colors.black.withOpacity(0.25),
              forceElevated: true,
              pinned: true,
              floating: false,
              expandedHeight: 120,
              collapsedHeight: 60,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explore',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AnimatedOpacity(
                      opacity: _showSearchIcon ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.search,
                        size: 28,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExploreSearchPage(),
                              ),
                            );
                            if (result != null) {
                              // Handle selected location
                              setState(() {
                                _selectedCity = result['city'] ?? 'Lahore';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Theme.of(context).cardColor
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: primaryColor,
                                  size: 18,
                                ),
                                Expanded(
                                  child: Text(
                                    'From $_selectedCity',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.6),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),

            SliverToBoxAdapter(
              child: Padding(
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
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 20,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated lowest fares ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // First Row - Popular Destinations Horizontal Scroll
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDestinationCard(
                      context,
                      'Karachi',
                      'Pakistan',
                      'US\$ 132',
                      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400',
                      primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _buildDestinationCard(
                      context,
                      'Ras al Khaimah',
                      'United Arab Emirates',
                      'US\$ 175',
                      'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
                      primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _buildDestinationCard(
                      context,
                      'Quetta',
                      'Pakistan',
                      'US\$ 153',
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                      primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Second Row - Popular Destinations Horizontal Scroll
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDestinationCard(
                      context,
                      'Skardu',
                      'Pakistan',
                      'US\$ 188',
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                      primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _buildDestinationCard(
                      context,
                      'Dubai',
                      'United Arab Emirates',
                      'US\$ 195',
                      'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
                      primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _buildDestinationCard(
                      context,
                      'Istanbul',
                      'Turkey',
                      'US\$ 220',
                      'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=400',
                      primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Featured Destinations Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Featured Destinations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                      ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Saudi Arabia Featured Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFeaturedCard(context, primaryColor),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // Plan Your Getaway Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Your Getaway',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      'Our suggestions to maximize your public holidays',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Calendar Widget - Horizontal Scroll
            SliverToBoxAdapter(
              child: SizedBox(
                height: 395,
                child: ListView.builder(
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
            ),

            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    String city,
    String country,
    String price,
    String imageUrl,
    Color priceColor,
  ) {
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
                    price,
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
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
                  'US\$ 204',
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
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
}
