import Foundation

struct DailySteps: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
    
    init(date: Date, steps: Int) {
        self.date = date
        self.steps = steps
    }
    
    // Helper para obtener la fecha como string
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Helper para obtener el día de la semana
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let languageCode = UserDefaults.standard.string(forKey: LanguageManager.storageKey) ?? AppLanguage.english.rawValue
        formatter.locale = Locale(identifier: languageCode == AppLanguage.spanish.rawValue ? "es_ES" : "en_US")
        return formatter.string(from: date)
    }
    
    // Helper para verificar si es hoy
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    // Helper para verificar si es ayer
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
} 
