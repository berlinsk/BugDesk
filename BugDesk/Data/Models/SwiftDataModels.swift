import Foundation
import SwiftData

@Model
final class Project {
    var id: UUID
    var name: String
    var projectDescription: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var versions: [Version]

    init(name: String, projectDescription: String = "") {
        self.id = UUID()
        self.name = name
        self.projectDescription = projectDescription
        self.createdAt = Date()
        self.versions = []
    }
}

@Model
final class Version {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var bugReports: [StoredBugReport]

    var project: Project?

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.bugReports = []
    }
}

@Model
final class StoredBugReport {
    var id: UUID
    var devices: [String]
    var screenModule: String
    var bugTypes: [String]
    var summary: String
    var reportDescription: String
    var criticality: String
    var createdAt: Date

    var appAttachmentsData: [AttachmentData]
    var designAttachmentsData: [AttachmentData]

    var version: Version?

    init(from report: BugReportEntity) {
        self.id = UUID()
        self.devices = Array(report.devices.map { $0.rawValue })
        self.screenModule = report.screenModule
        self.bugTypes = Array(report.bugTypes.map { $0.rawValue })
        self.summary = report.summary
        self.reportDescription = report.description
        self.criticality = report.criticality.rawValue
        self.createdAt = Date()

        self.appAttachmentsData = report.appAttachments.map { AttachmentData(from: $0) }
        self.designAttachmentsData = report.designAttachments.map { AttachmentData(from: $0) }
    }

    func toBugReportEntity() -> BugReportEntity {
        var report = BugReportEntity()
        report.devices = Set(devices.compactMap { Device(rawValue: $0) })
        report.screenModule = screenModule
        report.bugTypes = Set(bugTypes.compactMap { BugType(rawValue: $0) })
        report.summary = summary
        report.description = reportDescription
        report.criticality = Criticality(rawValue: criticality) ?? .medium

        report.appAttachments = appAttachmentsData.compactMap { $0.toAttachment() }
        report.designAttachments = designAttachmentsData.compactMap { $0.toAttachment() }

        return report
    }
}

struct AttachmentData: Codable {
    var filename: String
    var mimeType: String
    var fileData: Data

    init(from attachment: Attachment) {
        self.filename = attachment.filename
        self.mimeType = attachment.mimeType
        if let data = try? Data(contentsOf: attachment.url) {
            self.fileData = data
        } else {
            self.fileData = Data()
        }
    }

    func toAttachment() -> Attachment? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? fileData.write(to: tempURL)
        return Attachment(url: tempURL, filename: filename, mimeType: mimeType)
    }
}
