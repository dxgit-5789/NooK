# Splash Screen Feature

## Purpose
Display an animated splash screen during application initialization to provide visual feedback while the app loads.

## Feature Description
The splash screen shows the NooK logo with smooth animations and transitions to the workspace selection screen after a brief delay. It creates a professional first impression with Material 3 design language.

## User Flow
1. User launches the application
2. Splash screen appears with animated logo
3. After 2 seconds, automatically transitions to workspace selection
4. No user interaction required

## UI Flow
- Gradient background (surface to surfaceContainerLow)
- Centered logo container with glassmorphism effect
- App name "NooK" with tagline
- Fade and scale animations
- Smooth transition to next screen

## Data Flow
1. Application starts
2. Splash screen renders
3. AnimationController manages fade/scale animations
4. Timer triggers navigation after 2 seconds
5. Navigator pushes workspace selection route

## Storage Flow
No storage operations performed.

## Inputs
- None (automatic launch)

## Outputs
- Visual feedback during app initialization
- Navigation to workspace selection screen

## Dependencies
- MaterialApp routing
- AnimationController
- Timer for auto-navigation

## Edge Cases
- If navigation occurs before animations complete: No issue, navigation takes precedence
- If user closes app during splash: Normal app termination

## Error Handling
- Graceful handling if navigation context is disposed
- Check mounted state before navigation

## Implementation Notes
- Uses SingleTickerProviderStateMixin for animation
- 1500ms animation duration
- 2000ms total display time
- Fade animation: 0.0 to 1.0 (first 60% of animation)
- Scale animation: 0.8 to 1.0 with easeOutBack curve
- Primary color used for logo container
- Icon: edit_note_rounded (Material Icons)
