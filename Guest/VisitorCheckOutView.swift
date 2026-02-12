import SwiftUI

struct VisitorCheckOutView: View {
    @EnvironmentObject var guestManager: GuestManager
    @Binding var showWelcome: Bool
    
    @State private var searchText = ""
    @State private var showCheckoutThankYou = false
    @State private var checkedOutVisitorName = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isViewVisible = false
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 0) {
            if showCheckoutThankYou {
                checkoutThankYouView
            } else {
                checkOutView
            }
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
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).delay(0.1)) {
                isViewVisible = true
            }
        }
    }
    
    private var checkOutView: some View {
        VStack(spacing: 0) {
            // Top navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        searchText = ""
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
            
            // Header
            VStack(spacing: 12) {
                Text("Visitor Check Out")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                
                Text("Search by name or pass number")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .opacity(isViewVisible ? 1 : 0)
            .offset(y: isViewVisible ? 0 : 20)
            
            // Search field
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(isSearchFieldFocused ? maroon : .gray)
                        .font(.system(size: 20))
                    
                    TextField("Enter name or pass number", text: $searchText)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .textContentType(.name)
                        .submitLabel(.search)
                        .focused($isSearchFieldFocused)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSearchFieldFocused ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isSearchFieldFocused ? maroon.opacity(0.1) : Color.clear, radius: 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .opacity(isViewVisible ? 1 : 0)
            .offset(y: isViewVisible ? 0 : 20)
            
            // Search results
            searchResultsView
            
            Spacer()
        }
    }
    
    private var searchResultsView: some View {
        VStack {
            if !searchText.isEmpty {
                if matchingVisitors.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No matching visitors found")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("Try searching by full name or pass number")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(matchingVisitors) { visitor in
                                VisitorCheckOutCard(
                                    visitor: visitor,
                                    onCheckOut: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            checkedOutVisitorName = visitor.fullName
                                            guestManager.checkOutVisitor(id: visitor.id ?? "")
                                            showCheckoutThankYou = true
                                        }
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
        }
    }
    
    private var matchingVisitors: [Visitor] {
        guestManager.visitors.filter { visitor in
            visitor.checkOutTime == nil && // Only show active visitors
            searchText.count >= 2 &&
            (visitor.fullName.lowercased().contains(searchText.lowercased()) ||
             visitor.passNumber.lowercased().contains(searchText.lowercased()))
        }
    }
    
    private var checkoutThankYouView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("See You Soon!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                
                Text("\(checkedOutVisitorName), thank you for visiting TM45.")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showCheckoutThankYou = false
                    searchText = ""
                    checkedOutVisitorName = ""
                    showWelcome = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20))
                    Text("Return to Home")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(maroon)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: maroon.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

struct VisitorCheckOutCard: View {
    let visitor: Visitor
    let onCheckOut: () -> Void
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                Text(visitor.fullName.prefix(2).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(visitor.fullName)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(visitor.company)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "number")
                            .font(.system(size: 12))
                        Text(visitor.passNumber)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(.blue)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                        Text("In: \(visitor.checkInTime.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onCheckOut) {
                HStack(spacing: 6) {
                    Text("Check Out")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.15), radius: 8, x: 0, y: 2)
    }
}

struct VisitorCheckOutView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = GuestManager()
        manager.addVisitor(Visitor(
            id: nil, // Let GuestManager generate the ID
            fullName: "John Visitor",
            company: "Tech Corp",
            phoneNumber: "1234567890",
            purpose: "Meeting",
            passNumber: "AB-1234",
            checkInTime: Date().addingTimeInterval(-3600),
            checkOutTime: nil
        ))
        return VisitorCheckOutView(showWelcome: .constant(false))
            .environmentObject(manager)
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
