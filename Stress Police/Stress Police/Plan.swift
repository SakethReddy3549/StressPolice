import SwiftUI

struct Plan: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var dueDate: Date
    var priority: String
}

