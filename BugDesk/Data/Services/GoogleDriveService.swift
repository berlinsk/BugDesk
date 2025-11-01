import Foundation

struct DriveItem {
    let id: String
    let webViewLink: String?
}

final class GoogleDriveService {
    private let accessToken: String
    init(accessToken: String) { self.accessToken = accessToken }

    private func makeRequest(url: URL, method: String = "GET", jsonBody: [String: Any]? = nil, contentType: String = "application/json") throws -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.addValue(contentType, forHTTPHeaderField: "Content-Type")
        if let jsonBody = jsonBody {
            req.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        }
        return req
    }

    private func runJSON<T: Decodable>(_ req: URLRequest, as: T.Type) async throws -> T {
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let text = String(data: data, encoding: .utf8) ?? "no body"
            throw DomainError.network("Drive error (\((resp as? HTTPURLResponse)?.statusCode ?? -1)): \(text)")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func createFolder(name: String, parentId: String?) async throws -> DriveItem {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files?fields=id,webViewLink")!
        var body: [String: Any] = [
            "name": name,
            "mimeType": "application/vnd.google-apps.folder"
        ]
        if let parentId { body["parents"] = [parentId] }

        let req = try makeRequest(url: url, method: "POST", jsonBody: body)
        struct R: Decodable { let id: String; let webViewLink: String? }
        let r: R = try await runJSON(req, as: R.self)
        return DriveItem(id: r.id, webViewLink: r.webViewLink)
    }

    func setAnyoneEditor(fileId: String) async throws {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files/\(fileId)/permissions?sendNotificationEmail=false")!
        let body: [String: Any] = [
            "type": "anyone",
            "role": "writer"
        ]
        let req = try makeRequest(url: url, method: "POST", jsonBody: body)
        _ = try await URLSession.shared.data(for: req)
    }

    func uploadFileMultipart(parentId: String, fileURL: URL, filename: String, mimeType: String) async throws -> DriveItem {
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id,webViewLink")!
        var req = try makeRequest(url: url, method: "POST", contentType: "multipart/related; boundary=\(boundary)")

        var meta: [String: Any] = [
            "name": filename,
            "mimeType": mimeType,
            "parents": [parentId]
        ]
        let metaData = try JSONSerialization.data(withJSONObject: meta, options: [])

        let fileData = try Data(contentsOf: fileURL, options: .mappedIfSafe)

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: .utf8)!)
        body.append(metaData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        req.httpBody = body

        struct R: Decodable { let id: String; let webViewLink: String? }
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let text = String(data: data, encoding: .utf8) ?? "no body"
            throw DomainError.network("Upload error: \(text)")
        }
        let r = try JSONDecoder().decode(R.self, from: data)
        return DriveItem(id: r.id, webViewLink: r.webViewLink)
    }

    func createSpreadsheetInFolder(title: String, parentId: String) async throws -> DriveItem {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files?fields=id,webViewLink")!
        let body: [String: Any] = [
            "name": title,
            "mimeType": "application/vnd.google-apps.spreadsheet",
            "parents": [parentId]
        ]
        let req = try makeRequest(url: url, method: "POST", jsonBody: body)
        struct R: Decodable { let id: String; let webViewLink: String? }
        let r: R = try await runJSON(req, as: R.self)
        return DriveItem(id: r.id, webViewLink: r.webViewLink)
    }
}
