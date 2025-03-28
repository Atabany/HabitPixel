import Foundation

struct GridData: Equatable {
    let startDate: Date
    let numberOfWeeks: Int
    let completedDates: Set<Date>
    let dateRange: (first: Date?, last: Date)?
    
    static func == (lhs: GridData, rhs: GridData) -> Bool {
        lhs.startDate == rhs.startDate &&
        lhs.numberOfWeeks == rhs.numberOfWeeks &&
        lhs.completedDates == rhs.completedDates
    }
}
