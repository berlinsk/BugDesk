import Foundation

protocol GenerateReportUseCaseProtocol {
    func execute(report: BugReportEntity, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String)
}

final class GenerateReportUseCase: GenerateReportUseCaseProtocol {
    private let repository: BugReportRepositoryProtocol

    init(repository: BugReportRepositoryProtocol) {
        self.repository = repository
    }

    func execute(report: BugReportEntity, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String) {
        guard !report.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.validation("Summary is required")
        }
        guard !report.bugTypes.isEmpty else {
            throw DomainError.validation("Bug type is required")
        }

        return try await repository.generateReport(report: report, accessToken: accessToken)
    }
}
