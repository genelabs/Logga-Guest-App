import Foundation

struct Guest: Identifiable, Codable {
    let id: UUID
    let fullName: String  // Changed from firstName and lastName
    var company: String
    var phoneNumber: String
    var checkInTime: Date
    var checkOutTime: Date?
    
    init(id: UUID = UUID(), fullName: String, company: String, phoneNumber: String, checkInTime: Date, checkOutTime: Date? = nil) {
        self.id = id
        self.fullName = fullName
        self.company = company
        self.phoneNumber = phoneNumber
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
    }
}

class GuestManager: ObservableObject {
    @Published var guests: [Guest] = []
    private let guestKey = "savedGuests"
    
    init() {
        loadGuests()
    }
    
    func addGuest(_ guest: Guest) {
        // Check if this guest already exists (based on fullName)
        if let index = guests.firstIndex(where: { $0.fullName == guest.fullName }) {
            var existingGuest = guests[index]
            existingGuest.checkInTime = guest.checkInTime
            existingGuest.checkOutTime = nil // Reset for new check-in
            existingGuest.company = guest.company // Update company if changed
            existingGuest.phoneNumber = guest.phoneNumber // Update phone if changed
            guests[index] = existingGuest
        } else {
            guests.append(guest)
        }
        saveToUserDefaults()
    }
    
    func checkOutGuest(id: UUID) {
        if let index = guests.firstIndex(where: { $0.id == id }) {
            var guest = guests[index]
            guest.checkOutTime = Date()
            guests[index] = guest
            saveToUserDefaults()
        }
    }
    
    func loadGuests() {
        if let data = UserDefaults.standard.data(forKey: guestKey),
           let decodedGuests = try? JSONDecoder().decode([Guest].self, from: data) {
            guests = decodedGuests
        }
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(guests) {
            UserDefaults.standard.set(encoded, forKey: guestKey)
        }
    }
    
    func checkInsToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return guests.filter { guest in
            calendar.isDate(guest.checkInTime, inSameDayAs: today)
        }.count
    }
    
    func checkOutsToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return guests.filter { guest in
            if let checkOutTime = guest.checkOutTime {
                return calendar.isDate(checkOutTime, inSameDayAs: today)
            }
            return false
        }.count
    }
}
