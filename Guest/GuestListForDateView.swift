import SwiftUI

struct GuestListForDateView: View {
    @EnvironmentObject var guestManager: GuestManager
    let selectedDate: Date
    @State private var selectedTab = 0 // 0 = All, 1 = Staff, 2 = Visitors
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            // Tab Selector
            tabSelectorView
            
            // Count
            countView
            
            // List
            ScrollView {
                VStack(spacing: 16) {
                    if selectedTab == 0 || selectedTab == 1 {
                        staffSectionView
                    }
                    
                    if selectedTab == 0 || selectedTab == 2 {
                        visitorsSectionView
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Records")
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(formattedDate(selectedDate))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
            
            Text("Complete Records")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            DateTabButton(
                title: "All",
                isSelected: selectedTab == 0,
                color: maroon
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            DateTabButton(
                title: "Staff",
                isSelected: selectedTab == 1,
                color: maroon
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
            
            DateTabButton(
                title: "Visitors",
                isSelected: selectedTab == 2,
                color: maroon
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var countView: some View {
        HStack(spacing: 20) {
            if selectedTab == 0 {
                CountBadge(count: staffForDate.count, label: "Staff", color: maroon)
                CountBadge(count: visitorsForDate.count, label: "Visitors", color: .blue)
            } else if selectedTab == 1 {
                CountBadge(count: staffForDate.count, label: "Staff", color: maroon)
            } else {
                CountBadge(count: visitorsForDate.count, label: "Visitors", color: .blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var staffSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if selectedTab == 0 {
                SectionHeader(title: "Staff", icon: "person.fill", count: staffForDate.count, color: maroon)
            }
            
            if staffForDate.isEmpty {
                EmptyStateCard(message: "No staff records for this date", icon: "person.fill")
            } else {
                ForEach(staffForDate) { guest in
                    StaffCardView(guest: guest, guestManager: guestManager)
                }
            }
        }
    }
    
    private var visitorsSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if selectedTab == 0 {
                SectionHeader(title: "Visitors", icon: "person.3.fill", count: visitorsForDate.count, color: .blue)
            }
            
            if visitorsForDate.isEmpty {
                EmptyStateCard(message: "No visitor records for this date", icon: "person.3.fill")
            } else {
                ForEach(visitorsForDate) { visitor in
                    VisitorCardView(visitor: visitor, guestManager: guestManager)
                }
            }
        }
    }
    
    // MARK: - Filtered Data
    
    private var staffForDate: [Guest] {
        let calendar = Calendar.current
        return guestManager.guests.filter { guest in
            calendar.isDate(guest.checkInTime, inSameDayAs: selectedDate)
        }
    }
    
    private var visitorsForDate: [Visitor] {
        let calendar = Calendar.current
        return guestManager.visitors.filter { visitor in
            calendar.isDate(visitor.checkInTime, inSameDayAs: selectedDate)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Supporting Views

struct DateTabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? color : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ? color.opacity(0.1) : Color.clear
                )
                .overlay(
                    Rectangle()
                        .fill(isSelected ? color : Color.clear)
                        .frame(height: 3),
                    alignment: .bottom
                )
        }
    }
}

struct CountBadge: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text("(\(count))")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}

struct EmptyStateCard: View {
    let message: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(message)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3)
    }
}

struct StaffCardView: View {
    let guest: Guest
    @ObservedObject var guestManager: GuestManager
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar
                ZStack {
                    Circle()
                        .fill(maroon)
                        .frame(width: 44, height: 44)
                    Text(guest.fullName.prefix(2).uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(guest.fullName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(guest.company)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(isCheckedIn: guest.checkOutTime == nil)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "phone.fill", label: "Phone", value: guest.phoneNumber, color: maroon)
                InfoRow(icon: "arrow.down.circle.fill", label: "Check In", value: formattedTime(guest.checkInTime), color: .green)
                
                if let checkOutTime = guest.checkOutTime {
                    InfoRow(icon: "arrow.up.circle.fill", label: "Check Out", value: formattedTime(checkOutTime), color: .orange)
                }
            }
            
            // Check Out Button
            if guest.checkOutTime == nil {
                Button(action: {
                    guestManager.checkOutGuest(id: guest.id ?? "")
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Check Out")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct VisitorCardView: View {
    let visitor: Visitor
    @ObservedObject var guestManager: GuestManager
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 44, height: 44)
                    Text(visitor.fullName.prefix(2).uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(visitor.fullName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(visitor.company)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(isCheckedIn: visitor.checkOutTime == nil)
                    
                    Text("Pass: \(visitor.passNumber)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "phone.fill", label: "Phone", value: visitor.phoneNumber, color: .blue)
                InfoRow(icon: "doc.text.fill", label: "Purpose", value: visitor.purpose, color: .blue)
                InfoRow(icon: "arrow.down.circle.fill", label: "Check In", value: formattedTime(visitor.checkInTime), color: .green)
                
                if let checkOutTime = visitor.checkOutTime {
                    InfoRow(icon: "arrow.up.circle.fill", label: "Check Out", value: formattedTime(checkOutTime), color: .orange)
                }
            }
            
            // Check Out Button
            if visitor.checkOutTime == nil {
                Button(action: {
                    guestManager.checkOutVisitor(id: visitor.id ?? "")
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Check Out")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text("\(label):")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct GuestListForDateView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = GuestManager()
        manager.addGuest(Guest(id: nil, fullName: "John Doe", company: "xAI", phoneNumber: "1234567890", checkInTime: Date(), checkOutTime: nil))
        manager.addGuest(Guest(id: nil, fullName: "Jane Smith", company: "SpaceX", phoneNumber: "0987654321", checkInTime: Date().addingTimeInterval(-3600), checkOutTime: Date()))
        manager.addVisitor(Visitor(id: nil, fullName: "Bob Wilson", company: "Tesla", phoneNumber: "5551234567", purpose: "Meeting with engineering team", passNumber: "AB-1234", checkInTime: Date(), checkOutTime: nil))
        return NavigationStack {
            GuestListForDateView(selectedDate: Date())
                .environmentObject(manager)
        }
    }
}
