import SwiftUI

struct VisitorCheckInOutView: View {
    @Binding var showWelcome: Bool
    @Binding var showVisitorCheckInOut: Bool
    @Binding var selectedAction: String?
    
    @State private var currentDate = Date()
    @State private var isViewVisible = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showVisitorCheckInOut = false
                        showWelcome = true
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(maroon)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .opacity(isViewVisible ? 1 : 0)
            
            Spacer()
            
            // Clock
            clockView
            
            // Title and subtitle
            VStack(spacing: 12) {
                Text("What would you like to do?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("Visitor Check-In/Out")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .opacity(isViewVisible ? 1 : 0)
            .offset(y: isViewVisible ? 0 : 15)
            
            // Action buttons
            VStack(spacing: 20) {
                ActionButton(
                    icon: "person.badge.plus",
                    label: "Check In",
                    subtitle: "Register your arrival",
                    color: .green
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedAction = "visitorCheckIn"
                        showVisitorCheckInOut = false
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                
                ActionButton(
                    icon: "person.badge.minus",
                    label: "Check Out",
                    subtitle: "Register your departure",
                    color: .red
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedAction = "visitorCheckOut"
                        showVisitorCheckInOut = false
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            .opacity(isViewVisible ? 1 : 0)
            .scaleEffect(isViewVisible ? 1 : 0.95)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    maroon.opacity(0.08),
                    Color.white.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onReceive(timer) { _ in
            currentDate = Date()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).delay(0.1)) {
                isViewVisible = true
            }
        }
    }
    
    private var clockView: some View {
        VStack(spacing: 8) {
            Text(formattedTime(currentDate))
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(maroon)
            
            Text(formattedDate(currentDate))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .opacity(isViewVisible ? 1 : 0)
        .offset(y: isViewVisible ? 0 : 15)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct VisitorCheckInOutView_Previews: PreviewProvider {
    static var previews: some View {
        VisitorCheckInOutView(
            showWelcome: .constant(false),
            showVisitorCheckInOut: .constant(true),
            selectedAction: .constant(nil)
        )
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
