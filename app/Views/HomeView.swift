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
            .background(DS.background.ignoresSafeArea())
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
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center)
            Text("Encontra os pares e diverte-te!")
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
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
                    .foregroundStyle(DS.textSecondary)
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
                    .foregroundStyle(DS.textSecondary)
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
                    .foregroundStyle(DS.textSecondary)
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
                        DS.accent.opacity(0.08),
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
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityLabel("Jogar")

            Button {
                showSettings = true
            } label: {
                Label("Definições", systemImage: "gearshape")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityLabel("Definições")
        }
    }
}

// MARK: - SoftCard

private struct SoftCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
    }
}

// MARK: - ChoicePill

private struct ChoicePill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

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
                    isSelected ? DS.accent : DS.pillBg,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .foregroundStyle(isSelected ? Color.white : DS.textPrimary)
                .shadow(color: isSelected ? DS.accent.opacity(0.25) : .clear, radius: 5, x: 0, y: 2)
                .animation(.spring(response: 0.22, dampingFraction: 0.80), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(SettingsStore())
}
