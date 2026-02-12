# TM45 Guest Check-In App

> A modern, feature-rich iPad check-in system for managing staff, visitors, and facility issues.

![Version](https://img.shields.io/badge/version-1.1-blue)
![Platform](https://img.shields.io/badge/platform-iOS%2014%2B-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## 📱 Overview

TM45 is a comprehensive check-in/check-out management system designed for iPad, perfect for office buildings, facilities, and corporate environments. It streamlines visitor management, staff tracking, and issue reporting in one elegant application.

## ✨ Features

### 🎯 Core Features
- **Staff Check-In/Out** - Quick and efficient staff tracking with company information
- **Visitor Management** - Complete visitor workflow with pass number generation
- **Photo Capture** - Take visitor photos during check-in for enhanced security
- **Issue Reporting** - Report and track facility issues with photos and priority levels
- **Live Occupancy Dashboard** - Real-time view of who's currently in the building
- **Global Search** - Search across all staff, visitors, and issues instantly
- **Statistics & Analytics** - Comprehensive stats with date filtering

### 📊 Dashboard & Stats
- Live occupancy count (staff + visitors)
- Real-time updates
- Historical data with date-based filtering
- Visual statistics cards
- Searchable records

### 🔍 Search Functionality
- Search staff by name, company, or phone
- Search visitors by name, company, pass number, or purpose
- Search issues by location, description, or reporter
- Instant results with highlighting

### 📸 Visitor Photo Capture
- Camera integration for visitor photos
- Photo library selection option
- Photos displayed in all visitor cards
- Secure local storage
- Optional (can skip if preferred)

### 🛠️ Issue Tracking
- Report facility issues with categories:
  - Maintenance
  - IT/Tech
  - Safety
  - Facility
  - Other
- Priority levels (Low, Medium, High)
- Photo attachments
- Status tracking (Open, In Progress, Resolved)
- Resolution notes and timestamps

## 🎨 User Interface

### Welcome Screen
Beautiful gradient design with quick access to:
- Staff Check-In/Out
- Visitor Check-In/Out
- Issue Logs (Reporting)
- Maintenance (Coming Soon)

### Multi-Step Forms
- **Staff**: 2-step process (Details → Confirmation)
- **Visitor**: 4-step process (Details → Purpose → Photo → Confirmation)
- Smooth animations and transitions
- Real-time validation
- Progress indicators

### Tabbed Interface
- **Guests** - Main check-in/out flows
- **Stats** - Dashboard, Staff records, Visitor records
- **Issues** - Issue log with filtering

## 🏗️ Technical Architecture

### Technology Stack
- **Language**: Swift 5.0
- **Framework**: SwiftUI
- **Minimum iOS**: 14.0
- **Target Device**: iPad (optimized for 12.9-inch)
- **Storage**: UserDefaults (local persistence)
- **Camera**: AVFoundation via UIImagePickerController

### Data Models
```swift
- Guest (Staff)
  - ID, Full Name, Company, Phone
  - Check-in/out timestamps
  
- Visitor
  - ID, Full Name, Company, Phone
  - Purpose, Pass Number
  - Check-in/out timestamps
  - Photo (optional)
  
- Issue
  - ID, Reporter Name
  - Category, Priority, Status
  - Location, Description
  - Photo (optional)
  - Resolution tracking
```

### Key Components
- **GuestManager**: ObservableObject managing all data and persistence
- **ImagePicker**: UIKit wrapper for camera and photo library access
- **Custom Views**: Reusable components for forms, cards, and navigation

## 📋 Requirements

- **Development**:
  - Xcode 14.0 or later
  - macOS Monterey or later
  - Swift 5.0+

- **Deployment**:
  - iOS/iPadOS 14.0 or later
  - iPad (recommended: 12.9-inch iPad Pro)
  - Camera (for photo capture feature)

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/genelabs/Logga-Guest-App.git
cd Logga-Guest-App
```

### 2. Open in Xcode
```bash
open Guest.xcodeproj
```

### 3. Configure Signing
1. Select your target in Xcode
2. Go to "Signing & Capabilities"
3. Select your Team (Apple ID)
4. Xcode will handle provisioning automatically

### 4. Add Camera Permissions
The app requires camera permissions for visitor photos:

1. In Xcode, click the project icon (top of navigator)
2. Select your target → **Info** tab
3. Under "Custom iOS Target Properties", add:
   - **Privacy - Camera Usage Description**: 
     ```
     We need camera access to take visitor photos for security and identification purposes.
     ```
   - **Privacy - Photo Library Usage Description**: 
     ```
     We need photo library access to select visitor photos for security and identification purposes.
     ```

### 5. Build and Run
- Connect your iPad
- Select your device in Xcode
- Press **Cmd + R** or click the Play button ▶️

## 📖 Usage Guide

### Staff Check-In
1. Tap "Staff" on welcome screen
2. Tap "Check In"
3. Enter full name, company, and phone number
4. Review and confirm
5. Staff member receives confirmation

### Visitor Check-In
1. Tap "Visitors" on welcome screen
2. Tap "Check In"
3. **Step 1**: Enter name, company, phone
4. **Step 2**: Enter purpose of visit
5. **Step 3**: Take photo (optional - can skip)
6. **Step 4**: Review and confirm
7. Visitor receives unique pass number

### Issue Reporting
1. Tap "Issue Logs" on welcome screen
2. Enter reporter name (optional)
3. Select category (Maintenance, IT, Safety, etc.)
4. Select priority (Low, Medium, High)
5. Enter location and description
6. Add photo (optional)
7. Submit report

### Viewing Statistics
1. Go to "Stats" tab
2. Select "Dashboard" to see live occupancy
3. Select "Staff" or "Visitors" for historical records
4. Use search bar to find specific records
5. Filter by date using date selector

## 🎯 Key Features Detail

### Live Occupancy Dashboard
- Shows total number of people in building
- Breaks down by staff vs visitors
- Lists all currently checked-in individuals
- Updates in real-time as people check in/out
- Visual indicators for active status

### Photo Capture System
- Integrated camera access
- Photo library selection fallback
- Image preview and retake option
- JPEG compression for efficient storage
- Photos visible in all visitor cards
- Circular thumbnail displays

### Issue Management
- Comprehensive issue tracking
- Filter by status (Open, In Progress, Resolved)
- Filter by priority
- Search by location or description
- Photo attachments for visual reference
- Resolution notes and timestamps

### Search Functionality
- Real-time filtering as you type
- Searches across multiple fields
- Results grouped by type (Staff/Visitors/Issues)
- Shows result counts
- Highlights matching records

## 🗂️ Project Structure

```
Logga-Guest-App/
├── Guest/
│   ├── GuestApp.swift                 # App entry point
│   ├── ContentView.swift              # Main navigation
│   ├── WelcomeView.swift              # Home screen
│   │
│   ├── Models/
│   │   ├── GuestManager.swift         # Data manager
│   │   └── IssueModels.swift          # Issue data models
│   │
│   ├── Staff/
│   │   ├── CheckInOutView.swift       # Staff main view
│   │   └── GuestListView.swift        # Staff check-in form
│   │
│   ├── Visitors/
│   │   ├── VisitorCheckInOutView.swift    # Visitor main view
│   │   ├── VisitorCheckInView.swift       # Visitor check-in (4 steps)
│   │   └── VisitorCheckOutView.swift      # Visitor check-out
│   │
│   ├── Issues/
│   │   ├── IssueReportView.swift      # Issue reporting form
│   │   ├── IssueLogView.swift         # Issue log viewer
│   │   └── IssueDetailView.swift      # Issue details
│   │
│   ├── Stats/
│   │   └── StatsView.swift            # Statistics & dashboard
│   │
│   ├── Search/
│   │   └── GlobalSearchView.swift     # Global search
│   │
│   ├── Components/
│   │   ├── ImagePicker.swift          # Camera integration
│   │   └── VisitorCardsWithPhoto.swift # Photo-enabled cards
│   │
│   └── Supporting Files/
│       ├── Assets.xcassets
│       └── Info.plist
│
└── README.md
```

## 🔐 Data & Privacy

### Local Storage
- All data stored locally on device using UserDefaults
- No cloud sync (can be added via Firebase)
- Data persists between app restarts
- No data sent to external servers

### Photo Storage
- Visitor photos stored as JPEG data (70% quality)
- Photos stored locally with visitor record
- Automatic cleanup when visitor record is deleted
- No photos uploaded or shared externally

### Privacy Compliance
- Camera permission required before access
- User can deny permissions (photo becomes optional)
- Clear permission messages explaining usage
- Data remains on-device

## 🚧 Roadmap

### Planned Features
- [ ] Firebase cloud sync
- [ ] QR code check-in for returning visitors
- [ ] Email/SMS notifications
- [ ] Export to CSV/Excel
- [ ] PDF reports generation
- [ ] Multi-location support
- [ ] Advanced analytics with charts
- [ ] Contractor management
- [ ] Pre-registration portal
- [ ] Badge printing

## 🐛 Known Issues

- Camera doesn't work in iOS Simulator (use real device)
- Layout optimized for iPad 12.9" (scales on smaller devices)
- Free Apple Developer accounts require rebuild every 7 days

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

**Gene Labs**
- GitHub: [@genelabs](https://github.com/genelabs)

## 🙏 Acknowledgments

- Built with SwiftUI
- Designed for iPad
- Optimized for iOS 14+

## 📞 Support

For support, please open an issue on GitHub or contact the development team.

---

**Version 1.1** - Complete visitor management system with photo capture, live occupancy tracking, and comprehensive issue reporting.

Made with ❤️ by Gene Labs
