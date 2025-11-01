import Foundation

@MainActor
final class BugReportViewModel: ObservableObject {
    @Published var report = BugReportEntity()
    @Published var isGenerating = false
    @Published var resultSheetLink: String?
    @Published var resultAttachmentsFolderLink: String?
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var showSuccess = false
    @Published var spreadsheetURL: String?
    @Published var attachmentsFolderURL: String?

    init() {}

    var isValid: Bool {
        !report.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !report.bugTypes.isEmpty
    }

    func generate(accessToken: String) async {
        guard isValid else {
            errorMessage = "Обязательные поля: Тип бага, Резюме."
            return
        }
        isGenerating = true
        defer { isGenerating = false }

        do {
            let useCase = DIContainer.shared.makeGenerateReportUseCase(accessToken: accessToken)
            let result = try await useCase.execute(report: report, accessToken: accessToken)
            resultSheetLink = result.sheetLink
            resultAttachmentsFolderLink = result.attachmentsLink
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func generateBatchReport(bugReports: [BugReportEntity], projectName: String, versionName: String, accessToken: String) async {
        guard !bugReports.isEmpty else {
            errorMessage = "No bug reports to generate"
            showError = true
            return
        }

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
