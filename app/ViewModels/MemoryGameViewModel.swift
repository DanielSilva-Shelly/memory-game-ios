import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AudioToolbox)
import AudioToolbox
internal import Combine
#endif

@MainActor
final class MemoryGameViewModel: ObservableObject {
    enum Phase: Equatable {
        case playing
        case victory
        case timeUp
    }

    @Published private(set) var cards: [MemoryCard] = []
    @Published private(set) var moves: Int = 0
    @Published private(set) var matchedPairs: Int = 0
    @Published private(set) var phase: Phase = .playing

    @Published private(set) var timeRemaining: Int = 0
    @Published private(set) var mismatchedCardIDs: Set<UUID> = []
    @Published private(set) var matchedFlashCardIDs: Set<UUID> = []

    let difficulty: Difficulty
    let theme: Theme

    private var indexOfOnlyFaceUpCard: Int?
    private var isResolvingMismatch: Bool = false
    private var timer: Timer?

    init(difficulty: Difficulty, theme: Theme) {
        self.difficulty = difficulty
        self.theme = theme
        newGame()
    }

    deinit {
        timer?.invalidate()
    }

    func newGame() {
        timer?.invalidate()
        timer = nil

        moves = 0
        matchedPairs = 0
        phase = .playing
        indexOfOnlyFaceUpCard = nil
        isResolvingMismatch = false
        mismatchedCardIDs = []
        matchedFlashCardIDs = []

        let total = difficulty.numeroDeCartas
        let pairs = total / 2
        let faces = Array(theme.itens.shuffled().prefix(pairs))

        var deck: [MemoryCard] = []
        deck.reserveCapacity(total)
        for face in faces {
            deck.append(MemoryCard(face: face))
            deck.append(MemoryCard(face: face))
        }
        cards = deck.shuffled()

        timeRemaining = difficulty.tempoTotal
        startTimer()
    }

    func flip(_ card: MemoryCard, efeitosSonorosAtivos: Bool) {
        guard phase == .playing else { return }
        guard isResolvingMismatch == false else { return }
        guard let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard cards[idx].isMatched == false else { return }
        guard cards[idx].isFaceUp == false else { return }

        if let only = indexOfOnlyFaceUpCard {
            // Segunda carta
            cards[idx].isFaceUp = true
            moves += 1

            if cards[only].face == cards[idx].face {
                cards[only].isMatched = true
                cards[idx].isMatched = true
                matchedPairs += 1
                indexOfOnlyFaceUpCard = nil
                flashMatched(firstID: cards[only].id, secondID: cards[idx].id)

                notify(.success, efeitosSonorosAtivos: efeitosSonorosAtivos)

                if matchedPairs == (difficulty.numeroDeCartas / 2) {
                    win()
                }
            } else {
                // Não coincide: fecha após breve atraso
                indexOfOnlyFaceUpCard = nil
                isResolvingMismatch = true
                notify(.warning, efeitosSonorosAtivos: efeitosSonorosAtivos)

                let firstID = cards[only].id
                let secondID = cards[idx].id
                flashMismatch(firstID: firstID, secondID: secondID)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 550_000_000)
                    self.faceDownIfNeeded(firstID: firstID, secondID: secondID)
                    self.isResolvingMismatch = false
                }
            }
        } else {
            // Primeira carta: fecha todas as outras não-matched (segurança)
            for i in cards.indices where cards[i].isMatched == false {
                cards[i].isFaceUp = false
            }
            cards[idx].isFaceUp = true
            indexOfOnlyFaceUpCard = idx
            notify(.light, efeitosSonorosAtivos: efeitosSonorosAtivos)
        }
    }

    private enum Feedback {
        case light
        case success
        case warning
    }

    private func notify(_ feedback: Feedback, efeitosSonorosAtivos: Bool) {
        // Feedback tátil (sempre) + efeitos sonoros (opcional).
#if canImport(UIKit)
        switch feedback {
        case .light:
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.prepare()
            gen.impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
#else
        _ = feedback
#endif

        guard efeitosSonorosAtivos else { return }
#if canImport(AudioToolbox)
        // Sons do sistema (offline, sem assets).
        let id: SystemSoundID
        switch feedback {
        case .light: id = 1104   // “tock”
        case .success: id = 1111 // “success-ish”
        case .warning: id = 1053 // “error-ish”
        }
        AudioServicesPlaySystemSound(id)
#endif
    }

    private func faceDownIfNeeded(firstID: UUID, secondID: UUID) {
        guard phase == .playing else { return }
        guard let a = cards.firstIndex(where: { $0.id == firstID }),
              let b = cards.firstIndex(where: { $0.id == secondID }) else { return }
        if cards[a].isMatched == false { cards[a].isFaceUp = false }
        if cards[b].isMatched == false { cards[b].isFaceUp = false }
    }

    private func flashMismatch(firstID: UUID, secondID: UUID) {
        mismatchedCardIDs.formUnion([firstID, secondID])
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 650_000_000)
            self.mismatchedCardIDs.subtract([firstID, secondID])
        }
    }

    private func flashMatched(firstID: UUID, secondID: UUID) {
        matchedFlashCardIDs.formUnion([firstID, secondID])
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            self.matchedFlashCardIDs.subtract([firstID, secondID])
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.tick()
            }
        }
    }

    private func tick() {
        guard phase == .playing else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        if timeRemaining == 0 {
            timer?.invalidate()
            timer = nil
            phase = .timeUp
        }
    }

    private func win() {
        timer?.invalidate()
        timer = nil
        phase = .victory

        let timeUsed = max(0, difficulty.tempoTotal - timeRemaining)
        ScoreStore.updateIfBetter(difficulty: difficulty, theme: theme, moves: moves, timeSeconds: timeUsed)
    }
}

