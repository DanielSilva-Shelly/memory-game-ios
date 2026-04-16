import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var settings: SettingsStore

    @State private var selectedDifficulty: Difficulty = .facil
    @State private var selectedTheme: Theme = .animais
    @State private var showSettings: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header

                    VStack(spacing: 12) {
                        pickerCard(title: "Dificuldade") {
                        Picker("Dificuldade", selection: $selectedDifficulty) {
                            ForEach(Difficulty.allCases) { d in
                                Text(d.titulo).tag(d)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text(selectedDifficulty.subtitulo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                    }

                        pickerCard(title: "Tema") {
                        Picker("Tema", selection: $selectedTheme) {
                            ForEach(Theme.allCases) { t in
                                Text(t.titulo).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)

                        sampleRow
                            .padding(.top, 6)
                        }
                    }

                    VStack(spacing: 12) {
                        NavigationLink {
                            GameView(viewModel: MemoryGameViewModel(
                                difficulty: selectedDifficulty,
                                theme: selectedTheme
                            ))
                        } label: {
                            Label("Jogar", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(KidsPrimaryButtonStyle())
                        .accessibilityLabel("Jogar")

                        Button {
                            showSettings = true
                        } label: {
                            Label("Definições", systemImage: "gearshape.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(KidsSecondaryButtonStyle())
                        .accessibilityLabel("Definições")
                    }
                }
            }
            .frame(maxWidth: 720)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(background)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("Jogo da Memória Kids")
                .font(.largeTitle.weight(.heavy))
                .multilineTextAlignment(.center)

            Text("Encontra os pares e diverte-te!")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
        .accessibilityAddTraits(.isHeader)
    }

    private var sampleRow: some View {
        HStack(spacing: 10) {
            ForEach(Array(selectedTheme.itens.prefix(6)), id: \.self) { s in
                Text(s)
                    .font(.title2)
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func pickerCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.weight(.semibold))
            content()
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.90, blue: 0.95),
                Color(red: 0.92, green: 0.95, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct KidsPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.bold))
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.pink, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.08 : 0.12),
                    radius: configuration.isPressed ? 6 : 12,
                    x: 0, y: configuration.isPressed ? 3 : 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

private struct KidsSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.55), lineWidth: 1)
            )
            .foregroundStyle(.primary)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
        .environmentObject(SettingsStore())
}

