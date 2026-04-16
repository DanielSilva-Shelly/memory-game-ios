import Foundation

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case facil
    case medio
    case dificil

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .facil: return "Fácil"
        case .medio: return "Médio"
        case .dificil: return "Difícil"
        }
    }

    var subtitulo: String {
        switch self {
        case .facil: return "Calmo e rápido para começar"
        case .medio: return "Mais pares, mais desafio"
        case .dificil: return "Muitos pares, máximo desafio"
        }
    }

    /// Total de cartas no tabuleiro (tem de ser par).
    var numeroDeCartas: Int {
        switch self {
        case .facil: return 10
        case .medio: return 16
        case .dificil: return 20
        }
    }

    /// Countdown por dificuldade (segundos).
    var tempoTotal: Int {
        switch self {
        case .facil: return 2 * 60
        case .medio: return 5 * 60
        case .dificil: return 10 * 60
        }
    }
}

