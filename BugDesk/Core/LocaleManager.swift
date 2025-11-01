import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"
    case ukrainian = "uk"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .ukrainian: return "Українська"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .russian: return "🏳️‍🌈"
        case .ukrainian: return "🇺🇦"
        }
    }
}

final class LocaleManager: ObservableObject {
    static let shared = LocaleManager()

    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            Bundle.setLanguage(currentLanguage.rawValue)
        }
    }

    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .english
        Bundle.setLanguage(currentLanguage.rawValue)
    }

    func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

private var bundleKey: UInt8 = 0

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    var currentLanguagePath: String? {
        objc_getAssociatedObject(self, &bundleKey) as? String
    }
}

private class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = currentLanguagePath,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

import ObjectiveC
