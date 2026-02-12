import SwiftUI
import Foundation

// TEMPORARY: Use this version first to make sure the app compiles
// Once we fix the Firebase installation, we'll replace this

// MARK: - Guest Model (STAFF ONLY)
struct Guest: Identifiable, Codable, Hashable {
    var id: String? // Changed to String for Firebase compatibility
    var fullName: String
    var company: String
    var phoneNumber: String
    var checkInTime: Date
    var checkOutTime: Date?
    
    // Helper to get a valid ID
    var validId: String {
        id ?? UUID().uuidString
    }
    
    init(id: String? = nil, fullName: String, company: String, phoneNumber: String, checkInTime: Date, checkOutTime: Date? = nil) {
        self.id = id ?? UUID().uuidString
        self.fullName = fullName
        self.company = company
        self.phoneNumber = phoneNumber
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
    }
}

// MARK: - Visitor Model (VISITORS ONLY)
struct Visitor: Identifiable, Codable, Hashable {
    var id: String? // Changed to String for Firebase compatibility
    var fullName: String
    var company: String
    var phoneNumber: String
    var purpose: String
    var passNumber: String
    var checkInTime: Date
    var checkOutTime: Date?
    var photoData: Data? // ADDED: Photo captured during check-in
    
    // Helper to get a valid ID
    var validId: String {
        id ?? UUID().uuidString
    }
    
    init(id: String? = nil, fullName: String, company: String, phoneNumber: String, purpose: String, passNumber: String, checkInTime: Date, checkOutTime: Date? = nil, photoData: Data? = nil) {
        self.id = id ?? UUID().uuidString
        self.fullName = fullName
        self.company = company
        self.phoneNumber = phoneNumber
        self.purpose = purpose
        self.passNumber = passNumber
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.photoData = photoData // ADDED: Store photo data
    }
}

// MARK: - Guest Manager (Local Storage - Temporary)
// This version stores data locally using UserDefaults
// Replace with FirebaseManager once Firebase is set up

class GuestManager: ObservableObject {
    @Published var guests: [Guest] = []
    @Published var visitors: [Visitor] = []
    @Published var issues: [Issue] = []
    
    private let guestsKey = "saved_guests"
    private let visitorsKey = "saved_visitors"
    private let issuesKey = "saved_issues"
    
    init() {
        loadData()
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        // Load guests
        if let guestsData = UserDefaults.standard.data(forKey: guestsKey),
           let decodedGuests = try? JSONDecoder().decode([Guest].self, from: guestsData) {
            guests = decodedGuests
            print("✅ Loaded \(guests.count) staff members from local storage")
        }
        
        // Load visitors
        if let visitorsData = UserDefaults.standard.data(forKey: visitorsKey),
           let decodedVisitors = try? JSONDecoder().decode([Visitor].self, from: visitorsData) {
            visitors = decodedVisitors
            print("✅ Loaded \(visitors.count) visitors from local storage")
        }
        
        // Load issues
        if let issuesData = UserDefaults.standard.data(forKey: issuesKey),
           let decodedIssues = try? JSONDecoder().decode([Issue].self, from: issuesData) {
            issues = decodedIssues
            print("✅ Loaded \(issues.count) issues from local storage")
        }
    }
    
    private func saveGuests() {
        if let encoded = try? JSONEncoder().encode(guests) {
            UserDefaults.standard.set(encoded, forKey: guestsKey)
            print("💾 Saved \(guests.count) staff members")
        }
    }
    
    private func saveVisitors() {
        if let encoded = try? JSONEncoder().encode(visitors) {
            UserDefaults.standard.set(encoded, forKey: visitorsKey)
            print("💾 Saved \(visitors.count) visitors")
        }
    }
    
    private func saveIssues() {
        if let encoded = try? JSONEncoder().encode(issues) {
            UserDefaults.standard.set(encoded, forKey: issuesKey)
            print("💾 Saved \(issues.count) issues")
        }
    }
    
