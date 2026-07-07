import Foundation

struct LoanEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var notes: String = ""
    var balance: Double
    var payment: Double
}
