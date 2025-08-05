import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @Binding var showCheckInOut: Bool // Added to transition to CheckInOutView
    @State private var currentDate = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 50) {
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
            
            Text("Welcome to TM45")
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 25),
                GridItem(.flexible(), spacing: 25)
            ], spacing: 25) {
                CategoryBox(icon: "person.fill", label: "Staff") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showWelcome = false
                        showCheckInOut = true // Transition to CheckInOutView
                    }
                }
                CategoryBox(icon: "hammer.fill", label: "Contractors")
                CategoryBox(icon: "person.3.fill", label: "Visitors")
                CategoryBox(icon: "ellipsis.circle.fill", label: "Others")
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showWelcome = false
                    showCheckInOut = true // Transition to CheckInOutView
                }
            }) {
                Text("Get Started")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [maroon.opacity(0.05), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onReceive(timer) { _ in
            currentDate = Date()
        }
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
    var action: (() -> Void)?
    
    @State private var isTapped = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
        }
        .frame(width: 140, height: 140)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .onTapGesture {
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
    
    init(icon: String, label: String) {
        self.icon = icon
        self.label = label
        self.action = nil
    }
    
    init(icon: String, label: String, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.action = action
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        struct PreviewWrapper: View {
            @State private var showWelcome = true
            @State private var showCheckInOut = false
            var body: some View {
                WelcomeView(showWelcome: $showWelcome, showCheckInOut: $showCheckInOut)
                    .environmentObject(GuestManager())
            }
        }
        return PreviewWrapper()
    }
}
