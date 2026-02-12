import SwiftUI

struct IssueDetailView: View {
    @EnvironmentObject var guestManager: GuestManager
    @Environment(\.dismiss) var dismiss
    let issue: Issue
    
    @State private var showingStatusUpdate = false
    @State private var newStatus: IssueStatus
    @State private var resolvedBy = ""
    @State private var resolutionNotes = ""
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    init(issue: Issue) {
        self.issue = issue
        _newStatus = State(initialValue: issue.status)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status card
                    statusCardView
                    
                    // Priority & Category
                    priorityCategoryView
                    
                    // Location
                    locationView
                    
                    // Description
                    descriptionView
                    
                    // Photo (if available)
                    if let photoData = issue.photoData,
                       let uiImage = UIImage(data: photoData) {
                        photoView(image: uiImage)
                    }
                    
                    // Reporter info
                    reporterInfoView
                    
                    // Resolution info (if resolved)
                    if issue.status == .resolved {
                        resolutionInfoView
                    }
                    
                    // Update status button
                    if issue.status != .resolved {
                        updateStatusButtonView
                    }
                }
                .padding()
            }
            .navigationTitle("Issue Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingStatusUpdate) {
                statusUpdateSheet
            }
        }
    }
    
    private var statusCardView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: issue.status.icon)
                        .font(.system(size: 24))
                        .foregroundColor(issue.status.color)
                    
                    Text(issue.status.displayName)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(issue.status.color)
                }
                
                Text("Issue #\(issue.id?.suffix(8) ?? "Unknown")")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(issue.status.color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var priorityCategoryView: some View {
        HStack(spacing: 12) {
            // Priority
            VStack(spacing: 8) {
                Image(systemName: issue.priority.icon)
                    .font(.system(size: 24))
                    .foregroundColor(issue.priority.color)
                
                Text(issue.priority.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Text("Priority")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
            
            // Category
            VStack(spacing: 8) {
                Image(systemName: issue.category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(maroon)
                
                Text(issue.category.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Text("Category")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
    
    private var locationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Location", systemImage: "location.fill")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(issue.location)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Description", systemImage: "text.alignleft")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(issue.description)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private func photoView(image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Photo", systemImage: "photo")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var reporterInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Reported By", systemImage: "person.fill")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(issue.reporterName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    Text(issue.reportedDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var resolutionInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Resolution", systemImage: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.green)
            
            if let resolvedBy = issue.resolvedBy {
                HStack {
                    Text("Resolved by:")
                        .foregroundColor(.secondary)
                    Text(resolvedBy)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14, design: .rounded))
            }
            
            if let resolvedDate = issue.resolvedDate {
                HStack {
                    Text("Resolved on:")
                        .foregroundColor(.secondary)
                    Text(resolvedDate.formatted(date: .abbreviated, time: .shortened))
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14, design: .rounded))
            }
            
            if let notes = issue.resolutionNotes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes:")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(notes)
                        .font(.system(size: 15, design: .rounded))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var updateStatusButtonView: some View {
        Button(action: {
            showingStatusUpdate = true
        }) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Update Status")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(maroon)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var statusUpdateSheet: some View {
        NavigationStack {
            Form {
                Section("Change Status") {
                    Picker("Status", selection: $newStatus) {
                        ForEach([IssueStatus.open, .inProgress, .resolved], id: \.self) { status in
                            HStack {
                                Image(systemName: status.icon)
                                Text(status.displayName)
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if newStatus == .resolved {
                    Section("Resolution Details") {
                        TextField("Resolved by", text: $resolvedBy)
                        
                        TextField("Notes (optional)", text: $resolutionNotes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("Update Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingStatusUpdate = false
                        newStatus = issue.status
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateStatus()
                    }
                    .disabled(newStatus == .resolved && resolvedBy.isEmpty)
                }
            }
        }
    }
    
    private func updateStatus() {
        guestManager.updateIssueStatus(
            id: issue.id ?? "",
            status: newStatus,
            resolvedBy: newStatus == .resolved ? resolvedBy : nil,
            notes: newStatus == .resolved ? resolutionNotes : nil
        )
        showingStatusUpdate = false
        dismiss()
    }
}

struct IssueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        IssueDetailView(issue: Issue(
            reporterName: "John Doe",
            category: .maintenance,
            priority: .high,
            location: "Building A, Room 101",
            description: "Broken window needs immediate repair",
            reportedDate: Date(),
            status: .open
        ))
        .environmentObject(GuestManager())
    }
}
