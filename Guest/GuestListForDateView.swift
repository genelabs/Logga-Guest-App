import SwiftUI

struct GuestListForDateView: View {
    @EnvironmentObject var guestManager: GuestManager
    let selectedDate: Date
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            guestCountView
            guestListView
            Spacer()
        }
        .padding()
        .navigationTitle("Guest List")
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("Guests for \(formattedDate(selectedDate))")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(maroon)
            .padding(.top, 20)
            .accessibilityAddTraits(.isHeader)
    }
    
    private var guestCountView: some View {
        Text("\(guestsForDate.count) guest\(guestsForDate.count == 1 ? "" : "s")")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .accessibilityLabel("\(guestsForDate.count) guests on \(formattedDate(selectedDate))")
    }
    
    private var guestListView: some View {
        Group {
            if guestsForDate.isEmpty {
                emptyStateView
            } else {
                populatedListView
            }
        }
    }
    
    private var emptyStateView: some View {
        Text("No guests checked in on \(formattedDate(selectedDate))")
            .foregroundColor(.gray)
            .padding()
            .accessibilityLabel("No guests for selected date")
    }
    
    private var populatedListView: some View {
        List {
            guestItemsView
        }
        .listStyle(.plain)
    }
    
    private var guestItemsView: some View {
        ForEach(guestsForDate) { guest in
            GuestListItemView(guest: guest, guestManager: guestManager)
        }
    }
    
    // MARK: - Guest List Item Subview
    
    private struct GuestListItemView: View {
        let guest: Guest
        @ObservedObject var guestManager: GuestManager
        private let maroon = Color(red: 0.5, green: 0, blue: 0)
        
        var body: some View {
            GuestCardView(guest: guest)
                .swipeActions(edge: .trailing, allowsFullSwipe: guest.checkOutTime == nil) {
                    if guest.checkOutTime == nil {
                        Button {
                            guestManager.checkOutGuest(id: guest.id)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Label("Check Out", systemImage: "person.fill.xmark")
                        }
                        .tint(.red)
                    }
                }
                .accessibilityAction(named: "Check Out") {
                    if guest.checkOutTime == nil {
                        guestManager.checkOutGuest(id: guest.id)
                    }
                }
        }
    }
    
    // MARK: - Guest Card Subview
    
    private struct GuestCardView: View {
        let guest: Guest
        private let maroon = Color(red: 0.5, green: 0, blue: 0)
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                avatarView
                detailsView
                Spacer()
            }
            .padding(.all, 10)
            .background(cardBackground)
        }
        
        private var avatarView: some View {
            ZStack {
                Circle()
                    .fill(maroon.opacity(0.8))
                    .frame(width: 36, height: 36)
                Text(guest.fullName.prefix(2).uppercased())
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .accessibilityLabel("Avatar for \(guest.fullName)")
        }
        
        private var detailsView: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(guest.fullName)
                    .font(.headline)
                Text("Company: \(guest.company)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Phone: \(guest.phoneNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("In: \(formattedDateTime(guest.checkInTime))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                statusView
            }
        }
        
        private var statusView: some View {
            Group {
                if let checkOutTime = guest.checkOutTime {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        Text("Out: \(formattedDateTime(checkOutTime))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        Text("Still Checked In")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        
        private var cardBackground: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(radius: 1)
        }
        
        private func formattedDateTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Helpers
    
    private var guestsForDate: [Guest] {
        let calendar = Calendar.current
        return guestManager.guests.filter { guest in
            calendar.isDate(guest.checkInTime, inSameDayAs: selectedDate)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct GuestListForDateView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = GuestManager()
        manager.addGuest(Guest(id: UUID(), fullName: "John Doe", company: "xAI", phoneNumber: "1234567890", checkInTime: Date(), checkOutTime: nil))
        manager.addGuest(Guest(id: UUID(), fullName: "Jane Smith", company: "SpaceX", phoneNumber: "0987654321", checkInTime: Date(), checkOutTime: Date()))
        return NavigationStack {
            GuestListForDateView(selectedDate: Date())
                .environmentObject(manager)
        }
    }
}
