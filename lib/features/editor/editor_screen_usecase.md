# Text Editor Feature

## Purpose
Provide a distraction-free, full-featured text editor for writing and editing documents with autosave, find/replace, keyboard shortcuts, and real-time statistics.

## Feature Description
The editor screen offers a large writing area with professional text editing capabilities including undo/redo, find/replace, zoom controls, autosave, word/character/line counting, and cursor position tracking. All editing happens in a clean, focused interface.

## User Flow
1. User opens document from home screen
2. Editor loads document content
3. User writes/edits content
4. Content autosaves every 30 seconds (configurable)
5. User can manually save with Ctrl+S or toolbar button
6. User can find/replace text with Ctrl+F
7. User can zoom in/out with Ctrl+=/- 
8. User can access document menu for actions
9. User exits with back button (prompt if unsaved)

## UI Flow
- App bar with document title, save status, action buttons
- Optional find/replace toolbar
- Large distraction-free editor area
- Status bar with statistics and zoom controls
- Unsaved changes indicator
- Modal bottom sheet for document menu
- Confirmation dialogs for destructive actions
- Keyboard shortcuts for common actions

## Data Flow
1. Load document model from navigation arguments
2. Read file content from disk via FileService
3. Display in TextField with TextEditingController
4. Listen for content changes
5. Update statistics in real-time
6. Autosave timer triggers periodic saves
7. On save, write to disk and update metadata
8. On exit, check for unsaved changes and prompt
9. Update last opened timestamp

## Storage Flow
- Read TXT file from document path
- Parse content into editor
- On save: Write content to TXT file
- Update document metadata in SQLite:
  - title (first line of content)
  - modified_at (current timestamp)
  - word_count (calculated from content)
  - character_count (content.length)
  - line_count (number of newlines)
  - search_index (lowercase title + filename + content)
- Autosave writes to same file path

## Inputs
- Document model (from navigation)
- User text input
- Find/replace queries
- Zoom level adjustments
- Save/menu actions
- Keyboard shortcuts

## Outputs
- Updated file content on disk
- Updated metadata in database
- Real-time statistics display
- Navigation back to home
- Document menu actions (pin, favorite, duplicate, trash)

## Dependencies
- FileService for file operations
- DatabaseService for metadata updates
- AppProvider for state management
- SettingsService for editor preferences
- UndoHistoryController for undo/redo

## Edge Cases
- Very large files (>1MB): May impact performance, handled by Flutter
- File deleted externally: Show error, offer to recreate
- Rapid typing during autosave: Autosave flag prevents conflicts
- Multiple find matches: Cycles through with wrap-around
- Zero matches in find: Wraps to start of document
- Replace all with no matches: No action taken
- User closes during save: Async operation completes
- Empty content: Uses "Untitled" as default title

## Error Handling
- Try-catch around file read/write operations
- Show SnackBar on save failure
- Prompt user on unsaved changes before exit
- Handle disposed context gracefully
- Validate file path exists before operations
- Recover from autosave failures silently
- Log errors but don't interrupt user flow

## Implementation Notes
### Keyboard Shortcuts
- Ctrl+S: Save document
- Ctrl+F: Open find/replace
- Ctrl+H: Open find/replace
- Ctrl+=: Zoom in
- Ctrl+-: Zoom out
- Ctrl+0: Reset zoom

### Text Statistics
- Word count: Split by whitespace, filter empty
- Character count: Total length including spaces
- Line count: Split by newline
- Cursor position: Line and column calculated from selection
- Reading time: wordCount / 200 words per minute

### Autosave
- Default interval: 30 seconds (configurable in settings)
- Only saves if hasUnsavedChanges flag is true
- Prevents concurrent saves with isSaving flag
- Shows "Unsaved" badge when changes exist
- Silent autosave (no snackbar notification)

### Find/Replace
- Case-sensitive search
- Find next wraps to document start
- Replace replaces current selection if matches
- Replace all uses string.replaceAll()
- Find/replace bar toggles with Ctrl+F

### Zoom
- Range: 50% to 200% (0.5 to 2.0)
- Step: 10% (0.1)
- Applied to fontSize multiplier
- Displayed as percentage in status bar

### Document Menu
- Pin/Unpin toggle
- Favorite/Unfavorite toggle
- Duplicate document
- Reveal in File Explorer
- Move to Trash (with confirmation)

### Title Extraction
- Title is always the first line of content
- If first line is empty, uses "Untitled"
- Automatically updates on save

### Editor Configuration
- Font family: Consolas (monospace)
- Font size: Configurable (default 16pt)
- Line height: 1.6
- Max lines: null (unlimited)
- Expands: true (fills available space)
- Autofocus: true
- Text align: top
- Padding: 48px horizontal, 32px vertical
