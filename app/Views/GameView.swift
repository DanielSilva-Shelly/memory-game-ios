import SwiftUI

struct GameView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: MemoryGameViewModel
    @State private var showEndState: Bool = false
    @State private var timerPulse: Bool = false

    init(viewModel: MemoryGameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geo in
            let isPadLike = geo.size.width >= 700
            let spacing: CGFloat = isPadLike ? 18 : 12
            let boardMaxWidth: CGFloat = isPadLike ? 980 : 560
            let boardWidth = max(260, min(geo.size.width - 32, boardMaxWidth))
            let columns = gridColumns(for: geo.size.width, boardWidth: boardWidth, difficulty: viewModel.difficulty, spacing: spacing)

            VStack(spacing: 14) {
                topBar

                ScrollView {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(viewModel.cards) { card in
                            Button {
                                viewModel.flip(card, efeitosSonorosAtivos: settings.efeitosSonorosAtivos)
                            } label: {
                                CardView(
                                    card: card,
                                    isMismatched: viewModel.mismatchedCardIDs.contains(card.id),
                                    isJustMatched: viewModel.matchedFlashCardIDs.contains(card.id)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(card.isMatched || viewModel.phase != .playing)
                            .accessibilityLabel(card.isMatched ? "Par encontrado" : "Carta")
                            .accessibilityHint("Toque para virar")
                        }
                    }
                    .frame(width: boardWidth)
                    .padding(.top, isPadLike ? 14 : 10)
                    .padding(.bottom, isPadLike ? 28 : 20)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.phase) { _, newValue in
            showEndState = (newValue == .victory || newValue == .timeUp)
        }
        .onChange(of: viewModel.timeRemaining) { _, _ in
            if shouldWarnTimeLow {
                timerPulse = true
            }
        }
        .sheet(isPresented: $showEndState) {
            let isVictory = (viewModel.phase == .victory)
            VictoryView(
                state: isVictory ? .victory : .timeUp,
                difficultyTitle: viewModel.difficulty.titulo,
                themeTitle: viewModel.theme.titulo,
                movesText: "\(viewModel.moves)",
                timeTitle: isVictory ? "Tempo restante" : "Tempo gasto",
                timeText: isVictory ? formatTime(viewModel.timeRemaining) : formatTime(viewModel.difficulty.tempoTotal),
                onPlayAgain: {
                    showEndState = false
                    viewModel.newGame()
                },
                onGoHome: {
                    showEndState = false
                    dismiss()
                }
            )
        }
    }

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.bold))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .accessibilityLabel("Voltar")

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.theme.titulo) • \(viewModel.difficulty.titulo)")
                        .font(.headline.weight(.semibold))
                    Text(statusLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    viewModel.newGame()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline.weight(.bold))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .accessibilityLabel("Recomeçar")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            HStack(spacing: 12) {
                pill(title: "Jogadas", value: "\(viewModel.moves)", icon: "arrow.left.arrow.right")
                timerPill
                pill(title: "Pares", value: "\(viewModel.matchedPairs)/\(viewModel.difficulty.numeroDeCartas/2)", icon: "checkmark.circle.fill")
            }
            .padding(.horizontal, 16)

            bestScoreLine
                .padding(.horizontal, 16)
        }
    }

    private var statusLine: String {
        "Encontra todos os pares antes do tempo acabar"
    }

    private var bestScoreLine: some View {
        let score = ScoreStore.load(difficulty: viewModel.difficulty, theme: viewModel.theme)
        let bestMovesText: String? = score.bestMoves.map { "\($0) jogadas" }
        let bestTimeText: String? = score.bestTimeSeconds.map { formatTime($0) }

        let text: String = {
            switch (bestMovesText, bestTimeText) {
            case (nil, nil):
                return " "
            case let (m?, nil):
                return "Melhor: \(m)"
            case let (nil, t?):
                return "Melhor tempo: \(t)"
            case let (m?, t?):
                return "Melhor: \(m) • Melhor tempo: \(t)"
            }
        }()

        return Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func gridColumns(for screenWidth: CGFloat, boardWidth: CGFloat, difficulty: Difficulty, spacing: CGFloat) -> [GridItem] {
        let isPadLike = screenWidth >= 700

        // iPad-first: menos colunas em portrait para cartas grandes; em landscape, deixa crescer um pouco.
        let columns: Int = {
            if isPadLike {
                let isLandscapeWide = screenWidth >= 1000
                switch difficulty {
                case .facil: return isLandscapeWide ? 5 : 4
                case .medio: return isLandscapeWide ? 6 : 5
                case .dificil: return isLandscapeWide ? 6 : 5
                }
            } else {
                switch difficulty {
                case .facil: return 4
                case .medio: return 4
                case .dificil: return 5
                }
            }
        }()

        let minCard = max(92, (boardWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns))
        return Array(repeating: GridItem(.flexible(minimum: minCard), spacing: spacing), count: columns)
    }

    private func pill(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.weight(.heavy))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var shouldWarnTimeLow: Bool {
        let threshold: Int = {
            switch viewModel.difficulty {
            case .facil: return 20
            case .medio: return 45
            case .dificil: return 60
            }
        }()
        return viewModel.timeRemaining > 0 && viewModel.timeRemaining <= threshold && viewModel.phase == .playing
    }

    private var timerPill: some View {
        let isLow = shouldWarnTimeLow
        return HStack(spacing: 10) {
            Image(systemName: "timer")
                .font(.headline.weight(.bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("Tempo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(formatTime(viewModel.timeRemaining))
                    .font(.system(.title3, design: .monospaced).weight(.heavy))
                    .foregroundStyle(isLow ? .orange : .primary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(isLow ? Color.orange.opacity(0.55) : Color.white.opacity(0.0), lineWidth: 2)
                )
        )
        .scaleEffect(isLow && timerPulse ? 1.015 : 1.0)
        .animation(isLow ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: timerPulse)
        .onAppear {
            if isLow { timerPulse = true }
        }
        .onChange(of: isLow) { _, newValue in
            timerPulse = newValue
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 1.0, blue: 0.96),
                Color(red: 0.93, green: 0.96, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct CardView: View {
    let card: MemoryCard
    let isMismatched: Bool
    let isJustMatched: Bool

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let emojiSize = max(54, side * 0.68)

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(card.isFaceUp || card.isMatched ? .white.opacity(0.90) : Color.blue.opacity(0.82))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(borderColor.opacity(0.75), lineWidth: borderLineWidth)
                    )
                    .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 8)

                if card.isFaceUp || card.isMatched {
                    Text(card.face)
                        .font(.system(size: emojiSize, weight: .heavy))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: max(24, side * 0.24), weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .opacity(card.isMatched ? 0.55 : 1.0)
        .scaleEffect(isJustMatched ? 1.045 : (card.isMatched ? 0.985 : 1.0))
        .rotation3DEffect(.degrees(card.isFaceUp || card.isMatched ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: card.isFaceUp)
        .animation(.spring(response: 0.28, dampingFraction: 0.85), value: card.isMatched)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isJustMatched)
        .animation(.easeInOut(duration: 0.18), value: isMismatched)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityAddTraits(.isButton)
    }

    private var borderColor: Color {
        if isMismatched { return .orange }
        if card.isMatched || isJustMatched { return .green }
        return .white
    }

    private var borderLineWidth: CGFloat {
        if isMismatched { return 4 }
        if card.isMatched || isJustMatched { return 4 }
        return 2
    }
}

#Preview {
    NavigationStack {
        GameView(viewModel: MemoryGameViewModel(difficulty: .medio, theme: .animais))
            .environmentObject(SettingsStore())
    }
}

