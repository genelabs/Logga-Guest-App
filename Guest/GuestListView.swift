import SwiftUI

struct GuestListView: View {
    @EnvironmentObject var guestManager: GuestManager
    let action: String?
    @Binding var showWelcome: Bool
    
    @State private var fullName = ""
    @State private var company = ""
    @State private var phoneNumber = ""
    @State private var showThankYou = false
    @State private var currentStep = 1
    @State private var selectedGuest: Guest? = nil
    @FocusState private var isNameFieldFocused: Bool // Changed to @FocusState
    @FocusState private var isCompanyFieldFocused: Bool // Changed to @FocusState
    @FocusState private var isPhoneFieldFocused: Bool // Changed to @FocusState
    @FocusState private var isSearchFieldFocused: Bool // Changed to @FocusState
    @State private var isPreviousButtonPressed = false
    @State private var isNextButtonPressed = false
    @State private var isDoneButtonPressed = false
    @State private var isCancelButtonPressed = false
    
    @State private var searchName = ""
    @State private var showCheckoutThankYou = false
    @State private var checkedOutGuestName = ""
    @State private var phoneError: String? = nil
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 0) {
            if action == "checkIn" {
                if showThankYou {
                    thankYouView
                } else {
                    checkInView
                }
            } else if action == "checkOut" {
                if showCheckoutThankYou {
                    checkoutThankYouView
                } else {
                    checkOutView
                }
            } else {
                Text("Guest List Overview")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                    .padding(.top, 20)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [maroon.opacity(0.1), Color.white.opacity(0.95)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Check-In Views
    
    private var checkInView: some View {
        VStack(spacing: 20) {
            Spacer() // Center content vertically
            headerView
            ScrollView {
                contentView
            }
            .scrollDismissesKeyboard(.interactively)
            stepIndicatorView
            navigationButtonsView
            Spacer() // Center content vertically
        }
        .frame(maxHeight: .infinity)
        .padding(.bottom, 20)
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Check In a New Guest")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
                .accessibilityAddTraits(.isHeader)
            
            Text("Step \(currentStep) of \(selectedGuest == nil ? 3 : 2)")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .accessibilityLabel("Step \(currentStep) of \(selectedGuest == nil ? 3 : 2)")
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var stepIndicatorView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 5)
                    .fill(maroon)
                    .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(selectedGuest == nil ? 3 : 2), height: 6)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .accessibilityLabel("Progress: Step \(currentStep) of \(selectedGuest == nil ? 3 : 2)")
        }
        .frame(height: 26)
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            switch currentStep {
            case 1:
                stepOneView
            case 2:
                if selectedGuest != nil {
                    confirmGuestView
                } else {
                    stepTwoView
                }
            case 3:
                confirmDetailsView
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var stepOneView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(isNameFieldFocused ? maroon : .gray)
                    .font(.system(size: 20))
                TextField("Full Name", text: $fullName)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .textContentType(.name)
                    .submitLabel(.next)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isNameFieldFocused ? maroon : maroon.opacity(0.5), lineWidth: 2)
                    )
                    .scaleEffect(isNameFieldFocused ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isNameFieldFocused)
                    .focused($isNameFieldFocused)
                    .accessibilityLabel("Enter full name")
            }
            guestSuggestionsView
        }
    }
    
    private var guestSuggestionsView: some View {
        VStack {
            if !fullName.isEmpty && !matchingGuests.isEmpty {
                LazyVStack(spacing: 10) {
                    ForEach(matchingGuests) { guest in
                        ReturningGuestCard(
                            guest: guest,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedGuest = guest
                                    fullName = guest.fullName
                                    company = guest.company
                                    phoneNumber = guest.phoneNumber
                                    currentStep = 2
                                    isNameFieldFocused = false // Clear focus
                                    isCompanyFieldFocused = false
                                    isPhoneFieldFocused = false
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 10)
            } else {
                EmptyView()
            }
        }
    }
    
    private var matchingGuests: [Guest] {
        guestManager.guests.filter {
            $0.fullName.lowercased().contains(fullName.lowercased())
        }
    }
    
    private var stepTwoView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(isCompanyFieldFocused ? maroon : .gray)
                    .font(.system(size: 20))
                TextField("Company", text: $company)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .textContentType(.organizationName)
                    .submitLabel(.next)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCompanyFieldFocused ? maroon : maroon.opacity(0.5), lineWidth: 2)
                    )
                    .scaleEffect(isCompanyFieldFocused ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isCompanyFieldFocused)
                    .focused($isCompanyFieldFocused)
                    .accessibilityLabel("Enter company name")
            }
            
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(isPhoneFieldFocused ? maroon : .gray)
                    .font(.system(size: 20))
                TextField("Phone Number", text: $phoneNumber)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .keyboardType(.phonePad)
                    .submitLabel(.next)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isPhoneFieldFocused ? maroon : maroon.opacity(0.5), lineWidth: 2)
                    )
                    .scaleEffect(isPhoneFieldFocused ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isPhoneFieldFocused)
                    .focused($isPhoneFieldFocused)
                    .accessibilityLabel("Enter phone number")
            }
            
            if let error = phoneError {
                Text(error)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.top, 5)
                    .accessibilityLabel("Error: \(error)")
            }
        }
    }
    
    private var confirmGuestView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Confirm Check-In")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
                .accessibilityAddTraits(.isHeader)
            
            Text("Name: \(selectedGuest!.fullName)")
                .font(.system(size: 16, weight: .regular, design: .rounded))
            Text("Company: \(selectedGuest!.company)")
                .font(.system(size: 16, weight: .regular, design: .rounded))
            Text("Phone: \(selectedGuest!.phoneNumber)")
                .font(.system(size: 16, weight: .regular, design: .rounded))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.white, maroon.opacity(0.05)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .shadow(color: maroon.opacity(0.2), radius: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Confirm check-in for \(selectedGuest!.fullName), company \(selectedGuest!.company), phone \(selectedGuest!.phoneNumber)")
    }
    
    private var confirmDetailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Confirm Your Details")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
                .accessibilityAddTraits(.isHeader)
            
            Text("Name: \(fullName)")
                .font(.system(size: 16, weight: .regular, design: .rounded))
            Text("Company: \(company)")
                .font(.system(size: 16, weight: .regular, design: .rounded))
            Text("Phone: \(phoneNumber)")
                .font(.system(size: 16, weight: .regular, design: .rounded))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.white, maroon.opacity(0.05)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .shadow(color: maroon.opacity(0.2), radius: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Confirm details: name \(fullName), company \(company), phone \(phoneNumber)")
    }
    
    private var navigationButtonsView: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    resetForm()
                    showWelcome = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                Text("Cancel")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .scaleEffect(isCancelButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isCancelButtonPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isCancelButtonPressed = true }
                    .onEnded { _ in isCancelButtonPressed = false }
            )
            .accessibilityLabel("Cancel and return to welcome screen")
            
            if currentStep > 1 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if currentStep == 2 && selectedGuest != nil {
                            selectedGuest = nil
                        }
                        currentStep -= 1
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }) {
                    Text("Previous")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .scaleEffect(isPreviousButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPreviousButtonPressed)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPreviousButtonPressed = true }
                        .onEnded { _ in isPreviousButtonPressed = false }
                )
                .accessibilityLabel("Go to previous step")
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if selectedGuest != nil && currentStep == 2 {
                        submitCheckIn()
                    } else if currentStep < 3 {
                        currentStep += 1
                    } else {
                        submitCheckIn()
                    }
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                Text(selectedGuest != nil && currentStep == 2 ? "Confirm Check-In" : (currentStep == 3 ? "Confirm Check-In" : "Next"))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [maroon.opacity(0.9), maroon.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: maroon.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .scaleEffect(isNextButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isNextButtonPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isNextButtonPressed = true }
                    .onEnded { _ in isNextButtonPressed = false }
            )
            .disabled(isNextDisabled())
            .opacity(isNextDisabled() ? 0.6 : 1.0)
            .accessibilityLabel(currentStep == 3 || (selectedGuest != nil && currentStep == 2) ? "Confirm check-in" : "Go to next step")
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var thankYouView: some View {
        VStack(spacing: 20) {
            Text("Thank You!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.green)
                .accessibilityAddTraits(.isHeader)
            
            Text("\(fullName) has been successfully checked in.")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .foregroundColor(.gray)
                .accessibilityLabel("\(fullName) checked in successfully")
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    resetForm()
                    showWelcome = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [maroon.opacity(0.9), maroon.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: maroon.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .scaleEffect(isDoneButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDoneButtonPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isDoneButtonPressed = true }
                    .onEnded { _ in isDoneButtonPressed = false }
            )
            .padding(.horizontal, 20)
            .accessibilityLabel("Return to welcome screen")
        }
        .padding(.vertical, 30)
        .frame(maxHeight: .infinity)
        .opacity(showThankYou ? 1 : 0)
        .animation(.easeInOut(duration: 0.4), value: showThankYou)
    }
    
    // MARK: - Check-Out Views
    
    private var checkOutView: some View {
        VStack(spacing: 20) {
            Spacer() // Center content vertically
            Text("Check Out")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
                .padding(.top, 20)
                .accessibilityAddTraits(.isHeader)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(isSearchFieldFocused ? maroon : .gray)
                    .font(.system(size: 20))
                TextField("Enter Your Full Name", text: $searchName)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .textContentType(.name)
                    .submitLabel(.search)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSearchFieldFocused ? maroon : maroon.opacity(0.5), lineWidth: 2)
                    )
                    .scaleEffect(isSearchFieldFocused ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSearchFieldFocused)
                    .focused($isSearchFieldFocused)
                    .accessibilityLabel("Search for guest to check out")
            }
            .padding(.horizontal, 20)
            
            searchResultsView
            Spacer() // Center content vertically
        }
        .frame(maxHeight: .infinity)
    }
    
    private var searchResultsView: some View {
        VStack {
            if !searchName.isEmpty {
                if matchingCheckoutGuests.isEmpty {
                    Text("No matching guests found.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .accessibilityLabel("No guests found for search")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(matchingCheckoutGuests) { guest in
                                GuestCard(
                                    guest: guest,
                                    onCheckOut: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            checkedOutGuestName = guest.fullName
                                            guestManager.checkOutGuest(id: guest.id)
                                            showCheckoutThankYou = true
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxHeight: 300)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var matchingCheckoutGuests: [Guest] {
        guestManager.guests.filter {
            $0.fullName.lowercased().contains(searchName.lowercased()) && $0.checkOutTime == nil
        }
    }
    
    private var checkoutThankYouView: some View {
        VStack(spacing: 20) {
            Text("Thank You!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.green)
                .accessibilityAddTraits(.isHeader)
            
            Text("\(checkedOutGuestName), thank you for checking out. See you again soon!")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .foregroundColor(.gray)
                .accessibilityLabel("\(checkedOutGuestName) checked out successfully")
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showCheckoutThankYou = false
                    searchName = ""
                    checkedOutGuestName = ""
                    showWelcome = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                Text("Done")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [maroon.opacity(0.9), maroon.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: maroon.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .scaleEffect(isDoneButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDoneButtonPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isDoneButtonPressed = true }
                    .onEnded { _ in isDoneButtonPressed = false }
            )
            .padding(.horizontal, 20)
            .accessibilityLabel("Return to welcome screen")
        }
        .padding(.vertical, 30)
        .frame(maxHeight: .infinity)
        .opacity(showCheckoutThankYou ? 1 : 0)
        .animation(.easeInOut(duration: 0.4), value: showCheckoutThankYou)
    }
    
    // MARK: - Card Views
    
    struct ReturningGuestCard: View {
        let guest: Guest
        let onSelect: () -> Void
        private let maroon = Color(red: 0.5, green: 0, blue: 0)
        @State private var isPressed = false
        
        var body: some View {
            Button(action: {
                onSelect()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(guest.fullName)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(maroon)
                        Text("Company: \(guest.company)")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(maroon)
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.white, maroon.opacity(0.05)]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .shadow(color: maroon.opacity(isPressed ? 0.1 : 0.2), radius: 3)
                )
            }
            .buttonStyle(.plain)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            .accessibilityLabel("Select returning guest \(guest.fullName), company \(guest.company)")
        }
    }
    
    struct GuestCard: View {
        let guest: Guest
        let onCheckOut: () -> Void
        private let maroon = Color(red: 0.5, green: 0, blue: 0)
        @State private var isCheckOutButtonPressed = false
        
        var body: some View {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(guest.fullName)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(maroon)
                    Text("Company: \(guest.company)")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    onCheckOut()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }) {
                    Text("Check Out")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [maroon.opacity(0.9), maroon.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: maroon.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .scaleEffect(isCheckOutButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isCheckOutButtonPressed)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isCheckOutButtonPressed = true }
                        .onEnded { _ in isCheckOutButtonPressed = false }
                )
                .accessibilityLabel("Check out \(guest.fullName)")
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.white, maroon.opacity(0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .shadow(color: maroon.opacity(0.2), radius: 3)
            )
        }
    }
    
    // MARK: - Helpers
    
    private func isNextDisabled() -> Bool {
        switch currentStep {
        case 1: return fullName.isEmpty
        case 2:
            if selectedGuest != nil { return false }
            if !phoneNumber.isEmpty {
                let phoneRegex = "^[0-9+\\-() ]{7,}$"
                let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
                let isValid = predicate.evaluate(with: phoneNumber)
                phoneError = isValid ? nil : "Please enter a valid phone number"
                return company.isEmpty || !isValid
            }
            return company.isEmpty || phoneNumber.isEmpty
        case 3: return false
        default: return true
        }
    }
    
    private func submitCheckIn() {
        let newGuest = Guest(
            id: UUID(),
            fullName: fullName,
            company: company,
            phoneNumber: phoneNumber,
            checkInTime: Date(),
            checkOutTime: nil
        )
        guestManager.addGuest(newGuest)
        withAnimation(.easeInOut(duration: 0.3)) {
            showThankYou = true
        }
    }
    
    private func resetForm() {
        showThankYou = false
        fullName = ""
        company = ""
        phoneNumber = ""
        currentStep = 1
        selectedGuest = nil
        phoneError = nil
        isNameFieldFocused = false
        isCompanyFieldFocused = false
        isPhoneFieldFocused = false
    }
}

struct GuestListView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = GuestManager()
        manager.addGuest(Guest(id: UUID(), fullName: "John Doe", company: "xAI", phoneNumber: "1234567890", checkInTime: Date().addingTimeInterval(-86400), checkOutTime: nil))
        return NavigationStack {
            GuestListView(action: "checkIn", showWelcome: .constant(false))
                .environmentObject(manager)
        }
    }
}
