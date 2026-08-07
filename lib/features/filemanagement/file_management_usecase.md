# File Management Feature

## Purpose
Provide comprehensive file operations for documents including create, rename, duplicate, delete, restore, import, export, and reveal in File Explorer.

## Feature Description
The file management system handles all document lifecycle operations through the FileService. It maintains synchronization between physical TXT files and database metadata, ensuring data integrity across all operations.

## User Flow
### Create Document
1. User clicks "New Document" FAB
2. System generates unique ID
3. Empty TXT file created
4. Metadata inserted into database
5. Editor opens with new document

### Delete Document
1. User opens document menu
2. User selects "Move to Trash"
3. Confirmation dialog appears
4. File moved from Documents/ to Trash/
5. Metadata updated with new path
6. User returned to home screen

### Restore Document
1. User finds document in trash
2. User selects restore action
3. File moved from Trash/ to Documents/
4. Metadata updated with new path
5. Document appears in main list

### Permanent Delete
1. User selects document in trash
2. User chooses permanent delete
3. Confirmation dialog appears
4. TXT file deleted from disk
5. Metadata removed from database

## UI Flow
- All actions accessed via document menu (bottom sheet)
- Confirmation dialogs for destructive actions
- SnackBar feedback for operation results
- Immediate UI refresh after operations
- Loading states during async operations

## Data Flow
1. User triggers file operation
2. FileService method called with parameters
3. File system operation performed
4. Database metadata updated
5. AppProvider.refreshDocuments() called
6. UI updates via Provider consumer
7. Success/error feedback shown

## Storage Flow
### File System Structure
```
Workspace/
├── Documents/
│   ├── uuid1.txt
│   ├── uuid2.txt
│   └── uuid3.txt
├── Trash/
│   └── uuid4.txt
├── Database/
│   └── nook.db
└── Settings/
```

### Create
1. Generate UUID v4 for document ID
2. Create filename: `{id}.txt`
3. Create file in Documents/ folder
4. Write initial content (title or empty)
5. Insert metadata into SQLite documents table
6. Return DocumentModel

### Delete (Move to Trash)
1. Query document metadata by ID
2. Use File.rename() to move from Documents/ to Trash/
3. Update metadata path field
4. Keep all other metadata intact

### Restore
1. Query document metadata by ID
2. Use File.rename() to move from Trash/ to Documents/
3. Update metadata path field
4. Document reappears in main lists

### Permanent Delete
1. Query document metadata by ID
2. Delete TXT file using File.delete()
3. Delete metadata row from database
4. Unrecoverable operation

### Duplicate
1. Load source document by ID
2. Read source file content
3. Create new document with copied content
4. Append " (Copy)" to title
5. New unique ID assigned

### Rename
1. Read document content
2. Replace first line with new title
3. Write back to same file
4. Update metadata title and search index
5. File path remains unchanged

### Import
1. User selects TXT file via FilePicker
2. Read content from external file
3. Extract title from first line
4. Create new document with imported content
5. Original file remains unchanged

### Export
1. User selects destination via FilePicker
2. Copy TXT file to destination
3. Original remains in workspace

### Reveal in Explorer
1. Get document file path
2. Execute `explorer /select, {path}`
3. Windows Explorer opens with file selected

## Inputs
- Document ID (for most operations)
- New title (for rename)
- Source path (for import)
- Destination path (for export)
- Workspace path (for create)

## Outputs
- Created/modified TXT files
- Updated database metadata
- DocumentModel objects
- Success/failure boolean
- UI refresh via AppProvider

## Dependencies
- FileService for all file operations
- DatabaseService for metadata operations
- AppProvider for state management
- file_picker for import/export dialogs
- uuid package for ID generation
- dart:io for File operations

## Edge Cases
- File doesn't exist: Return null or false
- Permission denied: Show error, operation fails
- Duplicate filename: UUID ensures uniqueness
- Import very large file: May impact performance
- Delete while editor open: Editor handles gracefully
- Workspace folder deleted: Error handling rebuilds
- Database out of sync: Rebuild database option

## Error Handling
- Try-catch around all file operations
- Return null/false on failure
- Check file.exists() before operations
- Validate paths before file operations
- Log errors but don't throw exceptions
- Graceful degradation if operation fails
- User feedback via SnackBar

## Implementation Notes
### UUID Generation
- Uses uuid package v4 (random)
- Format: `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`
- Ensures globally unique document IDs
- Used as filename: `{uuid}.txt`

### File Operations
- All operations async (Future<T>)
- Use dart:io File class
- File.writeAsString() for saves
- File.readAsString() for reads
- File.rename() for moves
- File.delete() for permanent deletion
- File.copy() for export

### Metadata Synchronization
- Every file operation updates database
- Metadata includes: title, path, dates, counts
- Search index rebuilt on content changes
- Modified timestamp updated on saves
- Created timestamp never changes

### Pin/Favorite Toggle
- Simple boolean flip in database
- No file system changes
- Immediate UI update via Provider
- Used for organization, not file operations

### Last Opened Tracking
- Updated when document opened in editor
- Used for "Recent" list ordering
- DateTime.now() stored as ISO8601 string
- Nullable field (null for never opened)

### Reading Time Calculation
- Formula: wordCount / 200 words per minute
- Rounded up to nearest minute
- Displayed in document cards
- Updated on every save

### Word Counting Algorithm
```dart
int _countWords(String text) {
  if (text.isEmpty) return 0;
  return text
    .trim()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .length;
}
```

### Title Extraction
- Always uses first line of content
- Trimmed of whitespace
- Falls back to filename if empty
- Updated automatically on save
- Displayed in UI and stored in metadata

### Reveal in File Explorer
- Windows-specific: `Process.run('explorer', ['/select,', path])`
- Opens Windows Explorer with file highlighted
- Requires absolute path
- Async operation (fire-and-forget)
