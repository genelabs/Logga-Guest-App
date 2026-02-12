import SwiftUI

struct VisitorCheckInView: View {
    @EnvironmentObject var guestManager: GuestManager
    @Binding var showWelcome: Bool
    
    @State private var fullName = ""
    @State private var company = ""
    @State private var phoneNumber = ""
    @State private var purpose = ""
    @State private var showThankYou = false
    @State private var currentStep = 1
    @State private var generatedPassNumber = ""
    
    // Photo capture states
    @State private var capturedPhoto: UIImage?
    @State private var showingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @State private var showingSourceSelector = false
    
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isCompanyFieldFocused: Bool
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isPurposeFieldFocused: Bool
    @State private var phoneError: String? = nil
    @State private var isViewVisible = false
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    private let totalSteps = 4  // Changed from 3 to 4 (added photo step)
    
    var body: some View {
        VStack(spacing: 0) {
            if showThankYou {
                thankYouView
            } else {
                checkInView
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
    
    private var checkInView: some View {
        VStack(spacing: 0) {
            // Top navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        resetForm()
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
            
            // Header with step indicator
            VStack(spacing: 20) {
                headerView
                stepIndicatorView
            }
            .opacity(isViewVisible ? 1 : 0)
            .offset(y: isViewVisible ? 0 : 20)
            
            // Content
            ScrollView {
                contentView
            }
            .scrollDismissesKeyboard(.interactively)
            
            Spacer()
            
            // Navigation buttons
            navigationButtonsView
                .opacity(isViewVisible ? 1 : 0)
                .offset(y: isViewVisible ? 0 : 20)
        }
        .padding(.bottom, 20)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Visitor Check In")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
            
            Text(stepDescription)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
    
    private var stepDescription: String {
        switch currentStep {
        case 1:
            return "Enter your details"
        case 2:
            return "Purpose of visit"
        case 3:
            return "Take visitor photo"
        case 4:
            return "Review and confirm"
        default:
            return ""
        }
    }
    
    private var stepIndicatorView: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? maroon : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(step == currentStep ? maroon : Color.clear, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
                
                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep ? maroon : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: 60)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            switch currentStep {
            case 1:
                stepOneView
            case 2:
                stepTwoView
            case 3:
                stepThreePhotoView
            case 4:
                confirmDetailsView
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    // MARK: - Step 1: Personal Details
    
    private var stepOneView: some View {
        VStack(spacing: 20) {
            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(maroon)
                
                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .foregroundColor(isNameFieldFocused ? maroon : .gray)
                        .font(.system(size: 20))
                    
                    TextField("Enter your full name", text: $fullName)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .textContentType(.name)
                        .submitLabel(.next)
                        .focused($isNameFieldFocused)
                        .onSubmit {
                            isCompanyFieldFocused = true
                        }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isNameFieldFocused ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isNameFieldFocused ? maroon.opacity(0.1) : Color.clear, radius: 8)
            }
            
            // Company input
            VStack(alignment: .leading, spacing: 8) {
                Text("Company")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(maroon)
                
                HStack(spacing: 12) {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(isCompanyFieldFocused ? maroon : .gray)
                        .font(.system(size: 20))
                    
                    TextField("Enter company name", text: $company)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .textContentType(.organizationName)
                        .submitLabel(.next)
                        .focused($isCompanyFieldFocused)
                        .onSubmit {
                            isPhoneFieldFocused = true
                        }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCompanyFieldFocused ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isCompanyFieldFocused ? maroon.opacity(0.1) : Color.clear, radius: 8)
            }
            
            // Phone input
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(maroon)
                
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(isPhoneFieldFocused ? maroon : .gray)
                        .font(.system(size: 20))
                    
                    TextField("Enter phone number", text: $phoneNumber)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .keyboardType(.phonePad)
                        .submitLabel(.next)
                        .focused($isPhoneFieldFocused)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isPhoneFieldFocused ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isPhoneFieldFocused ? maroon.opacity(0.1) : Color.clear, radius: 8)
                
                if let error = phoneError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Step 2: Purpose
    
    private var stepTwoView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Purpose of Visit")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(maroon)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(isPurposeFieldFocused ? maroon : .gray)
                        .font(.system(size: 20))
                        .padding(.top, 12)
                    
                    TextEditor(text: $purpose)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                        .focused($isPurposeFieldFocused)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isPurposeFieldFocused ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isPurposeFieldFocused ? maroon.opacity(0.1) : Color.clear, radius: 8)
                
                Text("E.g., Meeting with John Smith, Delivery, Job Interview")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Step 3: Photo Capture
    
    private var stepThreePhotoView: some View {
        VStack(spacing: 20) {
            Text("Visitor Photo")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(maroon)
            
            Text("Take a photo for the visitor badge (optional)")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Photo preview or placeholder
            if let photo = capturedPhoto {
                photoPreviewView(photo: photo)
            } else {
                photoPlaceholderView
            }
            
            Spacer()
            
            // Photo action buttons
            if capturedPhoto == nil {
                photoActionButtons
            }
        }
        .sheet(isPresented: $showingSourceSelector) {
            sourceSelectionSheet
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $capturedPhoto, sourceType: imagePickerSourceType)
        }
    }
    
    private func photoPreviewView(photo: UIImage) -> some View {
        VStack(spacing: 16) {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(maroon, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.2), radius: 10)
            
            Button(action: {
                showingSourceSelector = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.rotate")
                    Text("Retake Photo")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(maroon.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    private var photoPlaceholderView: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 300)
                
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No Photo")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            
            Text("Photo is optional but recommended for security")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var photoActionButtons: some View {
        VStack(spacing: 12) {
            if UIImagePickerController.isCameraAvailable {
                Button(action: {
                    imagePickerSourceType = .camera
                    showingImagePicker = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                        Text("Take Photo")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(maroon)
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            if UIImagePickerController.isPhotoLibraryAvailable {
                Button(action: {
                    imagePickerSourceType = .photoLibrary
                    showingImagePicker = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                        Text("Choose from Library")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(maroon)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(maroon, lineWidth: 2)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var sourceSelectionSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if UIImagePickerController.isCameraAvailable {
                    Button(action: {
                        showingSourceSelector = false
                        imagePickerSourceType = .camera
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                            Text("Take Photo")
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                if UIImagePickerController.isPhotoLibraryAvailable {
                    Button(action: {
                        showingSourceSelector = false
                        imagePickerSourceType = .photoLibrary
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                            Text("Choose from Library")
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
            .navigationTitle("Select Photo Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingSourceSelector = false
                    }
                }
            }
        }
        .presentationDetents([.height(250)])
    }
    
    // MARK: - Step 4: Confirmation
    
    private var confirmDetailsView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Almost Done!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                
                Text("Please confirm your details")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ConfirmationRow(icon: "person.fill", label: "Name", value: fullName)
                ConfirmationRow(icon: "building.2.fill", label: "Company", value: company)
                ConfirmationRow(icon: "phone.fill", label: "Phone", value: phoneNumber)
                ConfirmationRow(icon: "doc.text.fill", label: "Purpose", value: purpose)
                
                // Photo confirmation
                if let photo = capturedPhoto {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                                .foregroundColor(maroon)
                                .frame(width: 24)
                            
                            Text("Photo")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(maroon, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: maroon.opacity(0.1), radius: 10, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtonsView: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentStep -= 1
                        phoneError = nil
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.gray)
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if currentStep < totalSteps {
                        currentStep += 1
                    } else {
                        submitCheckIn()
                    }
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                HStack(spacing: 8) {
                    Text(currentStep == totalSteps ? "Check In" : (currentStep == 3 ? "Skip" : "Next"))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    if currentStep < totalSteps {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    isNextDisabled() ?
                    AnyShapeStyle(Color.gray.opacity(0.3)) :
                    AnyShapeStyle(LinearGradient(
                        gradient: Gradient(colors: [maroon, maroon.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: isNextDisabled() ? Color.clear : maroon.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(isNextDisabled())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Thank You View
    
    private var thankYouView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("All Set!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                
                Text("\(fullName) has been checked in successfully.")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                
                // Pass number display
                VStack(spacing: 12) {
                    Text("Your Visitor Pass Number")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(generatedPassNumber)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(maroon)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: maroon.opacity(0.2), radius: 10, x: 0, y: 4)
                        )
                }
                .padding(.top, 20)
                
                Text("Please keep this number for reference")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    resetForm()
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
    
    // MARK: - Supporting Views
    
    struct ConfirmationRow: View {
        let icon: String
        let label: String
        let value: String
        private let maroon = Color(red: 0.5, green: 0, blue: 0)
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(maroon)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(label == "Purpose" ? nil : 1)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func isNextDisabled() -> Bool {
        switch currentStep {
        case 1:
            if fullName.isEmpty || company.isEmpty || phoneNumber.isEmpty {
                return true
            }
            if !phoneNumber.isEmpty {
                let phoneRegex = "^[0-9+\\-() ]{7,}$"
                let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
                let isValid = predicate.evaluate(with: phoneNumber)
                phoneError = isValid ? nil : "Please enter a valid phone number"
                return !isValid
            }
            return false
        case 2:
            return purpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3:
            return false  // Photo is optional, never disable
        case 4:
            return false
        default:
            return true
        }
    }
    
    private func generatePassNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        let letterPart = String((0..<2).map { _ in letters.randomElement()! })
        let numberPart = String((0..<4).map { _ in numbers.randomElement()! })
        
        return "\(letterPart)-\(numberPart)"
    }
    
    private func submitCheckIn() {
        generatedPassNumber = generatePassNumber()
        
        // Convert photo to data
        let photoData = capturedPhoto?.jpegData(compressionQuality: 0.7)
        
        let newVisitor = Visitor(
            id: nil,
            fullName: fullName,
            company: company,
            phoneNumber: phoneNumber,
            purpose: purpose,
            passNumber: generatedPassNumber,
            checkInTime: Date(),
            checkOutTime: nil,
            photoData: photoData  // Include photo data
        )
        
        guestManager.addVisitor(newVisitor)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showThankYou = true
        }
    }
    
    private func resetForm() {
        showThankYou = false
        fullName = ""
        company = ""
        phoneNumber = ""
        purpose = ""
        generatedPassNumber = ""
        capturedPhoto = nil
        currentStep = 1
        phoneError = nil
        isNameFieldFocused = false
        isCompanyFieldFocused = false
        isPhoneFieldFocused = false
        isPurposeFieldFocused = false
    }
}

struct VisitorCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        VisitorCheckInView(showWelcome: .constant(false))
            .environmentObject(GuestManager())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
