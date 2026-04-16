import Foundation

struct MemoryCard: Identifiable, Equatable, Codable {
    let id: UUID
    let face: String
    var isFaceUp: Bool
    var isMatched: Bool

    init(id: UUID = UUID(), face: String, isFaceUp: Bool = false, isMatched: Bool = false) {
        self.id = id
        self.face = face
        self.isFaceUp = isFaceUp
        self.isMatched = isMatched
    }
}

