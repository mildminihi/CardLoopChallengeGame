import Foundation
import SwiftUI

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    @Published var currentLanguage: String = "en"
    
    static let shared = LanguageManager()
    
    private init() {
        // Get current language from UserDefaults or system
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            currentLanguage = savedLanguage
        } else {
            // Default to system language if available, otherwise English
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = ["en", "th"].contains(systemLanguage) ? systemLanguage : "en"
        }
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "AppLanguage")
        UserDefaults.standard.synchronize()
        
        // Force refresh by posting notification
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    var availableLanguages: [(code: String, name: String, flag: String)] {
        return [
            ("en", "English", "🇺🇸"),
            ("th", "ไทย", "🇹🇭")
        ]
    }
}

extension String {
    var localized: String {
        let language = LanguageManager.shared.currentLanguage
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let language = LanguageManager.shared.currentLanguage
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
        }
        return String(format: NSLocalizedString(self, bundle: bundle, comment: ""), arguments: arguments)
    }
}
