import Foundation

enum Day: String, CaseIterable, Identifiable {
    case Sun = "Sun"
    case Mon = "Mon"
    case Tue = "Tue"
    case Wed = "Wed"
    case Thu = "Thu"
    case Fri = "Fri"
    case Sat = "Sat"
    
    var id: String { self.rawValue }
    
    var weekdayNumber: Int {
        switch self {
        case .Sun: return 1
        case .Mon: return 2
        case .Tue: return 3
        case .Wed: return 4
        case .Thu: return 5
        case .Fri: return 6
        case .Sat: return 7
        }
    }
}
