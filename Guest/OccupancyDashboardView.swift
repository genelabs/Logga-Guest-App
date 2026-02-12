import SwiftUI

struct OccupancyDashboardView: View {
    @EnvironmentObject var guestManager: GuestManager
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    liveClockView
                    totalOccupancyCard
                    breakdownCards
                    activePeopleLists
                }
                .padding()
            }
            .navigationTitle("Building Occupancy")
            .background(Color(.systemGroupedBackground))
            .onReceive(timer) { _ in
                currentTime = Date()
            }
        }
    }
    
    private var liveClockView: some View {
        VStack(spacing: 8) {
            Text("Current Time")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(currentTime.formatted(date: .omitted, time: .standard))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
            
            Text(currentTime.formatted(date: .complete, time: .omitted))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    private var totalOccupancyCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 24))
                    .foregroundColor(maroon)
                
                Text("Total Building Occupancy")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(maroon)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("LIVE")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            Text("\(totalOccupancy)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
            
            Text("people currently in building")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    maroon.opacity(0.1),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: maroon.opacity(0.1), radius: 10)
    }
    
    private var breakdownCards: some View {
        HStack(spacing: 12) {
            OccupancyBreakdownCard(
                title: "Staff",
                count: activeStaffCount,
                icon: "person.fill",
                color: maroon,
                total: guestManager.guests.count
            )
            
            OccupancyBreakdownCard(
                title: "Visitors",
                count: activeVisitorCount,
                icon: "person.3.fill",
                color: .blue,
                total: guestManager.visitors.count
            )
        }
    }
    
    private var activePeopleLists: some View {
        VStack(spacing: 20) {
            if !activeStaff.isEmpty {
                activePeopleSection(
                    title: "Active Staff",
                    icon: "person.fill",
                    color: maroon,
                    people: activeStaff.map { ($0.fullName, $0.company, $0.checkInTime) }
                )
            }
            
            if !activeVisitors.isEmpty {
                activePeopleSection(
                    title: "Active Visitors",
                    icon: "person.3.fill",
                    color: .blue,
                    people: activeVisitors.map { ($0.fullName, $0.company, $0.checkInTime) }
                )
            }
            
            if activeStaff.isEmpty && activeVisitors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Building is Empty")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("No one is currently checked in")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(40)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }
    
    private func activePeopleSection(title: String, icon: String, color: Color, people: [(String, String, Date)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text("(\(people.count))")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            ForEach(Array(people.enumerated()), id: \.offset) { index, person in
                ActivePersonRow(
                    name: person.0,
                    company: person.1,
                    checkInTime: person.2,
                    color: color
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var totalOccupancy: Int {
        activeStaffCount + activeVisitorCount
    }
    
    private var activeStaffCount: Int {
        guestManager.getCheckedInGuests().count
    }
    
    private var activeVisitorCount: Int {
        guestManager.getCheckedInVisitors().count
    }
    
    private var activeStaff: [Guest] {
        guestManager.getCheckedInGuests().sorted { $0.checkInTime > $1.checkInTime }
    }
    
    private var activeVisitors: [Visitor] {
        guestManager.getCheckedInVisitors().sorted { $0.checkInTime > $1.checkInTime }
    }
}

struct OccupancyBreakdownCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    let total: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Text("of \(total) total")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ActivePersonRow: View {
    let name: String
    let company: String
    let checkInTime: Date
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                Text(name.prefix(2).uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Text(company)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Active")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                }
                
                Text(timeInBuilding)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var timeInBuilding: String {
        let interval = Date().timeIntervalSince(checkInTime)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
