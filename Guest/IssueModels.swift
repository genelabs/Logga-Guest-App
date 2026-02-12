import SwiftUI
import Foundation

// MARK: - Issue Model
struct Issue: Identifiable, Codable, Hashable {
    var id: String?
    var reporterName: String
    var category: IssueCategory
    var priority: IssuePriority
    var location: String
    var description: String
    var photoData: Data?
    var reportedDate: Date
    var status: IssueStatus
    var resolvedDate: Date?
    var resolvedBy: String?
    var resolutionNotes: String?
    
    // Helper to get a valid ID
    var validId: String {
        id ?? UUID().uuidString
    }
    
    init(id: String? = nil, reporterName: String, category: IssueCategory, priority: IssuePriority, location: String, description: String, photoData: Data? = nil, reportedDate: Date, status: IssueStatus, resolvedDate: Date? = nil, resolvedBy: String? = nil, resolutionNotes: String? = nil) {
        self.id = id ?? UUID().uuidString
        self.reporterName = reporterName
        self.category = category
        self.priority = priority
        self.location = location
        self.description = description
        self.photoData = photoData
        self.reportedDate = reportedDate
        self.status = status
        self.resolvedDate = resolvedDate
        self.resolvedBy = resolvedBy
        self.resolutionNotes = resolutionNotes
    }
}

// MARK: - Issue Category
enum IssueCategory: String, Codable, CaseIterable {
    case maintenance = "maintenance"
    case it = "it"
    case safety = "safety"
    case facility = "facility"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .maintenance: return "Maintenance"
        case .it: return "IT/Tech"
        case .safety: return "Safety"
        case .facility: return "Facility"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .it: return "laptopcomputer"
        case .safety: return "exclamationmark.triangle.fill"
        case .facility: return "building.2.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Issue Priority
enum IssuePriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high: return "arrow.up.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Issue Status
enum IssueStatus: String, Codable, CaseIterable {
    case open = "open"
    case inProgress = "in_progress"
    case resolved = "resolved"
    
    var displayName: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        }
    }
    
    var icon: String {
        switch self {
        case .open: return "circle"
        case .inProgress: return "clock.fill"
        case .resolved: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .open: return .red
        case .inProgress: return .orange
        case .resolved: return .green
        }
    }
}
