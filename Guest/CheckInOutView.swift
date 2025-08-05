import SwiftUI

struct CheckInOutView: View {
    @Binding var showWelcome: Bool
    @Binding var showCheckInOut: Bool
    @Binding var selectedAction: String?
    
    @State private var currentDate = Date()
    @State private var isViewVisible = false
    @State private var isButtonPressed = false // For press animation
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 20) {
            clockView
            titleView
            buttonsView
            Spacer()
            bottomButtonView // Enhanced button styled like Get Started
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
            withAnimation(.easeInOut(duration: 0.2)) {
                currentDate = Date()
            }
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
                .transition(.opacity)
                .accessibilityLabel("Current time: \(formattedTime(currentDate))")
            
            Text(formattedDate(currentDate))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .accessibilityLabel("Current date: \(formattedDate(currentDate))")
        }
        .padding(.top, 30)
        .opacity(isViewVisible ? 1 : 0)
        .offset(y: isViewVisible ? 0 : 15)
    }
    
    private var titleView: some View {
        Text("What would you like to do?")
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 15)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .accessibilityAddTraits(.isHeader)
            .opacity(isViewVisible ? 1 : 0)
            .offset(y: isViewVisible ? 0 : 15)
    }
    
    private var buttonsView: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                CategoryBox(icon: "person.fill", label: "Check In") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedAction = "checkIn"
                        showCheckInOut = false
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                .accessibilityLabel("Check in a guest")
                .accessibilityHint("Opens the check-in form")
                .opacity(isViewVisible ? 1 : 0)
                .scaleEffect(isViewVisible ? 1 : 0.9)
                
                CategoryBox(icon: "person.fill.xmark", label: "Check Out") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedAction = "checkOut"
                        showCheckInOut = false
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                .accessibilityLabel("Check out a guest")
                .accessibilityHint("Opens the check-out form")
                .opacity(isViewVisible ? 1 : 0)
                .scaleEffect(isViewVisible ? 1 : 0.9)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var bottomButtonView: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCheckInOut = false
                showWelcome = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.uturn.left.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Return to Start")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
            }
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(maroon) // Use maroon instead of blue for branding
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: maroon.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .scaleEffect(isButtonPressed ? 0.95 : 1.0) // Press animation
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isButtonPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isButtonPressed = true }
                .onEnded { _ in isButtonPressed = false }
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 30) // Keeps at base
        .accessibilityLabel("Return to welcome screen")
        .accessibilityHint("Goes back to the main menu")
        .accessibilityAddTraits(.isButton)
        .opacity(isViewVisible ? 1 : 0)
        .scaleEffect(isViewVisible ? 1 : 0.9)
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

struct CheckInOutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInOutView(
            showWelcome: .constant(false),
            showCheckInOut: .constant(true),
            selectedAction: .constant(nil)
        )
        .environmentObject(GuestManager())
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
