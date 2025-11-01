import Foundation

struct ProjectEntity: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var createdAt: Date
    var versions: [VersionEntity]
}

struct VersionEntity: Identifiable {
    let id: UUID
    var name: String
    var createdAt: Date
    var bugReports: [BugReportEntity]
}
