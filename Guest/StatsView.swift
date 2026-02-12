import SwiftUI

struct StatsView: View {
    @EnvironmentObject var guestManager: GuestManager
    
    // 0 = Dashboard
    // 1 = Staff
    // 2 = Visitors
    @State private var selectedTab = 0
    
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @FocusState private var isSearchFocused: Bool
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var currentOccupancy: Int {
        guestManager.getAllActiveCount()
    }
    
    var currentStaff: Int {
        guestManager.getCheckedInGuests().count
    }
    
    var currentVisitors: Int {
        guestManager.getCheckedInVisitors().count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                tabSelectorView
                
                if selectedTab == 0 {
                    // Dashboard content
                    dashboardView
                } else {
                    // Staff/Visitors stats
                    searchBarView
                    dateFilterView
                    statsCardsView
                    
                    ScrollView {
                        if selectedTab == 1 {
                            staffListView
                        } else {
                            visitorListView
                        }
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        maroon.opacity(0.05),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - Dashboard View
    
    private var dashboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                mainOccupancyCard
                breakdownCards
                
                if !guestManager.getCheckedInGuests().isEmpty {
                    currentStaffSection
                }
                
                if !guestManager.getCheckedInVisitors().isEmpty {
                    currentVisitorsSection
                }
                
                if currentOccupancy == 0 {
                    emptyDashboardState
                }
            }
            .padding()
        }
    }
    
    private var mainOccupancyCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 50))
                .foregroundColor(maroon.opacity(0.7))
            
            Text("\(currentOccupancy)")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
            
            Text("People in Building")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Live")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.1))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private var breakdownCards: some View {
        HStack(spacing: 15) {
            OccupancyTypeCard(
                count: currentStaff,
                label: "Staff",
                icon: "person.fill",
                color: maroon
            )
            
            OccupancyTypeCard(
                count: currentVisitors,
                label: "Visitors",
                icon: "person.3.fill",
                color: .blue
            )
        }
    }
    
    private var currentStaffSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(maroon)
                Text("Current Staff (\(currentStaff))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .padding(.bottom, 4)
            
            ForEach(guestManager.getCheckedInGuests()) { guest in
                PersonRow(
                    name: guest.fullName,
                    subtitle: guest.company,
                    checkInTime: guest.checkInTime,
                    color: maroon
                )
            }
        }
    }
    
    private var currentVisitorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
                Text("Current Visitors (\(currentVisitors))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .padding(.bottom, 4)
            
            ForEach(guestManager.getCheckedInVisitors()) { visitor in
                VisitorRow(visitor: visitor)
            }
        }
    }
    
    private var emptyDashboardState: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Building is Empty")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            Text("No staff or visitors currently checked in")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// MARK: - Header

extension StatsView {
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Statistics & Records")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
            
            Text("Track and search all check-ins")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - Tabs

extension StatsView {
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            TabButton(title: "Dashboard",
                      icon: "building.2.fill",
                      isSelected: selectedTab == 0,
                      color: maroon) {
                selectedTab = 0
                searchText = ""
            }
            
            TabButton(title: "Staff",
                      icon: "person.fill",
                      isSelected: selectedTab == 1,
                      color: maroon) {
                selectedTab = 1
                searchText = ""
            }
            
