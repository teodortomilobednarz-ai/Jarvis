import Foundation
#if canImport(CloudKit)
import CloudKit
#endif

/// Types d'enregistrements CloudKit.
enum CKRecordType {
    static let userProfile = "UserProfile"
    static let foodItem = "FoodItem"
    static let foodEntry = "FoodEntry"
}

protocol CloudKitServiceProtocol {
    var isAvailable: Bool { get }
    func accountAvailable() async -> Bool

    func saveProfile(_ profile: UserProfile) async throws
    func fetchProfile() async throws -> UserProfile?

    func saveEntry(_ entry: FoodEntry) async throws
    func deleteEntry(id: UUID) async throws
    func fetchEntries(on day: Date) async throws -> [FoodEntry]
}

#if canImport(CloudKit)
final class CloudKitService: CloudKitServiceProtocol {
    private let container: CKContainer
    private var db: CKDatabase { container.privateCloudDatabase }

    // TODO: remplacer par l'identifiant réel du conteneur iCloud configuré dans Xcode.
    init(containerIdentifier: String? = nil) {
        self.container = containerIdentifier.map { CKContainer(identifier: $0) } ?? .default()
    }

    var isAvailable: Bool { true }

    func accountAvailable() async -> Bool {
        (try? await container.accountStatus()) == .available
    }

    // MARK: Profile

    func saveProfile(_ profile: UserProfile) async throws {
        let record = profile.toRecord()
        _ = try await db.save(record)
    }

    func fetchProfile() async throws -> UserProfile? {
        let query = CKQuery(recordType: CKRecordType.userProfile, predicate: NSPredicate(value: true))
        let result = try await db.records(matching: query, resultsLimit: 1)
        let record = result.matchResults.compactMap { try? $0.1.get() }.first
        return record.flatMap(UserProfile.init(record:))
    }

    // MARK: Entries

    func saveEntry(_ entry: FoodEntry) async throws {
        _ = try await db.save(entry.toRecord())
    }

    func deleteEntry(id: UUID) async throws {
        _ = try await db.deleteRecord(withID: CKRecord.ID(recordName: id.uuidString))
    }

    func fetchEntries(on day: Date) async throws -> [FoodEntry] {
        let start = Calendar.current.startOfDay(for: day)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        let query = CKQuery(recordType: CKRecordType.foodEntry, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let result = try await db.records(matching: query)
        return result.matchResults
            .compactMap { try? $0.1.get() }
            .compactMap(FoodEntry.init(record:))
    }
}
#else
/// Repli (plateforme sans CloudKit) — no-op.
final class CloudKitService: CloudKitServiceProtocol {
    var isAvailable: Bool { false }
    func accountAvailable() async -> Bool { false }
    func saveProfile(_ profile: UserProfile) async throws {}
    func fetchProfile() async throws -> UserProfile? { nil }
    func saveEntry(_ entry: FoodEntry) async throws {}
    func deleteEntry(id: UUID) async throws {}
    func fetchEntries(on day: Date) async throws -> [FoodEntry] { [] }
}
#endif
