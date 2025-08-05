import SwiftUI

struct StatsView: View {
    @EnvironmentObject var guestManager: GuestManager
    @State private var selectedDate = Date()
    @State private var navigateToGuestList = false // Controls navigation
    @State private var buttonScale: CGFloat = 1.0 // Animation for button
    
    // Define maroon color
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    // Compute counts for selected date
    private var checkedInCount: Int {
        let calendar = Calendar.current
        return guestManager.guests.filter { guest in
            calendar.isDate(guest.checkInTime, inSameDayAs: selectedDate) && guest.checkOutTime == nil
        }.count
    }
    
    private var checkedOutCount: Int {
        let calendar = Calendar.current
        return guestManager.guests.filter { guest in
            if let checkOutTime = guest.checkOutTime {
                return calendar.isDate(checkOutTime, inSameDayAs: selectedDate)
            }
            return false
        }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Guest Statistics")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                    .padding(.top, 20)
                
                // Modern counters with icons
                HStack(spacing: 20) {
                    CounterCard(
                        title: "Checked In",
                        count: checkedInCount,
                        color: maroon,
                        icon: "person.fill.checkmark"
                    )
                    CounterCard(
                        title: "Checked Out",
                        count: checkedOutCount,
                        color: maroon,
                        icon: "person.fill.xmark"
                    )
                }
                .padding(.horizontal)
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .accentColor(maroon)
                .padding(.horizontal)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                
                Button(action: {
                    navigateToGuestList = true // Trigger navigation
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("View Guests for \(formattedDate(selectedDate))")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [maroon, maroon.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: maroon.opacity(0.3), radius: 5, x: 0, y: 2)
                    .scaleEffect(buttonScale)
                }
                .padding(.horizontal)
                .simultaneousGesture(TapGesture().onEnded {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            buttonScale = 1.0
                        }
                    }
                })
                
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.05), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationDestination(isPresented: $navigateToGuestList) {
                GuestListForDateView(selectedDate: selectedDate)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Modernized counter card with icon
    struct CounterCard: View {
        let title: String
        let count: Int
        let color: Color
        let icon: String
        
        @State private var scale: CGFloat = 1.0
        
        var body: some View {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.05
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = GuestManager()
        manager.addGuest(Guest(id: UUID(), fullName: "John Doe", company: "xAI", phoneNumber: "1234567890", checkInTime: Date(), checkOutTime: nil))
        manager.addGuest(Guest(id: UUID(), fullName: "Jane Smith", company: "SpaceX", phoneNumber: "0987654321", checkInTime: Date(), checkOutTime: Date()))
        return NavigationStack {
            StatsView()
                .environmentObject(manager)
        }
    }
}
