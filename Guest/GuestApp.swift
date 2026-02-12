import SwiftUI

@main
struct GuestApp: App {
    @StateObject private var guestManager = GuestManager()
    @State private var showWelcome = true
    @State private var showCheckInOut = false
    @State private var showVisitorCheckInOut = false
    @State private var showIssueReporting = false
    @State private var selectedAction: String? = nil
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            if showWelcome {
                WelcomeView(
                    showWelcome: $showWelcome,
                    showCheckInOut: $showCheckInOut,
                    showVisitorCheckInOut: $showVisitorCheckInOut,
                    showIssueReporting: $showIssueReporting
                )
                .environmentObject(guestManager)
                .transition(.opacity.combined(with: .slide))
                .onAppear {
                    // Reset all states when returning to welcome
                    showCheckInOut = false
                    showVisitorCheckInOut = false
                    showIssueReporting = false
                    selectedAction = nil
                }
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        if showCheckInOut {
                            CheckInOutView(
                                showWelcome: $showWelcome,
                                showCheckInOut: $showCheckInOut,
                                selectedAction: $selectedAction
                            )
                        } else if showVisitorCheckInOut {
                            VisitorCheckInOutView(
                                showWelcome: $showWelcome,
                                showVisitorCheckInOut: $showVisitorCheckInOut,
                                selectedAction: $selectedAction
                            )
                        } else if showIssueReporting {
                            IssueReportView(showWelcome: $showWelcome)
                        } else if let action = selectedAction {
                            if action == "visitorCheckIn" {
                                VisitorCheckInView(showWelcome: $showWelcome)
                            } else if action == "visitorCheckOut" {
                                VisitorCheckOutView(showWelcome: $showWelcome)
                            } else {
                                GuestListView(action: action, showWelcome: $showWelcome)
                            }
                        } else {
                            CheckInOutView(
                                showWelcome: $showWelcome,
                                showCheckInOut: $showCheckInOut,
                                selectedAction: $selectedAction
                            )
                        }
                    }
                    .tabItem { Label("Guests", systemImage: "person.3") }
                    .tag(0)
                    
                    StatsView()
                        .tabItem { Label("Stats", systemImage: "chart.bar") }
                        .tag(1)
                    
                    IssueLogView()
                        .tabItem { Label("Issues", systemImage: "exclamationmark.bubble") }
                        .tag(2)
                }
                .environmentObject(guestManager)
            }
        }
    }
}

struct GuestApp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WelcomeView(
                showWelcome: .constant(true),
                showCheckInOut: .constant(false),
                showVisitorCheckInOut: .constant(false),
                showIssueReporting: .constant(false)
            )
            .environmentObject(GuestManager())
        }
    }
}
