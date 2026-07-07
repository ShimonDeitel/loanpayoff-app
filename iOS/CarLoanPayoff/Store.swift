import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [LoanEntry] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier allows up to this many saved entries. Kept comfortably above
    /// the seed data count so a fresh install never trips the paywall.
    static let freeLimit = 6

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("loanpayoff_entries.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || entries.count < Store.freeLimit
    }

    func add(_ entry: LoanEntry) {
        guard canAddMore else { return }
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: LoanEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: LoanEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            entries = Self.seedData()
            save()
            return
        }
        if let decoded = try? JSONDecoder().decode([LoanEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Self.seedData()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static func seedData() -> [LoanEntry] {
        [
        LoanEntry(date: Date().addingTimeInterval(-259200), notes: "", balance: 100.0, payment: 100.0)
        ]
    }
}
