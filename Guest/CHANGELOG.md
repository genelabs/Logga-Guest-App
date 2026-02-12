# Changelog

All notable changes to the TM45 Guest Check-In App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2024-02-12

### Added
- **Photo Capture for Visitors**
  - Camera integration during visitor check-in
  - Photo library selection option
  - Photo preview and retake functionality
  - Photos displayed in all visitor cards with circular thumbnails
  - Optional photo step (can be skipped)
  - JPEG compression for efficient storage

- **Live Occupancy Dashboard**
  - Real-time count of people in building
  - Breakdown by staff vs visitors
  - List of all currently checked-in individuals
  - Visual status indicators
  - Empty state when building is empty

- **Global Search**
  - Search across staff, visitors, and issues
  - Real-time filtering as you type
  - Results grouped by type
  - Result counts displayed
  - Search by name, company, phone, pass number, purpose, location, description

- **Issue Reporting System**
  - Report facility issues with categories (Maintenance, IT, Safety, Facility, Other)
  - Priority levels (Low, Medium, High)
  - Photo attachments for issues
  - Status tracking (Open, In Progress, Resolved)
  - Resolution notes and timestamps
  - Issue log viewer with filtering

- **Enhanced Statistics View**
  - Three-tab interface: Dashboard, Staff, Visitors
  - Date-based filtering
  - Search functionality in stats
  - Visual statistics cards
  - Active/departed status badges

### Changed
- Visitor check-in flow now includes 4 steps (added photo step)
- Updated WelcomeView with "Issue Logs" instead of "Others"
- Improved card layouts with photo support
- Enhanced occupancy tracking with live updates

### Improved
- Better data persistence with photo support
- More professional UI with circular photo thumbnails
- Smoother animations and transitions
- Better form validation

## [1.0.0] - 2024-01-15

### Added
- **Staff Check-In/Out**
  - Two-step process (Details → Confirmation)
  - Staff tracking with company information
  - Real-time validation

- **Visitor Check-In/Out**
  - Three-step process (Details → Purpose → Confirmation)
  - Unique pass number generation
  - Purpose tracking

- **Welcome Screen**
  - Beautiful gradient design
  - Quick access to all features
  - Category-based navigation

- **Statistics & Records**
  - Historical data viewing
  - Date filtering
  - Search functionality
  - Checked-in vs checked-out tracking

- **Data Persistence**
  - Local storage using UserDefaults
  - Data persists between app restarts
  - Separate tracking for staff and visitors

### Technical
- SwiftUI-based architecture
- iPad-optimized (12.9-inch)
- iOS 14+ support
- Observable pattern for state management

---

## Version Naming

- **Major.Minor.Patch** format
- **Major**: Breaking changes or major feature releases
- **Minor**: New features, backwards compatible
- **Patch**: Bug fixes and small improvements

## Categories

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements
- **Technical**: Technical changes or improvements
