import SwiftUI

struct VictoryView: View {
    enum EndState: Equatable {
        case victory
        case timeUp
    }

    let state: EndState
    let difficultyTitle: String
    let themeTitle: String
    let movesText: String
    let timeTitle: String
    let timeText: String
    let onPlayAgain: () -> Void
    let onGoHome: () -> Void

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                Text(state == .victory ? "🎉" : "⏳")
                    .font(.system(size: 64))
                    .scaleEffect(pulse ? 1.06 : 1.0)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

                Text(state == .victory ? "Muito bem!" : "Tempo esgotado")
                    .font(.largeTitle.weight(.heavy))

                Text("\(themeTitle) • \(difficultyTitle)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                StatRow(title: "Jogadas", value: movesText)
                StatRow(title: timeTitle, value: timeText)
                if state == .timeUp {
                    Text("Queres tentar outra vez?")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: 520)
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            HStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Text("Jogar outra vez")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)

                Button(action: onGoHome) {
                    Text("Voltar ao início")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: 520)

            Spacer(minLength: 6)
        }
        .padding(18)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear { pulse = true }
    }
}

private struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline.weight(.semibold))
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }
}

#Preview {
    VictoryView(
        state: .victory,
        difficultyTitle: "Médio",
        themeTitle: "Animais",
        movesText: "18",
        timeTitle: "Tempo restante",
        timeText: "2:15",
        onPlayAgain: {},
        onGoHome: {}
    )
}

