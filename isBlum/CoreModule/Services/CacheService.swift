import Foundation

enum CacheService {

    private static var directory: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("isBlumCache", isDirectory: true)
    }

    private static var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }

    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    // MARK: - Save

    static func save<T: Encodable>(_ value: T, key: String) {
        do {
            try FileManager.default.createDirectory(
                at: directory, withIntermediateDirectories: true
            )
            let data = try encoder.encode(value)
            try data.write(to: fileURL(key))
        } catch {
            print("CacheService save error (\(key)):", error)
        }
    }

    // MARK: - Load

    static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = try? Data(contentsOf: fileURL(key)) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    // MARK: - Clear

    static func clear(key: String) {
        try? FileManager.default.removeItem(at: fileURL(key))
    }

    static func clearAll() {
        try? FileManager.default.removeItem(at: directory)
    }

    // MARK: - Private

    private static func fileURL(_ key: String) -> URL {
        directory.appendingPathComponent("\(key).json")
    }
}
