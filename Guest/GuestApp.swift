import SwiftUI

@main
struct GuestApp: App {
    @StateObject private var guestManager = GuestManager()
    @State private var showWelcome = true
    @State private var showCheckInOut = false
    @State private var selectedAction: String? = nil
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            if showWelcome {
                WelcomeView(showWelcome: $showWelcome, showCheckInOut: $showCheckInOut)
                    .environmentObject(guestManager)
                    .transition(.opacity.combined(with: .slide)) // Fade + slide transition
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        if showCheckInOut {
                            CheckInOutView(showWelcome: $showWelcome, showCheckInOut: $showCheckInOut, selectedAction: $selectedAction)
                        } else if let action = selectedAction {
                            GuestListView(action: action, showWelcome: $showWelcome)
                        } else {
                            CheckInOutView(showWelcome: $showWelcome, showCheckInOut: $showCheckInOut, selectedAction: $selectedAction)
                        }
                    }
                    .tabItem { Label("Guests", systemImage: "person.3") }
                    .tag(0)
                    
                    StatsView()
                        .tabItem { Label("Stats", systemImage: "chart.bar") }
                        .tag(1)
                }
                .environmentObject(guestManager)
            }
        }
    }
}

struct GuestApp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WelcomeView(showWelcome: .constant(true), showCheckInOut: .constant(false))
                .environmentObject(GuestManager())
        }
    }
}
