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
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.97, blue: 0.95),
                         Color(red: 0.95, green: 0.95, blue: 1.00)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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

            Text("\(themeTitle) • \(difficultyTitle)")
                .font(.subheadline)
                .foregroundStyle(warmGray)
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
                    .foregroundStyle(warmGray)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 14)
            }
        }
        .frame(maxWidth: 480)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: action buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button(action: onPlayAgain) {
                Text("Jogar outra vez")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(VictoryPrimaryButtonStyle())

            Button(action: onGoHome) {
                Text("Voltar ao início")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(VictorySecondaryButtonStyle())
        }
        .frame(maxWidth: 480)
    }

    private var warmGray: Color { Color(red: 0.52, green: 0.49, blue: 0.46) }
}

// MARK: - StatRow

private struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.52, green: 0.49, blue: 0.46))
            Spacer()
            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

// MARK: - Button styles

private struct VictoryPrimaryButtonStyle: ButtonStyle {
    private let coral = Color(red: 1.0, green: 0.36, blue: 0.30)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .padding(.vertical, 15)
            .background(coral, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: coral.opacity(configuration.isPressed ? 0.20 : 0.32),
                    radius: configuration.isPressed ? 5 : 10,
                    x: 0, y: configuration.isPressed ? 2 : 5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

private struct VictorySecondaryButtonStyle: ButtonStyle {
    private let coral = Color(red: 1.0, green: 0.36, blue: 0.30)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 13)
            .background(
                coral.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .foregroundStyle(coral)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
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
