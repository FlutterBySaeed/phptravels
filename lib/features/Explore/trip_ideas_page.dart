import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';

class TripIdeasPage extends StatefulWidget {
  final String? initialCategory;

  const TripIdeasPage({super.key, this.initialCategory});

  @override
  State<TripIdeasPage> createState() => _TripIdeasPageState();
}

class _TripIdeasPageState extends State<TripIdeasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'HALAL-FRIENDLY',
    'NATURE',
    'FAMILY-FRIENDLY',
  ];

  final Map<String, List<_Destination>> _destinationsByCategory = {
    'HALAL-FRIENDLY': [
      _Destination(
        city: 'Istanbul',
        country: 'Turkey',
        rawPricePKR: 8600, // BHD 31 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=400',
      ),
      _Destination(
        city: 'Dammam',
        country: 'Saudi Arabia',
        rawPricePKR: 10000, // BHD 36 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?w=400',
      ),
      _Destination(
        city: 'Rome',
        country: 'Italy',
        rawPricePKR: 11900, // BHD 43 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
      ),
      _Destination(
        city: 'London',
        country: 'United Kingdom',
        rawPricePKR: 11900, // BHD 43 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400',
      ),
      _Destination(
        city: 'Stockholm',
        country: 'Sweden',
        rawPricePKR: 13900, // BHD 50 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1509356843151-3e7d96241e11?w=400',
      ),
      _Destination(
        city: 'Kuwait',
        country: 'Kuwait',
        rawPricePKR: 7800, // BHD 28 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400',
      ),
    ],
    'NATURE': [
      _Destination(
        city: 'Skardu',
        country: 'Pakistan',
        rawPricePKR: 9700, // BHD 35 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      ),
      _Destination(
        city: 'Bali',
        country: 'Indonesia',
        rawPricePKR: 14400, // BHD 52 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400',
      ),
      _Destination(
        city: 'Swiss Alps',
        country: 'Switzerland',
        rawPricePKR: 18900, // BHD 68 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400',
      ),
      _Destination(
        city: 'Maldives',
        country: 'Maldives',
        rawPricePKR: 20800, // BHD 75 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=400',
      ),
      _Destination(
        city: 'Iceland',
        country: 'Iceland',
        rawPricePKR: 22800, // BHD 82 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=400',
      ),
      _Destination(
        city: 'New Zealand',
        country: 'New Zealand',
        rawPricePKR: 26400, // BHD 95 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1507699622108-4be3abd695ad?w=400',
      ),
    ],
    'FAMILY-FRIENDLY': [
      _Destination(
        city: 'Dubai',
        country: 'United Arab Emirates',
        rawPricePKR: 10500, // BHD 38 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
      ),
      _Destination(
        city: 'Singapore',
        country: 'Singapore',
        rawPricePKR: 15300, // BHD 55 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=400',
      ),
      _Destination(
        city: 'Paris',
        country: 'France',
        rawPricePKR: 13300, // BHD 48 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
      ),
      _Destination(
        city: 'Barcelona',
        country: 'Spain',
        rawPricePKR: 12500, // BHD 45 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1562883676-8c7feb83f09b?w=400',
      ),
      _Destination(
        city: 'Tokyo',
        country: 'Japan',
        rawPricePKR: 17200, // BHD 62 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
      ),
      _Destination(
        city: 'Orlando',
        country: 'United States',
        rawPricePKR: 20000, // BHD 72 equivalent
        imageUrl:
            'https://images.unsplash.com/photo-1605723517503-3cadb5818a0c?w=400',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);

    // Set initial tab based on passed category
    if (widget.initialCategory != null) {
      final categoryIndex = _categories.indexWhere(
        (cat) =>
            cat.toLowerCase().contains(widget.initialCategory!.toLowerCase()),
      );
      if (categoryIndex != -1) {
        _tabController.index = categoryIndex;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trip Ideas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelColor: primaryColor,
              unselectedLabelColor:
                  theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: _categories.map((category) {
                return Tab(text: category);
              }).toList(),
            ),
          ),

          // Destination Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: _categories.map((category) {
                final destinations = _destinationsByCategory[category] ?? [];
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    return _buildDestinationCard(
                      context,
                      destination,
                      primaryColor,
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Bottom indicator
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated lowest fares',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
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

  Widget _buildDestinationCard(
    BuildContext context,
    _Destination destination,
    Color priceColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                image: DecorationImage(
                  image: NetworkImage(destination.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City name
                Text(
                  destination.city,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Country
                Text(
                  destination.country,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price with dynamic currency
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Round-trip from',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyProvider.formatPrice(
                        destination.rawPricePKR,
                        compact: true,
                      ),
                      style: TextStyle(
                        color: priceColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
