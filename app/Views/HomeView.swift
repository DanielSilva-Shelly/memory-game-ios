import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var settings: SettingsStore

    @State private var selectedDifficulty: Difficulty = .facil
    @State private var selectedTheme: Theme = .animais
    @State private var showSettings: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    difficultyCard
                    themeCard
                    actionButtons
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            }
            .background(background)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
    }

    // MARK: header

    private var header: some View {
        VStack(spacing: 8) {
            Text("🧠")
                .font(.system(size: 52))
            Text("Jogo da Memória")
                .font(.largeTitle.weight(.heavy))
                .multilineTextAlignment(.center)
            Text("Encontra os pares e diverte-te!")
                .font(.subheadline)
                .foregroundStyle(warmGray)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: difficulty card

    private var difficultyCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Dificuldade", systemImage: "slider.horizontal.3")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(warmGray)
                    .textCase(.uppercase)
                    .tracking(0.4)

                HStack(spacing: 8) {
                    ForEach(Difficulty.allCases) { d in
                        ChoicePill(label: d.titulo, isSelected: selectedDifficulty == d) {
                            selectedDifficulty = d
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                Text(selectedDifficulty.subtitulo)
                    .font(.footnote)
                    .foregroundStyle(warmGray)
                    .padding(.top, 2)
            }
        }
    }

    // MARK: theme card

    private var themeCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Tema", systemImage: "face.smiling")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(warmGray)
                    .textCase(.uppercase)
                    .tracking(0.4)

                HStack(spacing: 8) {
                    ForEach(Theme.allCases) { t in
                        ChoicePill(label: t.titulo, isSelected: selectedTheme == t) {
                            selectedTheme = t
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                sampleRow
                    .padding(.top, 4)
            }
        }
    }

    // MARK: sample row

    private var sampleRow: some View {
        HStack(spacing: 8) {
            ForEach(Array(selectedTheme.itens.prefix(6)), id: \.self) { s in
                Text(s)
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(
                        accentColor.opacity(0.09),
                        in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: action buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            NavigationLink {
                GameView(viewModel: MemoryGameViewModel(
                    difficulty: selectedDifficulty,
                    theme: selectedTheme
                ))
            } label: {
                Label("Jogar", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(CoralPrimaryButtonStyle())
            .accessibilityLabel("Jogar")

            Button {
                showSettings = true
            } label: {
                Label("Definições", systemImage: "gearshape")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GhostButtonStyle())
            .accessibilityLabel("Definições")
        }
    }

    // MARK: style

    private var accentColor: Color { Color(red: 1.0, green: 0.36, blue: 0.30) }
    private var warmGray: Color { Color(red: 0.52, green: 0.49, blue: 0.46) }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.99, green: 0.97, blue: 0.95),
                Color(red: 0.95, green: 0.95, blue: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - SoftCard

private struct SoftCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

// MARK: - ChoicePill

private struct ChoicePill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    private let coral = Color(red: 1.0, green: 0.36, blue: 0.30)

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? coral : Color(red: 0.96, green: 0.95, blue: 0.94),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .foregroundStyle(isSelected ? .white : Color(red: 0.36, green: 0.33, blue: 0.30))
                .shadow(color: isSelected ? coral.opacity(0.28) : .clear, radius: 6, x: 0, y: 3)
                .animation(.spring(response: 0.22, dampingFraction: 0.80), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Button styles

private struct CoralPrimaryButtonStyle: ButtonStyle {
    private let coral = Color(red: 1.0, green: 0.36, blue: 0.30)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(coral, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: coral.opacity(configuration.isPressed ? 0.20 : 0.35),
                    radius: configuration.isPressed ? 5 : 10,
                    x: 0, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

private struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .foregroundStyle(Color(red: 0.52, green: 0.49, blue: 0.46))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
        .environmentObject(SettingsStore())
}
