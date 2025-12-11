import 'package:flutter/material.dart';
import 'story_webview_page.dart';

class StoriesSearchPage extends StatefulWidget {
  final List<Story> stories;

  const StoriesSearchPage({
    super.key,
    required this.stories,
  });

  @override
  State<StoriesSearchPage> createState() => _StoriesSearchPageState();
}

class _StoriesSearchPageState extends State<StoriesSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Story> _filteredStories = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _filteredStories = []; // Empty initially
    // Auto-focus on search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterStories(String query) {
    setState(() {
      _hasSearched = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredStories = [];
      } else {
        _filteredStories = widget.stories
            .where((story) =>
                story.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterStories('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: theme.hintColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: _filterStories,
                  cursorColor: theme.colorScheme.primary,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search stories',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: false,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: _clearSearch,
                  child: Icon(
                    Icons.cancel,
                    color: theme.hintColor,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: theme.dividerColor,
          ),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    // Empty state when nothing typed
    if (!_hasSearched) {
      return const SizedBox.shrink();
    }

    // No results found
    if (_filteredStories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No stories found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // Show results
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredStories.length,
      itemBuilder: (context, index) {
        final story = _filteredStories[index];
        return _buildSearchResultItem(context, story);
      },
    );
  }

  Widget _buildSearchResultItem(BuildContext context, Story story) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryWebViewPage(
              title: story.title,
              url: story.blogUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                story.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 24),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                story.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for Story (shared with stories_page.dart)
class Story {
  final String title;
  final String source;
  final String imageUrl;
  final String blogUrl;

  const Story({
    required this.title,
    required this.source,
    required this.imageUrl,
    required this.blogUrl,
  });
}
