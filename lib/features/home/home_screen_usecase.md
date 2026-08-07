# Home Screen Feature

## Purpose
Provide a centralized dashboard for viewing, organizing, and accessing all documents with powerful search and categorization capabilities.

## Feature Description
The home screen displays documents organized by categories (Pinned, Favorites, Recent, All Documents) with instant search, statistics, and quick actions. Users can create new documents, search existing ones, and access settings.

## User Flow
1. User lands on home screen after workspace initialization
2. User sees categorized document lists
3. User can search documents using search bar
4. User clicks on document to open in editor
5. User clicks FAB to create new document
6. User can refresh documents or access settings

## UI Flow
- App bar with NooK branding and action buttons
- Search bar with instant filtering
- Sectioned document list (Pinned, Favorites, Recent, All)
- Document cards showing title, date, word count, reading time
- Empty state for new workspaces
- Floating action button for new documents
- Loading indicator during data fetch
- Pull-to-refresh support

## Data Flow
1. Load documents from database via AppProvider
2. Categorize documents (pinned, favorites, recent, all)
3. Display in sectioned lists
4. On search input, filter documents instantly
5. Update UI reactively via Provider
6. On document tap, navigate to editor
7. Update last opened timestamp

## Storage Flow
- Read all documents from SQLite database
- Query pinned documents (is_pinned = 1)
- Query favorite documents (is_favorite = 1)
- Query recent documents (ORDER BY last_opened_at DESC LIMIT 10)
- Query all documents (ORDER BY modified_at DESC)
- Search queries use search_index field

## Inputs
- Search query text
- Document selection tap
- Create new document action
- Refresh action
- Settings navigation

## Outputs
- Categorized document lists
- Filtered search results
- Navigation to editor screen
- Navigation to settings screen
- Updated document metadata (last opened)

## Dependencies
- AppProvider for state management
- DatabaseService for queries
- FileService for operations
- intl package for date formatting
- Provider for reactive updates

## Edge Cases
- Empty workspace: Show empty state with create button
- No search results: Show "no documents found" message
- Search with special characters: Handled by LIKE query
- Very long document titles: Ellipsis truncation
- Thousands of documents: Lazy loading and efficient queries
- Database corruption: Show error, offer rebuild option

## Error Handling
- Try-catch around database operations
- Graceful handling of missing files
- Show loading state during operations
- Display errors via SnackBar
- Automatic refresh on navigation back from editor
- Handle null workspace path

## Implementation Notes
- Uses Consumer<AppProvider> for reactive updates
- ListView.builder for efficient rendering
- Card widgets with InkWell for material ripple
- Section headers with icons and labels
- Document cards show: title, modified date, word count, reading time
- Pin/favorite icons displayed on cards
- Date format: "MMM d, y • h:mm a"
- Search is case-insensitive and searches title, filename, content
- FAB extended with "New Document" label
- RefreshIndicator for pull-to-refresh (implicit in scaffold)
- Search results replace categorized view when active
- Clear button appears in search field when text entered
