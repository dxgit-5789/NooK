import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../app/app_provider.dart';
import '../../models/document_model.dart';
import '../editor/editor_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.refreshDocuments();
  }

  Future<void> _createNewDocument() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final doc = await appProvider.createDocument(title: 'Untitled');

    if (doc != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditorScreen(document: doc),
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.search(query);
    setState(() {
      _isSearchActive = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.clearSearch();
    setState(() {
      _isSearchActive = false;
    });
  }

  void _openDocument(DocumentModel document) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.updateLastOpened(document.id);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditorScreen(document: document),
        ),
      );
    }
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, colorScheme),
            _buildSearchBar(context, colorScheme),
            Expanded(
              child: _isSearchActive
                  ? _buildSearchResults(context, colorScheme)
                  : _buildDocumentList(context, colorScheme),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewDocument,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Document'),
        elevation: 2,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NooK',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Your personal writing space',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadDocuments,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _navigateToSettings,
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _isSearchActive
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, ColorScheme colorScheme) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No documents found',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: appProvider.searchResults.length,
          itemBuilder: (context, index) {
            final doc = appProvider.searchResults[index];
            return _buildDocumentCard(context, colorScheme, doc);
          },
        );
      },
    );
  }

  Widget _buildDocumentList(BuildContext context, ColorScheme colorScheme) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          );
        }

        if (appProvider.documents.isEmpty) {
          return _buildEmptyState(context, colorScheme);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appProvider.pinnedDocuments.isNotEmpty) ...[
                _buildSectionHeader(context, 'Pinned', Icons.push_pin_rounded),
                const SizedBox(height: 12),
                ...appProvider.pinnedDocuments.map(
                  (doc) => _buildDocumentCard(context, colorScheme, doc),
                ),
                const SizedBox(height: 24),
              ],
              if (appProvider.favoriteDocuments.isNotEmpty) ...[
                _buildSectionHeader(context, 'Favorites', Icons.star_rounded),
                const SizedBox(height: 12),
                ...appProvider.favoriteDocuments.map(
                  (doc) => _buildDocumentCard(context, colorScheme, doc),
                ),
                const SizedBox(height: 24),
              ],
              if (appProvider.recentDocuments.isNotEmpty) ...[
                _buildSectionHeader(context, 'Recent', Icons.access_time_rounded),
                const SizedBox(height: 12),
                ...appProvider.recentDocuments.map(
                  (doc) => _buildDocumentCard(context, colorScheme, doc),
                ),
                const SizedBox(height: 24),
              ],
              _buildSectionHeader(context, 'All Documents', Icons.description_rounded),
              const SizedBox(height: 12),
              ...appProvider.documents.map(
                (doc) => _buildDocumentCard(context, colorScheme, doc),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(BuildContext context, ColorScheme colorScheme, DocumentModel doc) {
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openDocument(doc),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (doc.isPinned)
                    Icon(
                      Icons.push_pin_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  if (doc.isFavorite)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(doc.modifiedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.text_fields_rounded,
                    size: 12,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${doc.wordCount} words',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${doc.readingTimeMinutes} min read',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_rounded,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No documents yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first document to get started',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewDocument,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Document'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
