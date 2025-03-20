import SwiftUI

public struct Course: Identifiable {
    public let id = UUID()
    public let name: String
    public let code: String
    public let startTime: Date
    public let endTime: Date
    public let days: Set<WeekDay>
    public let colorName: String
    
    public init(name: String, code: String, startTime: Date, endTime: Date, days: Set<WeekDay>, colorName: String) {
        self.name = name
        self.code = code
        self.startTime = startTime
        self.endTime = endTime
        self.days = days
        self.colorName = colorName
    }
}

public enum WeekDay: String, CaseIterable, Identifiable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    public var id: Self { self }
    
    public var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tues"
        case .wednesday: return "Wed"
        case .thursday: return "Thur"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}

