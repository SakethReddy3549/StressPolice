import SwiftUI

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let message: String

    init(name: String, message: String) {
        self.id = UUID()
        self.name = name
        self.message = message
    }
    enum CodingKeys: String, CodingKey {
        case id, name, message
    }
}
