import SwiftUI
import PhotosUI

struct IssueReportView: View {
    @EnvironmentObject var guestManager: GuestManager
    @Binding var showWelcome: Bool
    
    @State private var reporterName = ""
    @State private var category: IssueCategory = .maintenance
    @State private var priority: IssuePriority = .medium
    @State private var location = ""
    @State private var issueDescription = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showThankYou = false
    @State private var isViewVisible = false
    
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isLocationFieldFocused: Bool
    @FocusState private var isDescriptionFieldFocused: Bool
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        VStack(spacing: 0) {
            if showThankYou {
                thankYouView
            } else {
                reportFormView
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
    
    private var reportFormView: some View {
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
            
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 50))
                    .foregroundColor(maroon)
                
                Text("Report an Issue")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                
                Text("Help us improve TM45")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .opacity(isViewVisible ? 1 : 0)
            .offset(y: isViewVisible ? 0 : 20)
            
            // Form
            ScrollView {
                VStack(spacing: 20) {
                    nameFieldView
                    categoryPickerView
                    priorityPickerView
                    locationFieldView
                    descriptionFieldView
                    photoPickerView
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Submit button
            submitButtonView
        }
    }
    
    private var nameFieldView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Name (Optional)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
            
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .foregroundColor(isNameFieldFocused ? maroon : .gray)
                    .font(.system(size: 20))
                
                TextField("Enter your name", text: $reporterName)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .textContentType(.name)
                    .submitLabel(.next)
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        isLocationFieldFocused = true
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
    }
    
    private var categoryPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Issue Category")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(IssueCategory.allCases, id: \.self) { cat in
                    CategoryButton(
                        category: cat,
                        isSelected: category == cat,
                        maroon: maroon
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            category = cat
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
        }
    }
    
    private var priorityPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Priority Level")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
            
            HStack(spacing: 12) {
                ForEach(IssuePriority.allCases, id: \.self) { pri in
                    PriorityButton(
                        priority: pri,
                        isSelected: priority == pri
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            priority = pri
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
        }
    }
    
    private var locationFieldView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
            
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(isLocationFieldFocused ? maroon : .gray)
                    .font(.system(size: 20))
                
                TextField("e.g., Building A, Room 101", text: $location)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .submitLabel(.next)
                    .focused($isLocationFieldFocused)
                    .onSubmit {
                        isDescriptionFieldFocused = true
                    }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isLocationFieldFocused ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: isLocationFieldFocused ? maroon.opacity(0.1) : Color.clear, radius: 8)
        }
    }
    
    private var descriptionFieldView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Issue Description")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.alignleft")
                    .foregroundColor(isDescriptionFieldFocused ? maroon : .gray)
                    .font(.system(size: 20))
                    .padding(.top, 12)
                
                TextEditor(text: $issueDescription)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .focused($isDescriptionFieldFocused)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDescriptionFieldFocused ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: isDescriptionFieldFocused ? maroon.opacity(0.1) : Color.clear, radius: 8)
            
            Text("Describe the issue in detail")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
        }
    }
    
    private var photoPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Photo (Optional)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(maroon)
            
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack {
                    Image(systemName: photoData != nil ? "photo.fill" : "camera.fill")
                        .font(.system(size: 20))
                    
                    Text(photoData != nil ? "Photo Added" : "Take or Select Photo")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    
                    Spacer()
                    
                    if photoData != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .foregroundColor(photoData != nil ? .green : maroon)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(photoData != nil ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
    }
    
    private var submitButtonView: some View {
        Button(action: {
            submitIssue()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                Text("Submit Issue Report")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isFormValid() ? maroon : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: isFormValid() ? maroon.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isFormValid())
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    private var thankYouView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Issue Reported!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(maroon)
                
                Text("Thank you for helping us improve TM45. We'll look into this issue.")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
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
    
    // MARK: - Helpers
    
    private func isFormValid() -> Bool {
        !location.isEmpty && !issueDescription.isEmpty
    }
    
    private func submitIssue() {
        let newIssue = Issue(
            id: nil,
            reporterName: reporterName.isEmpty ? "Anonymous" : reporterName,
            category: category,
            priority: priority,
            location: location,
            description: issueDescription,
            photoData: photoData,
            reportedDate: Date(),
            status: .open
        )
        
        guestManager.addIssue(newIssue)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showThankYou = true
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func resetForm() {
        reporterName = ""
        category = .maintenance
        priority = .medium
        location = ""
        issueDescription = ""
        selectedPhoto = nil
        photoData = nil
        showThankYou = false
    }
}

// MARK: - Supporting Views

struct CategoryButton: View {
    let category: IssueCategory
    let isSelected: Bool
    let maroon: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : maroon)
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? maroon : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? maroon : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: isSelected ? maroon.opacity(0.2) : Color.clear, radius: 5)
        }
        .buttonStyle(.plain)
    }
}

struct PriorityButton: View {
    let priority: IssuePriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: priority.icon)
                    .font(.system(size: 20))
                
                Text(priority.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? priority.color : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : priority.color)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? priority.color : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: isSelected ? priority.color.opacity(0.3) : Color.clear, radius: 5)
        }
        .buttonStyle(.plain)
    }
}

struct IssueReportView_Previews: PreviewProvider {
    static var previews: some View {
        IssueReportView(showWelcome: .constant(false))
            .environmentObject(GuestManager())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
