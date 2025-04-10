# My Savings Jar App Changelog

## [v1.3.1] - Widget Stability & Visual Feedback
### Added
- Graceful widget fallback message ("Loading...") while app group container is initializing after macOS login or reboot

### Improved
- Reduced blank widget states after system restart by adding retry logic to fetch data from App Group container

## [v1.3.0] - Widget Update
### Added
- Edit Jar functionality
- View Transactions functionality
- More icons to choose from when creating or editing a jar
- "Show in Widget" toggle for jars (from Add/Edit views)
- Widget Configuration view to select eligible jars
- Random selection of eligible jars for widget display
- Expand/Collapse functionality for sidebar navigation
- Modularized Main Dashboard components (UI architecture cleanup)

### Improved
- Polished the look-n-feel of the entire UI
- Made only the transaction list scrollable in detail view (not the full view)
- Improved synchronization of app data with widgets via App Group
- Fixed widget visibility and preview behavior using correct `@main` and `WidgetBundle`
- Updated widget rendering logic to handle edge cases and missing jars

## [v1.2.0] - Widget Update
### Added
- macOS desktop widgets for tracking savings goals
- Progress widget showing individual jar status
- Summary widget displaying overview of all jars
- Widget configuration options with customizable appearance
- Real-time widget updates synchronized with the main app
- Widget preferences in app settings

### Changed
- Enhanced data sharing between main app and widgets
- Improved app architecture to support widget extension

### Improvements
- Optimized performance for widget updates
- Added widget-specific color themes
- Implemented efficient data refresh mechanism

## [v1.1.0] - Export and Import Update
### Added
- Export Savings Jars to CSV
- Import Savings Jars from CSV
- User-friendly file selection dialogs for CSV export and import
- Comprehensive transaction history preservation during export/import
- Error handling and user notifications for import/export processes

### Changed
- Enhanced CSV export/import method to include detailed jar information
- Improved error handling for file import/export processes

### Improvements
- Added robust validation for imported CSV files
- Implemented safeguards to prevent data loss during import
- Created user-friendly alerts for import/export operations

## [v1.0.0] - Initial Release
### Core Features
- Create multiple savings jars
- Set savings targets
- Track current savings amount
- Add deposits and withdrawals
- Visualize savings progress
  - Progress bars
  - Color-coded jar representation
- Transaction history tracking
- Persistent local storage
- User-friendly interface with:
  - Overview screen
  - Individual jar details
  - Transaction management

### Key Functionalities
- Add new savings jars
- Edit existing jars
- Delete savings jars
- Make deposits
- Make withdrawals
- View transaction history
- Color and icon customization

## Export/Import Implementation Details
### Export Process
- Converts each savings jar to a CSV row
- Includes all jar details:
  - Unique identifier
  - Jar name
  - Target amount
  - Current amount
  - Color
  - Icon
  - Creation date
  - Transaction history

### Import Process
- Validates CSV file structure
- Parses and reconstructs savings jars
- Preserves transaction history
- Handles potential parsing errors gracefully

## Widget Implementation Details
### Widget Types
- Progress Widget: Displays progress of individual savings jars
- Summary Widget: Shows overview of all savings goals
- Different size options for various user preferences

### Widget Features
- Live progress bars for visual tracking
- Color-coded indicators matching jar settings
- Ability to select which jars appear in widgets
- Auto-refreshing data synchronized with main app

## Known Limitations
- Currently macOS-specific file dialogs
- Requires App Sandbox entitlements
- Replaces entire jar collection on import
- Widgets require macOS 11 or later

## Future Improvements
- Cross-platform file selection
- More granular import options
- Ability to merge imported jars instead of full replacement
- Enhanced export/import flexibility
- Additional widget customization options
- Interactive widgets with quick-add functionality
