import Foundation

@MainActor
final class VersionDetailViewModel: ObservableObject {
    @Published var isGenerating = false
    @Published var spreadsheetURL: String?
    @Published var attachmentsFolderURL: String?
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var showSuccess = false

    init() {}

    func generateBatchReport(bugReports: [BugReportEntity], projectName: String, versionName: String, accessToken: String) async {
        guard !bugReports.isEmpty else {
            errorMessage = "No bug reports to generate"
            showError = true
            return
        }

        isGenerating = true
        defer { isGenerating = false }

        do {
            let useCase = DIContainer.shared.makeGenerateBatchReportUseCase(accessToken: accessToken)
            let result = try await useCase.execute(reports: bugReports, projectName: projectName, versionName: versionName, accessToken: accessToken)
            spreadsheetURL = result.sheetLink
            attachmentsFolderURL = result.attachmentsLink
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
