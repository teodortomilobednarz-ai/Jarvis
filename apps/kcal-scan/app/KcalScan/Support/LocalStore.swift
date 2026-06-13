import Foundation

/// Cache local JSON minimal pour le mode hors-ligne (lecture immédiate + file d'attente d'écriture).
final class LocalStore {
    private let directory: URL
    private let queue = DispatchQueue(label: "LocalStore", attributes: .concurrent)

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directory = base.appendingPathComponent("KcalScan", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        queue.sync {
            let url = directory.appendingPathComponent("\(key).json")
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
    }

    func save<T: Encodable>(_ value: T, key: String) {
        queue.async(flags: .barrier) {
            let url = self.directory.appendingPathComponent("\(key).json")
            if let data = try? JSONEncoder().encode(value) {
                try? data.write(to: url, options: .atomic)
            }
        }
    }

    func delete(key: String) {
        queue.async(flags: .barrier) {
            let url = self.directory.appendingPathComponent("\(key).json")
            try? FileManager.default.removeItem(at: url)
        }
    }
}
