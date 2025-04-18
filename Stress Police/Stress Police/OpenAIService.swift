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
    private var apiKey: String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let key = plist["OPENAI_API_KEY"] as? String else {
            return ""
        }
        return key
    }

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

        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userPrompt)
            ],
            temperature: 0.7
        )

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            print("Failed to encode request: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                print("No data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                print("Raw Response:")
                print(String(data: data, encoding: .utf8) ?? "Failed to decode string")
                let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let content = decoded.choices.first?.message.content,
                   let jsonData = content.data(using: .utf8) {
                    let blocks = try? JSONDecoder().decode([Task.WorkBlock].self, from: jsonData)
                    completion(blocks)
                } else {
                    print("No content or invalid JSON format")
                    completion(nil)
                }
            } catch {
                print("Decoding failed: \(error)")
                print(String(data: data, encoding: .utf8) ?? "")
                completion(nil)
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
