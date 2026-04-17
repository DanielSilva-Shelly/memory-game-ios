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
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 22) {
                heroSection
                statsCard
                actionButtons
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear { pulse = true }
    }

    // MARK: hero section

    private var heroSection: some View {
        VStack(spacing: 8) {
            Text(state == .victory ? "🎉" : "⏳")
                .font(.system(size: 60))
                .scaleEffect(pulse ? 1.06 : 1.0)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

            Text(state == .victory ? "Muito bem!" : "Tempo esgotado")
                .font(.title.weight(.heavy))
                .foregroundStyle(DS.textPrimary)

            Text("\(themeTitle) • \(difficultyTitle)")
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
        }
        .padding(.top, 4)
    }

    // MARK: stats card

    private var statsCard: some View {
        VStack(spacing: 0) {
            StatRow(title: "Jogadas", value: movesText)
            Divider().padding(.horizontal, 14)
            StatRow(title: timeTitle, value: timeText)
            if state == .timeUp {
                Divider().padding(.horizontal, 14)
                Text("Queres tentar outra vez?")
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 14)
            }
        }
        .frame(maxWidth: 480)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
    }

    // MARK: action buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button(action: onPlayAgain) {
                Text("Jogar outra vez")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(action: onGoHome) {
                Text("Voltar ao início")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: 480)
    }
}

// MARK: - StatRow

private struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DS.textSecondary)
            Spacer()
            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundStyle(DS.textPrimary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
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