            TabButton(title: "Visitors",
                      icon: "person.3.fill",
                      isSelected: selectedTab == 2,
                      color: maroon) {
                selectedTab = 2
                searchText = ""
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - Search + Date

extension StatsView {
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isSearchFocused ? maroon : .gray)
            
            TextField("Search by name or company...", text: $searchText)
                .focused($isSearchFocused)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var dateFilterView: some View {
        HStack {
            Text("Date:")
                .foregroundColor(.secondary)
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack(spacing: 6) {
                    Text(formattedDate(selectedDate))
                        .foregroundColor(maroon)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Image(systemName: "calendar")
                        .foregroundColor(maroon)
                }
            }
            
            Spacer()
            
            // Today quick button
            if !Calendar.current.isDateInToday(selectedDate) {
                Button(action: {
                    selectedDate = Date()
                }) {
                    Text("Today")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(maroon)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Stats Cards

extension StatsView {
    private var statsCardsView: some View {
        HStack(spacing: 15) {
            if selectedTab == 1 {
                StatCard(title: "Checked In",
                         count: filteredStaffCheckedIn.count,
                         icon: "person.fill.checkmark",
                         color: .green)
                
                StatCard(title: "Checked Out",
                         count: filteredStaffCheckedOut.count,
                         icon: "person.fill.xmark",
                         color: .orange)
                
                StatCard(title: "Total Staff",
                         count: filteredStaff.count,
                         icon: "person.2.fill",
                         color: maroon)
            } else {
                StatCard(title: "Active",
                         count: filteredVisitorsCheckedIn.count,
                         icon: "person.fill.checkmark",
                         color: .green)
                
                StatCard(title: "Departed",
                         count: filteredVisitorsCheckedOut.count,
                         icon: "person.fill.xmark",
                         color: .orange)
                
                StatCard(title: "Total Visitors",
                         count: filteredVisitors.count,
                         icon: "person.3.fill",
                         color: maroon)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}

// MARK: - Lists

extension StatsView {
    private var staffListView: some View {
        LazyVStack(spacing: 12) {
            if filteredStaff.isEmpty {
                EmptyStateView(icon: "person.fill.questionmark",
                               message: "No staff records")
            } else {
                ForEach(filteredStaff) { guest in
                    StaffRecordCard(guest: guest, maroon: maroon)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var visitorListView: some View {
        LazyVStack(spacing: 12) {
            if filteredVisitors.isEmpty {
                EmptyStateView(icon: "person.3.fill",
                               message: "No visitor records")
            } else {
                ForEach(filteredVisitors) { visitor in
                    VisitorRecordCard(visitor: visitor, maroon: maroon)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Filters

extension StatsView {
    private var filteredStaff: [Guest] {
        guestManager.guests.filter {
            Calendar.current.isDate($0.checkInTime, inSameDayAs: selectedDate) &&
            (searchText.isEmpty ||
             $0.fullName.localizedCaseInsensitiveContains(searchText) ||
             $0.company.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    private var filteredStaffCheckedIn: [Guest] {
        filteredStaff.filter { $0.checkOutTime == nil }
    }
    
    private var filteredStaffCheckedOut: [Guest] {
        filteredStaff.filter { $0.checkOutTime != nil }
    }
    
    private var filteredVisitors: [Visitor] {
        guestManager.visitors.filter {
            Calendar.current.isDate($0.checkInTime, inSameDayAs: selectedDate) &&
            (searchText.isEmpty ||
             $0.fullName.localizedCaseInsensitiveContains(searchText) ||
             $0.company.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    private var filteredVisitorsCheckedIn: [Visitor] {
        filteredVisitors.filter { $0.checkOutTime == nil }
    }
    
    private var filteredVisitorsCheckedOut: [Visitor] {
        filteredVisitors.filter { $0.checkOutTime != nil }
    }
    
    private func formattedDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

// MARK: - Dashboard Supporting Views

struct OccupancyTypeCard: View {
    let count: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }
}

struct PersonRow: View {
    let name: String
    let subtitle: String
    let checkInTime: Date
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("In:")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                Text(checkInTime.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 3)
    }
}

struct VisitorRow: View {
    let visitor: Visitor
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
            
            // Photo thumbnail
            if let photoData = visitor.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            } else {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(visitor.fullName.prefix(1).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(visitor.fullName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                HStack(spacing: 8) {
                    Text(visitor.company)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Pass: \(visitor.passNumber)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("In:")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                Text(visitor.checkInTime.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 3)
    }
}

// MARK: - Original Supporting Views

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? color : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? color.opacity(0.1) : Color.clear)
        }
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(count)")
                .font(.system(size: 22, weight: .bold))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct StaffRecordCard: View {
    let guest: Guest
    let maroon: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(guest.fullName).bold()
                    Text(guest.company).foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(isCheckedIn: guest.checkOutTime == nil)
            }
            Divider()
            TimeLabel(icon: "arrow.down.circle.fill",
                      time: guest.checkInTime,
                      label: "In",
                      color: .green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct VisitorRecordCard: View {
    let visitor: Visitor
    let maroon: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Photo thumbnail
                if let photoData = visitor.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 50, height: 50)
                        Text(visitor.fullName.prefix(2).uppercased())
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(visitor.fullName).bold()
                    Text(visitor.company).foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(isCheckedIn: visitor.checkOutTime == nil)
            }
            Divider()
            TimeLabel(icon: "arrow.down.circle.fill",
                      time: visitor.checkInTime,
                      label: "In",
                      color: .green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct StatusBadge: View {
    let isCheckedIn: Bool
    
    var body: some View {
        Text(isCheckedIn ? "Active" : "Out")
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background((isCheckedIn ? Color.green : Color.gray).opacity(0.2))
            .cornerRadius(10)
    }
}

struct TimeLabel: View {
    let icon: String
    let time: Date
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(color)
            Text("\(label): \(time.formatted(date: .omitted, time: .shortened))")
        }
        .font(.caption)
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text(message)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 40)
    }
}
