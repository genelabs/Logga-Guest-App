import SwiftUI

struct ContentView: View {
    @State private var showWelcome = true
    @State private var showCheckInOut = false
    @State private var selectedAction: String? = nil
    
    var body: some View {
        NavigationStack {
            if showWelcome {
                WelcomeView(showWelcome: $showWelcome, showCheckInOut: $showCheckInOut)
                    .environmentObject(GuestManager())
            } else if showCheckInOut {
                CheckInOutView(showWelcome: $showWelcome, showCheckInOut: $showCheckInOut, selectedAction: $selectedAction)
                    .environmentObject(GuestManager())
            } else if let action = selectedAction {
                GuestListView(action: action, showWelcome: $showWelcome)
                    .environmentObject(GuestManager())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GuestManager())
    }
}
