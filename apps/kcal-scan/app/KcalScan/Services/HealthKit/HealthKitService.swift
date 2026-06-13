import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

/// Données santé pertinentes lues depuis HealthKit (lecture seule en v1).
struct HealthSnapshot {
    var steps: Int
    var activeEnergyKcal: Double
    var bodyMassKg: Double?
    var heightCm: Double?
    var sex: BiologicalSex?
    var birthDate: Date?

    static let empty = HealthSnapshot(steps: 0, activeEnergyKcal: 0,
                                      bodyMassKg: nil, heightCm: nil, sex: nil, birthDate: nil)
}

protocol HealthKitServiceProtocol {
    var isAvailable: Bool { get }
    func requestAuthorization() async throws
    func todaySteps() async throws -> Int
    func todayActiveEnergy() async throws -> Double
    func latestBodyMassKg() async throws -> Double?
    func latestHeightCm() async throws -> Double?
    func biologicalSex() -> BiologicalSex?
    func birthDate() -> Date?
    func snapshot() async -> HealthSnapshot
}

#if canImport(HealthKit)
final class HealthKitService: HealthKitServiceProtocol {
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []
        if let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) { types.insert(steps) }
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) { types.insert(energy) }
        if let mass = HKQuantityType.quantityType(forIdentifier: .bodyMass) { types.insert(mass) }
        if let height = HKQuantityType.quantityType(forIdentifier: .height) { types.insert(height) }
        types.insert(HKObjectType.characteristicType(forIdentifier: .biologicalSex)!)
        types.insert(HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!)
        return types
    }

    func requestAuthorization() async throws {
        guard isAvailable else { return }
        try await store.requestAuthorization(toShare: [], read: readTypes)
    }

    func todaySteps() async throws -> Int {
        let sum = try await sumToday(.stepCount, unit: .count())
        return Int(sum)
    }

    func todayActiveEnergy() async throws -> Double {
        try await sumToday(.activeEnergyBurned, unit: .kilocalorie())
    }

    func latestBodyMassKg() async throws -> Double? {
        try await latest(.bodyMass, unit: .gramUnit(with: .kilo))
    }

    func latestHeightCm() async throws -> Double? {
        if let m = try await latest(.height, unit: .meter()) { return m * 100 }
        return nil
    }

    func biologicalSex() -> BiologicalSex? {
        guard let value = try? store.biologicalSex().biologicalSex else { return nil }
        switch value {
        case .male:   return .male
        case .female: return .female
        case .other:  return .other
        default:      return nil
        }
    }

    func birthDate() -> Date? {
        guard let components = try? store.dateOfBirthComponents() else { return nil }
        return Calendar.current.date(from: components)
    }

    func snapshot() async -> HealthSnapshot {
        let steps = (try? await todaySteps()) ?? 0
        let energy = (try? await todayActiveEnergy()) ?? 0
        let mass = (try? await latestBodyMassKg()) ?? nil
        let height = (try? await latestHeightCm()) ?? nil
        return HealthSnapshot(
            steps: steps,
            activeEnergyKcal: energy,
            bodyMassKg: mass,
            heightCm: height,
            sex: biologicalSex(),
            birthDate: birthDate()
        )
    }

    // MARK: - Helpers

    private func sumToday(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return 0 }
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, stats, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            store.execute(query)
        }
    }

    private func latest(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error { continuation.resume(throwing: error); return }
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
#else
/// Repli (simulateur/plateforme sans HealthKit).
final class HealthKitService: HealthKitServiceProtocol {
    var isAvailable: Bool { false }
    func requestAuthorization() async throws {}
    func todaySteps() async throws -> Int { 0 }
    func todayActiveEnergy() async throws -> Double { 0 }
    func latestBodyMassKg() async throws -> Double? { nil }
    func latestHeightCm() async throws -> Double? { nil }
    func biologicalSex() -> BiologicalSex? { nil }
    func birthDate() -> Date? { nil }
    func snapshot() async -> HealthSnapshot { .empty }
}
#endif
