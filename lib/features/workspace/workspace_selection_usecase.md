# Workspace Selection Feature

## Purpose
Allow users to select and initialize a workspace directory where all NooK data will be stored, ensuring a clean separation of documents and metadata.

## Feature Description
On first launch, users choose a directory to serve as their workspace. The application automatically creates the required folder structure (Documents/, Trash/, Database/, Settings/) and remembers this location for future sessions.

## User Flow
1. User sees workspace selection screen
2. User clicks "Browse" to open directory picker
3. User selects desired directory
4. Selected path is displayed with confirmation
5. User clicks "Continue"
6. System initializes workspace structure
7. User is redirected to home screen

## UI Flow
- Centered card layout with gradient background
- Folder icon header
- Explanatory text describing workspace purpose
- Structure preview showing folder hierarchy
- Browse button to open directory picker
- Continue button (enabled only when path selected)
- Success/error feedback via colored containers
- Loading indicator during initialization

## Data Flow
1. Check for existing workspace in SharedPreferences
2. If valid workspace exists, skip to home screen
3. User selects directory via FilePicker
4. Validate selected path
5. Create workspace folder structure
6. Save workspace path to SharedPreferences
7. Initialize database connection
8. Navigate to home screen

## Storage Flow
1. Create workspace root directory
2. Create Documents/ subdirectory
3. Create Trash/ subdirectory
4. Create Database/ subdirectory
5. Create Settings/ subdirectory
6. Store workspace path in SharedPreferences (key: 'workspace_path')

## Inputs
- Directory path from FilePicker

## Outputs
- Initialized workspace folder structure
- Stored workspace path preference
- Navigation to home screen

## Dependencies
- file_picker package for directory selection
- shared_preferences for path persistence
- WorkspaceService for validation and initialization
- AppProvider for state management

## Edge Cases
- User cancels directory picker: No action taken
- User selects protected/system directory: Show error message
- Directory creation fails: Display error, allow retry
- User selects existing NooK workspace: Validate and continue
- Workspace path is invalid on app restart: Show workspace selection again

## Error Handling
- Try-catch around directory creation operations
- Validate directory exists and is writable
- Show user-friendly error messages in error container
- Prevent navigation if initialization fails
- Disable Continue button during initialization

## Implementation Notes
- Uses FilePicker.platform.getDirectoryPath()
- WorkspaceService handles all directory operations
- SharedPreferences key: 'workspace_path'
- Folder structure is created recursively
- AppProvider.setWorkspace() called on success
- MaterialPageRoute.pushReplacementNamed('/home') on completion
- Structure preview uses monospace font (Consolas)
- Icon colors match Material 3 color scheme
