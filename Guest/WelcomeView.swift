import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @Binding var showCheckInOut: Bool
    @Binding var showVisitorCheckInOut: Bool
    @Binding var showIssueReporting: Bool
    @State private var currentDate = Date()
    @State private var isViewVisible = false
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var boxSize: CGFloat {
        sizeClass == .regular ? 160 : 140
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Clock
            clockView
            
            // Welcome message
            welcomeMessageView
            
            // Category boxes
            categoryGridView
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    maroon.opacity(0.1),
                    Color.white,
                    maroon.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
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
        VStack(spacing: 15) {
            Text(formattedTime(currentDate))
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(maroon)
            
            Text(formattedDate(currentDate))
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
        .opacity(isViewVisible ? 1 : 0)
        .offset(y: isViewVisible ? 0 : 20)
    }
    
    private var welcomeMessageView: some View {
        VStack(spacing: 8) {
            Text("Welcome to TM45")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
                .multilineTextAlignment(.center)
            
            Text("Please select your category to begin")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .opacity(isViewVisible ? 1 : 0)
        .offset(y: isViewVisible ? 0 : 20)
    }
    
    private var categoryGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 25),
            GridItem(.flexible(), spacing: 25)
        ], spacing: 25) {
            CategoryBox(
                icon: "person.fill",
                label: "Staff",
                iconColor: maroon,
                size: boxSize
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showWelcome = false
                    showCheckInOut = true
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .opacity(isViewVisible ? 1 : 0)
            .scaleEffect(isViewVisible ? 1 : 0.9)
            
            CategoryBox(
                icon: "wrench.and.screwdriver.fill",
                label: "Maintenance",
                iconColor: maroon,
                size: boxSize,
                isComingSoon: true
            )
            .opacity(isViewVisible ? 1 : 0)
            .scaleEffect(isViewVisible ? 1 : 0.9)
            
            CategoryBox(
                icon: "person.3.fill",
                label: "Visitors",
                iconColor: maroon,
                size: boxSize
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showWelcome = false
                    showVisitorCheckInOut = true
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .opacity(isViewVisible ? 1 : 0)
            .scaleEffect(isViewVisible ? 1 : 0.9)
            
            CategoryBox(
                icon: "exclamationmark.bubble.fill",
                label: "Issue Logs",
                iconColor: maroon,
                size: boxSize
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showWelcome = false
                    showIssueReporting = true
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .opacity(isViewVisible ? 1 : 0)
            .scaleEffect(isViewVisible ? 1 : 0.9)
        }
        .padding(.horizontal, 40)
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

struct CategoryBox: View {
    let icon: String
    let label: String
    let iconColor: Color
    let size: CGFloat
    var isComingSoon: Bool = false
    var action: (() -> Void)?
    
    @State private var isTapped = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(iconColor)
                .symbolEffect(.bounce, value: isTapped)
            
            Text(label)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
            
            if isComingSoon {
                Text("Coming Soon")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 3)
        .opacity(isComingSoon ? 0.6 : 1.0)
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .onTapGesture {
            if !isComingSoon {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isTapped = false
                    }
                    action?()
                }
            }
        }
        .accessibilityLabel(isComingSoon ? "\(label), coming soon" : label)
        .accessibilityHint(isComingSoon ? "This feature is not yet available" : "Opens \(label.lowercased()) check-in")
    }
    
    init(icon: String, label: String, iconColor: Color = .black, size: CGFloat = 140, isComingSoon: Bool = false) {
        self.icon = icon
        self.label = label
        self.iconColor = iconColor
        self.size = size
        self.isComingSoon = isComingSoon
        self.action = nil
    }
    
    init(icon: String, label: String, iconColor: Color = .black, size: CGFloat = 140, isComingSoon: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.iconColor = iconColor
        self.size = size
        self.isComingSoon = isComingSoon
        self.action = action
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        struct PreviewWrapper: View {
            @State private var showWelcome = true
            @State private var showCheckInOut = false
            @State private var showVisitorCheckInOut = false
            @State private var showIssueReporting = false
            var body: some View {
                WelcomeView(
                    showWelcome: $showWelcome,
                    showCheckInOut: $showCheckInOut,
                    showVisitorCheckInOut: $showVisitorCheckInOut,
                    showIssueReporting: $showIssueReporting
                )
            }
        }
        return PreviewWrapper()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
