import Foundation

final class BugReportRepository: BugReportRepositoryProtocol {
    private let driveService: GoogleDriveService
    private let sheetsService: GoogleSheetsService

    init(driveService: GoogleDriveService, sheetsService: GoogleSheetsService) {
        self.driveService = driveService
        self.sheetsService = sheetsService
    }

    func generateReport(report: BugReportEntity, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String) {
        let root = try await driveService.createFolder(name: "Bug Report \(timestampString())", parentId: nil)
        try await driveService.setAnyoneEditor(fileId: root.id)

        let attachmentsFolder = try await driveService.createFolder(name: "Attachments", parentId: root.id)
        try await driveService.setAnyoneEditor(fileId: attachmentsFolder.id)

        let appLinks = try await uploadCategory(report.appAttachments, label: "App Attachments", parentId: attachmentsFolder.id)
        let designLinks = try await uploadCategory(report.designAttachments, label: "Design Attachments", parentId: attachmentsFolder.id)

        let sheet = try await driveService.createSpreadsheetInFolder(title: "Bug Desk Report", parentId: root.id)
        let sheetId = try await sheetsService.fetchFirstSheetId(spreadsheetId: sheet.id)

        let header = [
            "№",
            "Device",
            "Screen/Module",
            "Bug Type",
            "Summary",
            "Description",
            "App Attachments",
            "Design Attachments",
            "Criticality",
            "Partner Comment",
            "Mediator Comment"
        ]

        let devicesStr = report.devices.isEmpty ? "all" : report.devices.joinedRaw
        let bugTypesStr = report.bugTypes.joinedRaw

        let row = [
            "=ROW()-1",
            devicesStr,
            report.screenModule,
            bugTypesStr,
            report.summary,
            report.description,
            appLinks,
            designLinks,
            report.criticality.rawValue,
            "",
            ""
        ]

        try await sheetsService.writeHeaderAndRow(spreadsheetId: sheet.id, header: header, row: row)

        let allDeviceOptions = Device.allCases.map { $0.rawValue }
        let allBugTypeOptions = BugType.allCases.map { $0.rawValue }
        let allCriticalityOptions = Criticality.allCases.map { $0.rawValue }

        try await sheetsService.setDropdowns(
            spreadsheetId: sheet.id,
            sheetId: sheetId,
            deviceOptions: allDeviceOptions,
            bugTypeOptions: allBugTypeOptions,
            screenModuleOptions: report.screenModule.isEmpty ? [""] : [report.screenModule],
            criticalityOptions: allCriticalityOptions
        )

        try await sheetsService.formatTable(
            spreadsheetId: sheet.id,
            sheetId: sheetId,
            rowCount: 100,
            columnCount: header.count
        )

        try await driveService.setAnyoneEditor(fileId: sheet.id)

        guard let sheetLink = sheet.webViewLink,
              let attachmentsLink = attachmentsFolder.webViewLink else {
            throw DomainError.network("Missing webViewLink")
        }

        return (sheetLink, attachmentsLink)
    }

    func generateBatchReport(reports: [BugReportEntity], projectName: String, versionName: String, accessToken: String) async throws -> (sheetLink: String, attachmentsLink: String) {
        let folderName = "\(projectName) - \(versionName) - Bug Report \(timestampString())"
        let root = try await driveService.createFolder(name: folderName, parentId: nil)
        try await driveService.setAnyoneEditor(fileId: root.id)

        let attachmentsFolder = try await driveService.createFolder(name: "Attachments", parentId: root.id)
        try await driveService.setAnyoneEditor(fileId: attachmentsFolder.id)

        let sheet = try await driveService.createSpreadsheetInFolder(title: "\(projectName) - \(versionName)", parentId: root.id)
        let sheetId = try await sheetsService.fetchFirstSheetId(spreadsheetId: sheet.id)

        let header = [
            "№",
            "Device",
            "Screen/Module",
            "Bug Type",
            "Summary",
            "Description",
            "App Attachments",
            "Design Attachments",
            "Criticality",
            "Partner Comment",
            "Mediator Comment"
        ]

        var allRows: [[String]] = [header]

        for (index, bugReport) in reports.enumerated() {
            let bugFolder = try await driveService.createFolder(name: "Bug \(index + 1)", parentId: attachmentsFolder.id)

            let appLinks = try await uploadCategory(bugReport.appAttachments, label: "App Attachments", parentId: bugFolder.id)
            let designLinks = try await uploadCategory(bugReport.designAttachments, label: "Design Attachments", parentId: bugFolder.id)

            let devicesStr = bugReport.devices.isEmpty ? "all" : bugReport.devices.joinedRaw
            let bugTypesStr = bugReport.bugTypes.joinedRaw

            let row = [
                "\(index + 1)",
                devicesStr,
                bugReport.screenModule,
                bugTypesStr,
                bugReport.summary,
                bugReport.description,
                appLinks,
                designLinks,
                bugReport.criticality.rawValue,
                "",
                ""
            ]

            allRows.append(row)
        }

        try await sheetsService.batchUpdate(spreadsheetId: sheet.id, rows: allRows)

        let allScreenModules = Array(Set(reports.map { $0.screenModule }.filter { !$0.isEmpty }))
        let allDeviceOptions = Device.allCases.map { $0.rawValue }
        let allBugTypeOptions = BugType.allCases.map { $0.rawValue }
        let allCriticalityOptions = Criticality.allCases.map { $0.rawValue }

        try await sheetsService.setDropdowns(
            spreadsheetId: sheet.id,
            sheetId: sheetId,
            deviceOptions: allDeviceOptions,
            bugTypeOptions: allBugTypeOptions,
            screenModuleOptions: allScreenModules.isEmpty ? [""] : allScreenModules,
            criticalityOptions: allCriticalityOptions
        )

        try await sheetsService.formatTable(
            spreadsheetId: sheet.id,
            sheetId: sheetId,
            rowCount: allRows.count + 100,
            columnCount: header.count
        )

        try await driveService.setAnyoneEditor(fileId: sheet.id)

        guard let sheetLink = sheet.webViewLink,
              let attachmentsLink = attachmentsFolder.webViewLink else {
            throw DomainError.network("Missing webViewLink")
        }

        return (sheetLink, attachmentsLink)
    }

    private func uploadCategory(_ list: [Attachment], label: String, parentId: String) async throws -> String {
        guard !list.isEmpty else { return "" }

        if list.count == 1, let item = list.first {
            let file = try await driveService.uploadFileMultipart(parentId: parentId, fileURL: item.url, filename: item.filename, mimeType: item.mimeType)
            return file.webViewLink ?? ""
        } else {
            let sub = try await driveService.createFolder(name: label, parentId: parentId)
            for att in list {
                _ = try await driveService.uploadFileMultipart(parentId: sub.id, fileURL: att.url, filename: att.filename, mimeType: att.mimeType)
            }
            return sub.webViewLink ?? ""
        }
    }

    private func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
