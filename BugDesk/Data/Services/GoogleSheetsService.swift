import Foundation

final class GoogleSheetsService {
    private let accessToken: String
    init(accessToken: String) { self.accessToken = accessToken }

    private func req(_ url: URL, method: String = "GET", json: [String: Any]? = nil) throws -> URLRequest {
        var r = URLRequest(url: url)
        r.httpMethod = method
        r.addValue("application/json", forHTTPHeaderField: "Content-Type")
        r.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        if let json {
            r.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        }
        return r
    }

    private func run(_ req: URLRequest) async throws -> Data {
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let text = String(data: data, encoding: .utf8) ?? "no body"
            throw DomainError.network("Sheets error (\((resp as? HTTPURLResponse)?.statusCode ?? -1)): \(text)")
        }
        return data
    }

    func fetchFirstSheetId(spreadsheetId: String) async throws -> Int {
        let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)?fields=sheets.properties")!
        let data = try await run(try req(url))
        struct Resp: Decodable {
            struct Sheet: Decodable {
                struct P: Decodable {
                    let sheetId: Int
                }
                let properties: P
            }
            let sheets: [Sheet]
        }

        let resp = try JSONDecoder().decode(Resp.self, from: data)
        guard let id = resp.sheets.first?.properties.sheetId else { throw DomainError.network("No sheetId") }
        return id
    }

    func writeHeaderAndRow(spreadsheetId: String,
                           header: [String],
                           row: [String]) async throws {
        var url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/A1:K1?valueInputOption=USER_ENTERED")!
        let r1 = try req(url, method: "PUT", json: ["values": [header]])
        _ = try await run(r1)

        url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/A2:K2?valueInputOption=USER_ENTERED")!
        let r2 = try req(url, method: "PUT", json: ["values": [row]])
        _ = try await run(r2)
    }

    func batchUpdate(spreadsheetId: String, rows: [[String]]) async throws {
        let endColumn = rows.first?.count ?? 0
        let endColumnLetter = columnLetter(for: endColumn - 1)
        let endRow = rows.count
        let range = "A1:\(endColumnLetter)\(endRow)"

        let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(range)?valueInputOption=USER_ENTERED")!
        let body: [String: Any] = ["values": rows]
        let r = try req(url, method: "PUT", json: body)
        _ = try await run(r)
    }

    private func columnLetter(for index: Int) -> String {
        var column = index
        var letter = ""
        while column >= 0 {
            letter = String(UnicodeScalar(65 + (column % 26))!) + letter
            column = (column / 26) - 1
            if column < 0 { break }
        }
        return letter
    }

    func setDropdowns(spreadsheetId: String,
                      sheetId: Int,
                      deviceOptions: [String],
                      bugTypeOptions: [String],
                      screenModuleOptions: [String],
                      criticalityOptions: [String]) async throws {

        let makeRule: ([String], Bool) -> [String: Any] = { values, strict in
            [ "condition": [
                "type": "ONE_OF_LIST",
                "values": values.map { ["userEnteredValue": $0] }
              ],
              "showCustomUi": true,
              "strict": strict
            ]
        }

        let requests: [[String: Any]] = [
            [
              "setDataValidation": [
                "range": [
                    "sheetId": sheetId,
                    "startRowIndex": 1, "endRowIndex": 1000,
                    "startColumnIndex": 8, "endColumnIndex": 9
                ],
                "rule": makeRule(criticalityOptions, true)
              ]
            ]
        ]

        let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId):batchUpdate")!
        let body: [String: Any] = ["requests": requests]
        let req = try self.req(url, method: "POST", json: body)
        _ = try await run(req)
    }

    func formatTable(spreadsheetId: String,
                     sheetId: Int,
                     rowCount: Int,
                     columnCount: Int) async throws {

        var requests: [[String: Any]] = []

        requests.append([
            "repeatCell": [
                "range": [
                    "sheetId": sheetId,
                    "startRowIndex": 0,
                    "endRowIndex": rowCount,
                    "startColumnIndex": 0,
                    "endColumnIndex": columnCount
                ],
                "cell": [
                    "userEnteredFormat": [
                        "wrapStrategy": "WRAP"
                    ]
                ],
                "fields": "userEnteredFormat.wrapStrategy"
            ]
        ])

        requests.append([
            "repeatCell": [
                "range": [
                    "sheetId": sheetId,
                    "startRowIndex": 0,
                    "endRowIndex": 1,
                    "startColumnIndex": 0,
                    "endColumnIndex": columnCount
                ],
                "cell": [
                    "userEnteredFormat": [
                        "backgroundColor": [
                            "red": 0.26,
                            "green": 0.52,
                            "blue": 0.96,
                            "alpha": 1.0
                        ],
                        "textFormat": [
                            "foregroundColor": [
                                "red": 1.0,
                                "green": 1.0,
                                "blue": 1.0,
                                "alpha": 1.0
                            ],
                            "fontSize": 11,
                            "bold": true
                        ],
                        "horizontalAlignment": "CENTER",
                        "verticalAlignment": "MIDDLE"
                    ]
                ],
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment,verticalAlignment)"
            ]
        ])

        let cellBorder: [String: Any] = [
            "style": "SOLID",
            "width": 1,
            "color": [
                "red": 0.0,
                "green": 0.0,
                "blue": 0.0,
                "alpha": 1.0
            ]
        ]

        requests.append([
            "updateBorders": [
                "range": [
                    "sheetId": sheetId,
                    "startRowIndex": 0,
                    "endRowIndex": rowCount,
                    "startColumnIndex": 0,
                    "endColumnIndex": columnCount
                ],
                "top": cellBorder,
                "bottom": cellBorder,
                "left": cellBorder,
                "right": cellBorder,
                "innerHorizontal": cellBorder,
                "innerVertical": cellBorder
            ]
        ])

        let deviceColors: [(String, [String: Double])] = [
            ("iPhone 11", ["red": 1.0, "green": 0.8, "blue": 0.8, "alpha": 0.3]),
            ("iPhone 12 Pro Max", ["red": 1.0, "green": 0.9, "blue": 0.7, "alpha": 0.3]),
            ("iPhone 13 Pro", ["red": 0.9, "green": 0.8, "blue": 1.0, "alpha": 0.3]),
            ("iPhone SE 3", ["red": 0.8, "green": 1.0, "blue": 0.9, "alpha": 0.3])
        ]

        for (device, color) in deviceColors {
            requests.append([
                "addConditionalFormatRule": [
                    "rule": [
                        "ranges": [[
                            "sheetId": sheetId,
                            "startRowIndex": 1,
                            "endRowIndex": rowCount,
                            "startColumnIndex": 1,
                            "endColumnIndex": 2
                        ]],
                        "booleanRule": [
                            "condition": [
                                "type": "TEXT_CONTAINS",
                                "values": [["userEnteredValue": device]]
                            ],
                            "format": [
                                "backgroundColor": color
                            ]
                        ]
                    ],
                    "index": 0
                ]
            ])
        }

        let bugTypeColors: [(String, [String: Double])] = [
            ("UI", ["red": 1.0, "green": 0.6, "blue": 0.6, "alpha": 0.3]),
            ("UX", ["red": 1.0, "green": 0.8, "blue": 0.6, "alpha": 0.3]),
            ("Performance", ["red": 0.6, "green": 0.8, "blue": 1.0, "alpha": 0.3]),
            ("Compatibility", ["red": 0.9, "green": 0.7, "blue": 1.0, "alpha": 0.3]),
            ("Spec", ["red": 0.8, "green": 1.0, "blue": 0.6, "alpha": 0.3]),
            ("Network", ["red": 1.0, "green": 0.6, "blue": 1.0, "alpha": 0.3])
        ]

        for (bugType, color) in bugTypeColors {
            requests.append([
                "addConditionalFormatRule": [
                    "rule": [
                        "ranges": [[
                            "sheetId": sheetId,
                            "startRowIndex": 1,
                            "endRowIndex": rowCount,
                            "startColumnIndex": 3,
                            "endColumnIndex": 4
                        ]],
                        "booleanRule": [
                            "condition": [
                                "type": "TEXT_CONTAINS",
                                "values": [["userEnteredValue": bugType]]
                            ],
                            "format": [
                                "backgroundColor": color
                            ]
                        ]
                    ],
                    "index": 0
                ]
            ])
        }

        let criticalityColors: [(String, [String: Double])] = [
            ("highest", ["red": 0.9, "green": 0.2, "blue": 0.2, "alpha": 0.5]),
            ("high", ["red": 1.0, "green": 0.6, "blue": 0.2, "alpha": 0.4]),
            ("medium", ["red": 1.0, "green": 1.0, "blue": 0.4, "alpha": 0.4]),
            ("low", ["red": 0.6, "green": 0.8, "blue": 1.0, "alpha": 0.3]),
            ("lowest", ["red": 0.6, "green": 1.0, "blue": 0.6, "alpha": 0.3])
        ]

        for (criticality, color) in criticalityColors {
            requests.append([
                "addConditionalFormatRule": [
                    "rule": [
                        "ranges": [[
                            "sheetId": sheetId,
                            "startRowIndex": 1,
                            "endRowIndex": rowCount,
                            "startColumnIndex": 8,
                            "endColumnIndex": 9
                        ]],
                        "booleanRule": [
                            "condition": [
                                "type": "TEXT_CONTAINS",
                                "values": [["userEnteredValue": criticality]]
                            ],
                            "format": [
                                "backgroundColor": color
                            ]
                        ]
                    ],
                    "index": 0
                ]
            ])
        }

        requests.append([
            "autoResizeDimensions": [
                "dimensions": [
                    "sheetId": sheetId,
                    "dimension": "COLUMNS",
                    "startIndex": 0,
                    "endIndex": columnCount
                ]
            ]
        ])

        let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId):batchUpdate")!
        let body: [String: Any] = ["requests": requests]
        let req = try self.req(url, method: "POST", json: body)
        _ = try await run(req)
    }
}
