# Search Feature

## Purpose
Provide instant, comprehensive search across all documents by title, filename, and content with fast results even for thousands of documents.

## Feature Description
The search feature offers real-time filtering of documents as the user types in the search bar on the home screen. It searches through document titles, filenames, and full content using indexed queries for optimal performance.

## User Flow
1. User types in search bar on home screen
2. Search results update instantly on each keystroke
3. User sees matching documents with highlights
4. User can click any result to open document
5. User can clear search to return to normal view
6. Empty results show "no documents found" message

## UI Flow
- Search TextField in home screen header
- Real-time result updates (no submit button)
- Clear button appears when text entered
- Results replace categorized document view
- Empty state for zero matches
- Same document card design as home screen
- Search icon changes to clear icon when active

## Data Flow
1. User types in search TextField
2. TextEditingController.addListener detects change
3. AppProvider.search(query) called with query string
4. DatabaseService.searchDocuments(query) executes SQL
5. Results stored in AppProvider.searchResults
6. Consumer<AppProvider> rebuilds UI
7. Results displayed in ListView

## Storage Flow
### Database Query
```sql
SELECT * FROM documents 
WHERE search_index LIKE '%query%' 
ORDER BY modified_at DESC
```

### Search Index Structure
- Lowercase concatenation of: title + filename + content
- Example: "my note abc123.txt this is the content..."
- Stored in search_index column (TEXT)
- Indexed for fast LIKE queries
- Updated on every document save

### Indexing Strategy
- CREATE INDEX idx_search_index ON documents(search_index)
- SQLite LIKE with % wildcards
- Case-insensitive (lowercase normalization)
- Full-text search without FTS extension

## Inputs
- Search query string (any text)
- Clear search action

## Outputs
- Filtered list of matching documents
- Empty state if no matches
- Real-time result updates

## Dependencies
- AppProvider for state management
- DatabaseService for search queries
- TextEditingController for input handling
- Consumer<AppProvider> for reactive UI

## Edge Cases
- Empty query: Returns empty results, shows categorized view
- No matches: Shows "no documents found" empty state
- Very long query: Handled by SQL LIKE (performance may degrade)
- Special characters: Escaped by SQL parameter binding
- Thousands of documents: Index ensures fast queries (<100ms)
- Search during document load: Shows loading state appropriately

## Error Handling
- Try-catch around database query
- Return empty list on error
- Continue showing previous results if query fails
- Log errors silently without interrupting user
- Graceful handling of malformed queries

## Implementation Notes
### Search Behavior
- Instant search (no debouncing by default)
- Searches title, filename, and full content
- Case-insensitive matching
- Substring matching (not just prefix)
- No fuzzy matching (exact substring required)

### Performance Optimization
- Indexed search_index column for fast LIKE queries
- Query limited to necessary columns
- Results ordered by modified_at DESC
- No full-text extraction (uses indexed text)
- Expected performance: <50ms for 10k documents

### UI Integration
- Search bar always visible in home screen
- No separate search screen
- Results replace main document list
- Clear button appears when query non-empty
- Smooth transition between views

### Search Index Maintenance
- Updated on document create
- Updated on document save
- Updated on database rebuild
- Format: lowercase(title + " " + filename + " " + content)
- Spaces between components for word boundary matching

### Future Enhancements (Not Implemented)
- Search history
- Search filters (by date, word count, etc.)
- Fuzzy matching
- Search result highlighting
- Advanced query syntax
- Search suggestions
