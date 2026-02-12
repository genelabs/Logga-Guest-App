import SwiftUI

struct IssueLogView: View {
    @EnvironmentObject var guestManager: GuestManager
    @State private var selectedFilter: IssueFilter = .all
    @State private var searchText = ""
    @State private var selectedIssue: Issue?
    @State private var showingIssueDetail = false
    
    private let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with stats
                headerView
                
                // Filter tabs
                filterTabsView
                
                // Search bar
                searchBarView
                
                // Issue list
                issueListView
            }
            .navigationTitle("Issue Log")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .sheet(item: $selectedIssue) { issue in
                IssueDetailView(issue: issue)
                    .environmentObject(guestManager)
            }
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 15) {
            StatBadge(
                count: guestManager.issues.filter { $0.status == .open }.count,
                label: "Open",
                color: .red
            )
            StatBadge(
                count: guestManager.issues.filter { $0.status == .inProgress }.count,
                label: "In Progress",
                color: .orange
            )
            StatBadge(
                count: guestManager.issues.filter { $0.status == .resolved }.count,
                label: "Resolved",
                color: .green
            )
        }
        .padding()
        .background(Color.white)
    }
    
    private var filterTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(IssueFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        count: filterCount(for: filter)
                    ) {
                        withAnimation {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color.white)
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search issues...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    private var issueListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredIssues.isEmpty {
                    EmptyIssuesView(filter: selectedFilter)
                } else {
                    ForEach(filteredIssues) { issue in
                        IssueRow(issue: issue) {
                            selectedIssue = issue
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var filteredIssues: [Issue] {
        var result = guestManager.issues
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .open:
            result = result.filter { $0.status == .open }
        case .inProgress:
            result = result.filter { $0.status == .inProgress }
        case .resolved:
            result = result.filter { $0.status == .resolved }
        case .highPriority:
            result = result.filter { $0.priority == .high && $0.status != .resolved }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.location.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased()) ||
                $0.reporterName.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Sort by date (newest first)
        return result.sorted { $0.reportedDate > $1.reportedDate }
    }
    
    private func filterCount(for filter: IssueFilter) -> Int {
        switch filter {
        case .all:
            return guestManager.issues.count
        case .open:
            return guestManager.issues.filter { $0.status == .open }.count
        case .inProgress:
            return guestManager.issues.filter { $0.status == .inProgress }.count
        case .resolved:
            return guestManager.issues.filter { $0.status == .resolved }.count
        case .highPriority:
            return guestManager.issues.filter { $0.priority == .high && $0.status != .resolved }.count
        }
    }
}

// MARK: - Supporting Views

struct StatBadge: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FilterTab: View {
    let filter: IssueFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(filter.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                
                Text("\(count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? filter.color : Color(.systemGray6))
            .cornerRadius(20)
        }
    }
}

struct IssueRow: View {
    let issue: Issue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Priority indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(issue.priority.color)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: issue.category.icon)
                            .font(.system(size: 14))
                            .foregroundColor(issue.category == .safety ? .red : .secondary)
                        
                        Text(issue.category.displayName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Status badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(issue.status.color)
                                .frame(width: 6, height: 6)
                            Text(issue.status.displayName)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(issue.status.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(issue.status.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Text(issue.location)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(issue.description)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label(issue.reporterName, systemImage: "person.fill")
                        Label(issue.reportedDate.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                    }
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyIssuesView: View {
    let filter: IssueFilter
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text(emptyMessage)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    private var emptyMessage: String {
        switch filter {
        case .all:
            return "No issues reported yet"
        case .open:
            return "No open issues"
        case .inProgress:
            return "No issues in progress"
        case .resolved:
            return "No resolved issues"
        case .highPriority:
            return "No high priority issues"
        }
    }
}

enum IssueFilter: CaseIterable {
    case all
    case open
    case inProgress
    case resolved
    case highPriority
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .highPriority: return "High Priority"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .open: return .red
        case .inProgress: return .orange
        case .resolved: return .green
        case .highPriority: return .purple
        }
    }
}

struct IssueLogView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = GuestManager()
        manager.addIssue(Issue(
            reporterName: "John Doe",
            category: .maintenance,
            priority: .high,
            location: "Building A, Room 101",
            description: "Broken window needs immediate repair",
            reportedDate: Date(),
            status: .open
        ))
        return IssueLogView()
            .environmentObject(manager)
    }
}