    // MARK: - Guest (Staff) Methods
    
    func addGuest(_ guest: Guest) {
        var newGuest = guest
        if newGuest.id == nil {
            newGuest.id = UUID().uuidString
        }
        guests.append(newGuest)
        saveGuests()
        print("✅ Adding STAFF: \(guest.fullName) to guests array")
        print("📊 Total Staff: \(guests.count), Total Visitors: \(visitors.count)")
    }
    
    func checkOutGuest(id: String) {
        if let index = guests.firstIndex(where: { $0.id == id }) {
            guests[index].checkOutTime = Date()
            saveGuests()
            print("✅ Checked out STAFF: \(guests[index].fullName)")
        }
    }
    
    func removeGuest(id: String) {
        guests.removeAll { $0.id == id }
        saveGuests()
    }
    
    // MARK: - Visitor Methods
    
    func addVisitor(_ visitor: Visitor) {
        var newVisitor = visitor
        if newVisitor.id == nil {
            newVisitor.id = UUID().uuidString
        }
        visitors.append(newVisitor)
        saveVisitors()
        print("✅ Adding VISITOR: \(visitor.fullName) to visitors array")
        print("📊 Total Staff: \(guests.count), Total Visitors: \(visitors.count)")
    }
    
    func checkOutVisitor(id: String) {
        if let index = visitors.firstIndex(where: { $0.id == id }) {
            visitors[index].checkOutTime = Date()
            saveVisitors()
            print("✅ Checked out VISITOR: \(visitors[index].fullName)")
        }
    }
    
    func removeVisitor(id: String) {
        visitors.removeAll { $0.id == id }
        saveVisitors()
    }
    
    // MARK: - Issue Methods
    
    func addIssue(_ issue: Issue) {
        var newIssue = issue
        if newIssue.id == nil {
            newIssue.id = UUID().uuidString
        }
        issues.append(newIssue)
        saveIssues()
        print("✅ Adding ISSUE: \(issue.category.displayName) - \(issue.location)")
        print("📊 Total Issues: \(issues.count)")
    }
    
    func updateIssueStatus(id: String, status: IssueStatus, resolvedBy: String? = nil, notes: String? = nil) {
        if let index = issues.firstIndex(where: { $0.id == id }) {
            issues[index].status = status
            if status == .resolved {
                issues[index].resolvedDate = Date()
                issues[index].resolvedBy = resolvedBy
                issues[index].resolutionNotes = notes
            }
            saveIssues()
            print("✅ Updated issue status to \(status.displayName)")
        }
    }
    
    func removeIssue(id: String) {
        issues.removeAll { $0.id == id }
        saveIssues()
    }
    
    func getOpenIssues() -> [Issue] {
        issues.filter { $0.status == .open }
    }
    
    func getIssuesByPriority(_ priority: IssuePriority) -> [Issue] {
        issues.filter { $0.priority == priority && $0.status != .resolved }
    }
    
    // MARK: - Utility Methods
    
    func getCheckedInGuests() -> [Guest] {
        guests.filter { $0.checkOutTime == nil }
    }
    
    func getCheckedInVisitors() -> [Visitor] {
        visitors.filter { $0.checkOutTime == nil }
    }
    
    func getAllActiveCount() -> Int {
        getCheckedInGuests().count + getCheckedInVisitors().count
    }
    
    // MARK: - Debug Method
    func printStats() {
        print(String(repeating: "=", count: 50))
        print("GUEST MANAGER STATS (LOCAL STORAGE)")
        print(String(repeating: "=", count: 50))
        print("Total Staff (guests array): \(guests.count)")
        print("Total Visitors (visitors array): \(visitors.count)")
        print("Active Staff: \(getCheckedInGuests().count)")
        print("Active Visitors: \(getCheckedInVisitors().count)")
        print("Total Issues: \(issues.count)")
        print("Open Issues: \(getOpenIssues().count)")
        print(String(repeating: "=", count: 50))
    }
}
