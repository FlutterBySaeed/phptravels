import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/auth_provider.dart';
import 'package:phptravels/features/account/pages/login_page.dart';
import 'story_webview_page.dart';
import 'stories_search_page.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _bookmarkedStories = {};

  // Blog data - update URLs with actual links
  final List<_Story> _stories = const [
    _Story(
      title: 'Fiercely Independent Cultures',
      source: 'Travel Blog',
      imageUrl: 'https://phptravels.net//uploads/blog/791534_6.jpg',
      blogUrl: 'https://phptravels.net/blog/Fiercely-Independent-Cultures/34',
    ),
    _Story(
      title: 'Peace Train A Long Time Coming',
      source: 'Travel Blog',
      imageUrl: 'https://phptravels.net//uploads/blog/120331_3.jpg',
      blogUrl: 'https://phptravels.net/blog/Peace-Train-A-Long-Time-Coming/33',
    ),
    _Story(
      title: 'South Africa A Terminal Tyre',
      source: 'Travel Blog',
      imageUrl: 'https://phptravels.net//uploads/blog/780975_1.jpg',
      blogUrl: 'https://phptravels.net/blog/south-africa-a-terminal-tyre/32',
    ),
    _Story(
      title: 'It Wasn\'t Supposed to Rain',
      source: 'Travel Blog',
      imageUrl: 'https://phptravels.net//uploads/blog/835693_5.jpg',
      blogUrl: 'https://phptravels.net/blog/It-Wasn-t-Supposed-to-Rain/31',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleBookmark(int index) {
    setState(() {
      if (_bookmarkedStories.contains(index)) {
        _bookmarkedStories.remove(index);
      } else {
        _bookmarkedStories.add(index);
      }
    });
  }

  void _openStory(int index, _Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryWebViewPage(
          title: story.title,
          url: story.blogUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          'Stories',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoriesSearchPage(
                    stories: _stories
                        .map((s) => Story(
                              title: s.title,
                              source: s.source,
                              imageUrl: s.imageUrl,
                              blogUrl: s.blogUrl,
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: primaryColor,
          unselectedLabelColor:
              theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'LATEST'),
            Tab(text: 'BOOKMARKS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // LATEST Tab
          _buildStoryList(_stories),
          // BOOKMARKS Tab
          _buildBookmarksTab(),
        ],
      ),
    );
  }

  Widget _buildBookmarksTab() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final authProvider = Provider.of<AuthProvider>(context);

    // Show login prompt if not authenticated
    if (!authProvider.isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please log in to see bookmarks',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show bookmarked stories if authenticated
    final bookmarkedStories = _stories
        .asMap()
        .entries
        .where((e) => _bookmarkedStories.contains(e.key))
        .map((e) => e.value)
        .toList();

    if (bookmarkedStories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: theme.hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarked stories yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any story to save it',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarkedStories.length,
      itemBuilder: (context, index) {
        final story = bookmarkedStories[index];
        final actualIndex = _stories.indexOf(story);
        return _buildStoryCard(context, story, actualIndex);
      },
    );
  }

  Widget _buildStoryList(List<_Story> stories, {bool isBookmarksTab = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        final actualIndex = _stories.indexOf(story);
        return _buildStoryCard(context, story, actualIndex);
      },
    );
  }

  Widget _buildStoryCard(BuildContext context, _Story story, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final isBookmarked = _bookmarkedStories.contains(index);

    return GestureDetector(
      onTap: () => _openStory(index, story),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    story.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image, size: 48),
                        ),
                      );
                    },
                  ),
                ),
                // Bookmark Icon - no background
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(index),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 28,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.article_outlined,
                          size: 14,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        story.source,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
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

class _Story {
  final String title;
  final String source;
  final String imageUrl;
  final String blogUrl;

  const _Story({
    required this.title,
    required this.source,
    required this.imageUrl,
    required this.blogUrl,
  });
}
