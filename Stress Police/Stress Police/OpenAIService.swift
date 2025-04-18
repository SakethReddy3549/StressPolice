import Foundation

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

class OpenAIService {
    private let backendURL = URL(string: "https://stresspolice-backend.onrender.com")! // backend URL

    func fetchSmartSchedule(
        tasks: [Task],
        workStart: Int,
        workEnd: Int,
        objective: String,
        completion: @escaping ([Task.WorkBlock]?) -> Void
    ) {
        let systemPrompt = """
        You are a smart scheduling assistant. Given a main objective, user work hours, and a task with a deadline,
        return a JSON array of labeled work blocks like:
        [
            {
                "startHour": 10.5,
                "endHour": 11.25,
                "label": "Research competitive apps"
            },
            {
                "startHour": 13,
                "endHour": 14,
                "label": "Work on UI improvements"
            }
        ]
        Use floating point hours (e.g. 10.5 = 10:30 AM).
        Each label should describe exactly what to work on in that time block.
        Never suggest blocks before the current time.
        Utilize available time efficiently and spread the blocks logically across the user’s working hours until the deadline.
        Short breaks are okay between long blocks.
        """

        let userPrompt = generatePrompt(from: tasks, workStart: workStart, workEnd: workEnd, objective: objective)

        let payload: [String: String] = [
            "systemPrompt": systemPrompt,
            "userPrompt": userPrompt
        ]

        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                print("Raw Response:")
                print(String(data: data, encoding: .utf8) ?? "Failed to decode string")
                if let jsonData = String(data: data, encoding: .utf8)?.data(using: .utf8) {
                    let blocks = try? JSONDecoder().decode([Task.WorkBlock].self, from: jsonData)
                    completion(blocks)
                } else {
                    print("Invalid response format")
                    completion(nil)
                }
            }
        }.resume()
    }

    private func generatePrompt(from tasks: [Task], workStart: Int, workEnd: Int, objective: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"

        let now = Date()
        let currentTime = formatter.string(from: now)

        let taskDescriptions = tasks.map { task in
            let deadline = formatter.string(from: task.deadline)
            return "- \(task.title) (Deadline: \(deadline))"
        }.joined(separator: "\n")

        return """
        The current time is: \(currentTime)
        The user’s work hours are from \(workStart):00 to \(workEnd):00 each day.
        The main objective is: "\(objective)"

        Here are the tasks:
        \(taskDescriptions)

        Generate a JSON array of focused, labeled work blocks to complete the task. Use float hour format (e.g. 13.25 = 1:15 PM).
        Blocks must not start in the past.
        Spread blocks logically across available time until the deadline.
        """
    }
}
