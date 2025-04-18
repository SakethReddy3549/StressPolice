import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var deadline: Date
    var priority: Priority
    var workSchedule: [WorkBlock]?
    var groupMembers: [String]? // Optional list of group member names

    struct WorkBlock: Codable, Identifiable {
        var id: UUID = UUID()
        var startHour: Double
        var endHour: Double
        var from: Source
        var label: String?
        var isCompleted: Bool = false

        enum Source: String, Codable {
            case custom
            case ai
            case defaultPlan
        }
        
        init(startHour: Double, endHour: Double, from: Source, label: String? = nil, isCompleted: Bool = false) {
            self.id = UUID()
            self.startHour = startHour
            self.endHour = endHour
            self.from = from
            self.label = label
            self.isCompleted = isCompleted
        }
        
        // Add custom decoder
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()

                // 👇 This will decode Int OR Double as Double
                if let startInt = try? container.decode(Int.self, forKey: .startHour) {
                    startHour = Double(startInt)
                } else {
                    startHour = try container.decode(Double.self, forKey: .startHour)
                }

                if let endInt = try? container.decode(Int.self, forKey: .endHour) {
                    endHour = Double(endInt)
                } else {
                    endHour = try container.decode(Double.self, forKey: .endHour)
                }

                from = try container.decodeIfPresent(Source.self, forKey: .from) ?? .ai
                label = try container.decodeIfPresent(String.self, forKey: .label)
                isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
            }

            // Required for Codable when using custom decoder
            enum CodingKeys: String, CodingKey {
                case id, startHour, endHour, from, label, isCompleted
            }

        var startTime: Date {
            let hour = Int(startHour)
            let minute = Int((startHour - floor(startHour)) * 60)
            return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        }

        var duration: TimeInterval {
            (endHour - startHour) * 3600
        }
    }

    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    init(
        title: String,
        isCompleted: Bool = false,
        deadline: Date = Date().addingTimeInterval(3600),
        priority: Priority = .medium,
        workSchedule: [WorkBlock]? = nil,
        groupMembers: [String]? = nil
    ) {
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
