import Foundation

protocol GenerateBatchReportUseCaseProtocol {
    func execute(reports: [BugReportEntity], projectName: String, versionName: String, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String)
}

final class GenerateBatchReportUseCase: GenerateBatchReportUseCaseProtocol {
    private let repository: BugReportRepositoryProtocol

    init(repository: BugReportRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reports: [BugReportEntity], projectName: String, versionName: String, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String) {
        guard !reports.isEmpty else {
            throw DomainError.validation("No reports to generate")
        }

        return try await repository.generateBatchReport(reports: reports, projectName: projectName, versionName: versionName, accessToken: accessToken)
    }
}
