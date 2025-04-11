import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var deadline: Date
    var priority: Priority
    var workSchedule: [WorkBlock]?
    var groupMembers: [String]? // New: Optional list of group member names

    struct WorkBlock: Codable {
        var startTime: Date
        var duration: TimeInterval // In seconds
    }

    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    init(title: String, isCompleted: Bool = false, deadline: Date = Date().addingTimeInterval(3600), priority: Priority = .medium, workSchedule: [WorkBlock]? = nil, groupMembers: [String]? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.deadline = deadline
        self.priority = priority
        self.workSchedule = workSchedule
        self.groupMembers = groupMembers
    }

    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, deadline, priority, workSchedule, groupMembers
    }
}

