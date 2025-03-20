import SwiftUI
import Foundation

struct Assignment: Identifiable {
    let id: UUID
    let name: String
    let details: String
    let deadline: Date
    let courseId: UUID
    var isCompleted: Bool
    
    init(name: String, details: String, deadline: Date, courseId: UUID) {
        self.id = UUID()
        self.name = name
        self.details = details
        self.deadline = deadline
        self.courseId = courseId
        self.isCompleted = false
    }
}

