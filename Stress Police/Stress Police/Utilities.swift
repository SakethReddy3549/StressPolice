import SwiftUI

// MARK: - Friendly Countdown Formatter

func timeLeftString(for deadline: Date) -> String {
    let timeInterval = deadline.timeIntervalSinceNow

    if timeInterval <= 0 {
        return "Time Up"
    }

    let minutes = Int(timeInterval / 60) % 60
    let hours = Int(timeInterval / 3600) % 24
    let days = Int(timeInterval / (3600 * 24))

    if days > 0 {
        return "Due in \(days)d \(hours)h"
    } else if hours > 0 {
        return "Due in \(hours)h \(minutes)m"
    } else {
        return "Due in \(minutes)m"
    }
}

// MARK: - Format Work Block Duration

func formatDuration(_ duration: TimeInterval) -> String {
    let totalMinutes = Int(round(duration / 60))
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}

// MARK: - AI-Smart Work Schedule Generator

func recommendWorkSchedule(forTaskTitle title: String, deadline: Date, priority: Task.Priority, workHours: (start: Int, end: Int) = (9, 19)) -> [Task.WorkBlock] {
    let calendar = Calendar.current
    var current = Date().addingTimeInterval(600) // 10 min prep time

    let timeUntilDeadline = deadline.timeIntervalSince(current)
    guard timeUntilDeadline > 0 else { return [] }

    let (blockCount, preferredWorkPerBlock): (Int, TimeInterval) = {
        switch priority {
        case .high: return (6, 45 * 60)
        case .medium: return (4, 40 * 60)
        case .low: return (3, 30 * 60)
        }
    }()

    var schedule: [Task.WorkBlock] = []
    var remainingBlocks = blockCount

    while remainingBlocks > 0 && current < deadline {
        guard let workDayStart = calendar.date(bySettingHour: workHours.start, minute: 0, second: 0, of: current),
              let workDayEnd = calendar.date(bySettingHour: workHours.end, minute: 0, second: 0, of: current) else {
            break
        }

        if current < workDayStart {
            current = workDayStart
        } else if current >= workDayEnd {
            current = calendar.date(byAdding: .day, value: 1, to: workDayStart)!
            continue
        }

        let maxPossibleBlock = min(preferredWorkPerBlock, deadline.timeIntervalSince(current), workDayEnd.timeIntervalSince(current))

        if maxPossibleBlock >= 10 * 60 { // minimum 10 minutes
            let startHour = Double(calendar.component(.hour, from: current)) +
                            Double(calendar.component(.minute, from: current)) / 60.0

            let endTime = current.addingTimeInterval(maxPossibleBlock)
            let endHour = Double(calendar.component(.hour, from: endTime)) +
                          Double(calendar.component(.minute, from: endTime)) / 60.0

            schedule.append(Task.WorkBlock(startHour: startHour, endHour: endHour, from: .defaultPlan, label: nil))
            current = endTime.addingTimeInterval(20 * 60) // 20-min break
            remainingBlocks -= 1
        } else {
            current = calendar.date(byAdding: .day, value: 1, to: workDayStart)!
        }
    }

    return schedule
}

