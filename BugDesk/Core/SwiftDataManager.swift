import Foundation
import SwiftData

@MainActor
final class SwiftDataManager: ObservableObject {
    static let shared = SwiftDataManager()

    @Published private(set) var currentContainer: ModelContainer?
    private var currentUserEmail: String?

    private init() {}

    func setupContainer(for userEmail: String) {
        if currentUserEmail == userEmail, currentContainer != nil {
            print("✅ ModelContainer already set up for: \(userEmail)")
            return
        }

        currentUserEmail = userEmail

        do {
            let safeEmail = userEmail.replacingOccurrences(of: "@", with: "_at_")
                                      .replacingOccurrences(of: ".", with: "_")

            let fileName = "BugDesk_\(safeEmail).sqlite"

            let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let bugDeskURL = appSupportURL.appendingPathComponent("BugDesk", isDirectory: true)

            try? FileManager.default.createDirectory(at: bugDeskURL, withIntermediateDirectories: true)

            let databaseURL = bugDeskURL.appendingPathComponent(fileName)

            print("📂 Setting up database at: \(databaseURL.path)")

            let configuration = ModelConfiguration(
                url: databaseURL,
                allowsSave: true
            )

            currentContainer = try ModelContainer(
                for: Project.self, Version.self, StoredBugReport.self,
                configurations: configuration
            )

            print("✅ ModelContainer created for user: \(userEmail)")

        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    func clearContainer() {
        print("🗑️ Clearing current ModelContainer")
        currentContainer = nil
        currentUserEmail = nil
    }

    func deleteAllData(for userEmail: String) {
        let safeEmail = userEmail.replacingOccurrences(of: "@", with: "_at_")
                                  .replacingOccurrences(of: ".", with: "_")

        let fileName = "BugDesk_\(safeEmail).sqlite"

        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bugDeskURL = appSupportURL.appendingPathComponent("BugDesk", isDirectory: true)
        let databaseURL = bugDeskURL.appendingPathComponent(fileName)

        let filesToDelete = [
            databaseURL,
            databaseURL.appendingPathExtension("sqlite-shm"),
            databaseURL.appendingPathExtension("sqlite-wal")
        ]

        for fileURL in filesToDelete {
            try? FileManager.default.removeItem(at: fileURL)
            print("🗑️ Deleted: \(fileURL.lastPathComponent)")
        }
    }

    func listAllDatabases() -> [String] {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bugDeskURL = appSupportURL.appendingPathComponent("BugDesk", isDirectory: true)

        guard let files = try? FileManager.default.contentsOfDirectory(at: bugDeskURL, includingPropertiesForKeys: nil) else {
            return []
        }

        return files
            .filter { $0.pathExtension == "sqlite" }
            .map { $0.lastPathComponent }
    }
}
