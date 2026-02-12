import SwiftUI

struct ContentView: View {
    @StateObject private var guestManager = GuestManager()
    @State private var showWelcome = true
    @State private var showCheckInOut = false
    @State private var showVisitorCheckInOut = false
    @State private var showIssueReporting = false
    @State private var selectedAction: String? = nil
    
    var body: some View {
        NavigationStack {
            if showWelcome {
                WelcomeView(
                    showWelcome: $showWelcome,
                    showCheckInOut: $showCheckInOut,
                    showVisitorCheckInOut: $showVisitorCheckInOut,
                    showIssueReporting: $showIssueReporting
                )
                .environmentObject(guestManager)
            } else if showCheckInOut {
                CheckInOutView(
                    showWelcome: $showWelcome,
                    showCheckInOut: $showCheckInOut,
                    selectedAction: $selectedAction
                )
                .environmentObject(guestManager)
            } else if showVisitorCheckInOut {
                VisitorCheckInOutView(
                    showWelcome: $showWelcome,
                    showVisitorCheckInOut: $showVisitorCheckInOut,
                    selectedAction: $selectedAction
                )
                .environmentObject(guestManager)
            } else if showIssueReporting {
                IssueReportView(showWelcome: $showWelcome)
                    .environmentObject(guestManager)
            } else if let action = selectedAction {
                if action == "visitorCheckIn" {
                    VisitorCheckInView(showWelcome: $showWelcome)
                        .environmentObject(guestManager)
                } else if action == "visitorCheckOut" {
                    VisitorCheckOutView(showWelcome: $showWelcome)
                        .environmentObject(guestManager)
                } else {
                    GuestListView(action: action, showWelcome: $showWelcome)
                        .environmentObject(guestManager)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
