import Foundation

enum Device: String, CaseIterable, Identifiable {
    case iphone11 = "iPhone 11"
    case iphone12ProMax = "iPhone 12 Pro Max"
    case iphone13Pro = "iPhone 13 Pro"
    case se3 = "iPhone SE 3"
    var id: String { rawValue }
}

enum BugType: String, CaseIterable, Identifiable {
    case ui = "UI"
    case ux = "UX"
    case performance = "Performance"
    case compatibility = "Compatibility"
    case spec = "Spec"
    case network = "Network"
    var id: String { rawValue }
}

enum Criticality: String, CaseIterable, Identifiable {
    case highest, high, medium, low, lowest
    var id: String { rawValue }
}

struct Attachment: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let filename: String
    let mimeType: String
}

struct BugReportEntity {
    var devices: Set<Device> = []
    var screenModule: String = ""
    var bugTypes: Set<BugType> = []
    var summary: String = ""
    var description: String = ""
    var appAttachments: [Attachment] = []
    var designAttachments: [Attachment] = []
    var criticality: Criticality = .medium
    var partnerComment: String = ""
    var mediatorComment: String = ""
}

enum DomainError: LocalizedError {
    case notSignedIn
    case validation(String)
    case network(String)
    case auth(String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "Google не авторизован."
        case .validation(let s): return s
        case .network(let s): return s
        case .auth(let s): return s
        }
    }
}

struct AuthResult {
    let accessToken: String
    let userEmail: String
}
