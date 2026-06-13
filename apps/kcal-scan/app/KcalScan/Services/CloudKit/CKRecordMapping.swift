import Foundation
#if canImport(CloudKit)
import CloudKit

/// Mapping explicite Models ↔ CKRecord. `FoodItem` est embarqué (encodé JSON) dans `FoodEntry`
/// pour garder un schéma simple ; un type dédié reste possible si besoin de requêtes par aliment.

extension UserProfile {
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: CKRecordType.userProfile,
                              recordID: CKRecord.ID(recordName: id.uuidString))
        record["sex"] = sex.rawValue as CKRecordValue
        record["birthDate"] = birthDate as CKRecordValue
        record["heightCm"] = heightCm as CKRecordValue
        record["weightKg"] = weightKg as CKRecordValue
        record["activityLevel"] = activityLevel.rawValue as CKRecordValue
        record["objective"] = objective.rawValue as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue
        return record
    }

    init?(record: CKRecord) {
        guard let id = UUID(uuidString: record.recordID.recordName),
              let sexRaw = record["sex"] as? String, let sex = BiologicalSex(rawValue: sexRaw),
              let birthDate = record["birthDate"] as? Date,
              let heightCm = record["heightCm"] as? Double,
              let weightKg = record["weightKg"] as? Double,
              let activityRaw = record["activityLevel"] as? String, let activity = ActivityLevel(rawValue: activityRaw),
              let objectiveRaw = record["objective"] as? String, let objective = NutritionObjective(rawValue: objectiveRaw)
        else { return nil }
        self.init(id: id, sex: sex, birthDate: birthDate, heightCm: heightCm, weightKg: weightKg,
                  activityLevel: activity, objective: objective,
                  createdAt: (record["createdAt"] as? Date) ?? Date(),
                  updatedAt: (record["updatedAt"] as? Date) ?? Date())
    }
}

extension FoodEntry {
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: CKRecordType.foodEntry,
                              recordID: CKRecord.ID(recordName: id.uuidString))
        record["date"] = date as CKRecordValue
        record["mealType"] = mealType.rawValue as CKRecordValue
        record["portionGrams"] = portionGrams as CKRecordValue
        record["source"] = source.rawValue as CKRecordValue
        if let data = try? JSONEncoder().encode(foodItem) {
            record["foodItem"] = data as CKRecordValue
        }
        return record
    }

    init?(record: CKRecord) {
        guard let id = UUID(uuidString: record.recordID.recordName),
              let date = record["date"] as? Date,
              let mealRaw = record["mealType"] as? String, let meal = MealType(rawValue: mealRaw),
              let portion = record["portionGrams"] as? Double,
              let sourceRaw = record["source"] as? String, let source = FoodSource(rawValue: sourceRaw),
              let data = record["foodItem"] as? Data,
              let item = try? JSONDecoder().decode(FoodItem.self, from: data)
        else { return nil }
        self.init(id: id, date: date, mealType: meal, foodItem: item, portionGrams: portion, source: source)
    }
}
#endif
