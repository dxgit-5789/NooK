# Settings Screen Feature

## Purpose
Allow users to customize application behavior, appearance, editor preferences, and manage workspace settings.

## Feature Description
The settings screen provides comprehensive configuration options for theme, editor appearance, autosave behavior, workspace management, and system maintenance. Users can reset all settings to defaults and access application information.

## User Flow
1. User opens settings from home screen toolbar
2. User views categorized settings sections
3. User adjusts theme mode (Light/Dark/System)
4. User changes editor font size via slider
5. User sets autosave interval via slider
6. User can change workspace location
7. User can rebuild database if needed
8. User can reset all settings to defaults
9. Changes apply immediately
10. User returns to home screen

## UI Flow
- Scrollable list with sectioned settings
- Section headers for organization
- Card-based grouping
- Sliders for numeric values
- Dropdowns for selections
- Buttons for actions
- Confirmation dialogs for destructive actions
- SnackBar feedback for operations

## Data Flow
1. Load current settings from SettingsService
2. Load workspace path from WorkspaceService
3. Display in UI with current values
4. On change, update setting in SharedPreferences
5. Notify AppProvider of theme changes
6. Show confirmation for workspace/database changes
7. Apply changes immediately without restart

## Storage Flow
### SharedPreferences Keys
- theme_mode: 'light' | 'dark' | 'system'
- accent_color: int (Color.value)
- font_family: string
- font_size: double
- editor_font_family: string
- editor_font_size: double (12-24)
- autosave_interval: int seconds (10-120)
- editor_line_height: double
- editor_show_line_numbers: bool

### Workspace Operations
- Change workspace: Initialize new workspace, update path
- Rebuild database: Scan Documents/ folder, recreate metadata

## Inputs
- Theme mode selection
- Font size slider (12-24pt)
- Autosave interval slider (10-120 seconds)
- New workspace directory path
- Rebuild/Reset confirmations

## Outputs
- Updated preferences in SharedPreferences
- Theme change reflected in AppProvider
- New workspace initialization
- Rebuilt database metadata
- Reset settings confirmation

## Dependencies
- SettingsService for all preferences
- WorkspaceService for workspace operations
- AppProvider for theme updates
- file_picker for directory selection
- shared_preferences for persistence

## Edge Cases
- System theme change: App follows system immediately
- Invalid workspace path: Show error, keep current
- Database rebuild with no files: Empty database created
- Reset settings during active session: Applied immediately
- Very large autosave interval: UI enforces max 120 seconds
- Very small font size: UI enforces min 12pt

## Error Handling
- Try-catch around all async operations
- Validate workspace path before changing
- Confirm destructive actions (rebuild, reset)
- Show SnackBar on success/failure
- Graceful handling if settings file missing
- Fallback to defaults if setting load fails

## Implementation Notes
### Appearance Section
- Theme mode dropdown (System/Light/Dark)
- Follows Material 3 color scheme
- Updates AppProvider.themeMode immediately

### Editor Section
- Font size slider: 12pt to 24pt, step 1
- Shows current value as "Xpt"
- Autosave interval: 10 to 120 seconds, step 10
- Shows current value as "X seconds"

### Workspace Section
- Displays current workspace path
- Ellipsis for long paths (maxLines: 2)
- Change button opens FilePicker
- Rebuild database button with confirmation
- Rebuild scans Documents/ and recreates all metadata entries

### Advanced Section
- Reset to defaults with confirmation dialog
- Clears all SharedPreferences keys
- Reloads UI with default values

### About Section
- App name: NooK
- Version: 1.0.0
- Description: Local-first text editor

### Settings Persistence
- All changes saved immediately to SharedPreferences
- No "Apply" or "Save" button needed
- Changes reflected across app via Provider/Service pattern

### Default Values
- Theme: System
- Editor font size: 16pt
- Autosave interval: 30 seconds
- Font family: Segoe UI
- Editor font: Consolas
- Line height: 1.6

### UI Structure
- ListView with padding
- Section headers with titleLarge style
- Card widgets for grouping
- ListTile for each setting
- Leading icons matching theme colors
- Trailing controls (dropdown, button, slider)
- Dividers between related items
