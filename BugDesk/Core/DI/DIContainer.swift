import Foundation
import SwiftData

final class DIContainer {
    static let shared = DIContainer()

    private init() {}

    func makeAuthRepository() -> AuthRepositoryProtocol {
        return AuthRepository()
    }

    func makeProjectRepository(modelContext: ModelContext) -> ProjectRepositoryProtocol {
        return ProjectRepository(modelContext: modelContext)
    }

    func makeBugReportRepository(accessToken: String) -> BugReportRepositoryProtocol {
        let driveService = GoogleDriveService(accessToken: accessToken)
        let sheetsService = GoogleSheetsService(accessToken: accessToken)
        return BugReportRepository(driveService: driveService, sheetsService: sheetsService)
    }

    func makeGenerateReportUseCase(accessToken: String) -> GenerateReportUseCaseProtocol {
        let repository = makeBugReportRepository(accessToken: accessToken)
        return GenerateReportUseCase(repository: repository)
    }

    func makeGenerateBatchReportUseCase(accessToken: String) -> GenerateBatchReportUseCaseProtocol {
        let repository = makeBugReportRepository(accessToken: accessToken)
        return GenerateBatchReportUseCase(repository: repository)
    }
}
