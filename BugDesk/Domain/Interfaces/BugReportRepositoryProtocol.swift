import Foundation

protocol BugReportRepositoryProtocol {
    func generateReport(report: BugReportEntity, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String)
    func generateBatchReport(reports: [BugReportEntity], projectName: String, versionName: String, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String)
}
