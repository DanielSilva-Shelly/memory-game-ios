import Foundation

enum Theme: String, CaseIterable, Identifiable, Codable {
    case animais
    case frutas

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .animais: return "Animais"
        case .frutas: return "Frutas"
        }
    }

    var itens: [String] {
        switch self {
        case .animais:
            return ["🐶","🐱","🐰","🦊","🐼","🐯","🦁","🐸","🐵","🐷","🐮","🐔"]
        case .frutas:
            return ["🍎","🍌","🍓","🍇","🍉","🍍","🍑","🍒","🥝","🍐","🍊","🥭"]
        }
    }
}

