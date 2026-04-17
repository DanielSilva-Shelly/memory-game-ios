import SwiftUI

// MARK: - GameScreen

struct GameScreen: View {
    @ObservedObject var viewModel: MemoryGameViewModel

    var body: some View {
        GameScreenBody(viewModel: viewModel)
    }
}

// MARK: - GameScreenBody

/// Isolates all state so GameScreen.body stays trivially simple (1 expression).
private struct GameScreenBody: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @ObservedObject var viewModel: MemoryGameViewModel
    @State private var showEndState = false
    @State private var timerPulse = false

    var body: some View {
        mainStack
            .background(bgGradient)
            .navigationBarBackButtonHidden(true)
            .onReceive(viewModel.$phase) { phase in
                if phase == .victory || phase == .timeUp { showEndState = true }
            }
            .onReceive(viewModel.$timeRemaining) { _ in
                if timeLow { timerPulse = true }
            }
            .sheet(isPresented: $showEndState) {
                endSheet
            }
    }

    // MARK: main stack

    private var mainStack: some View {
        VStack(spacing: 8) {
            TopBarView(viewModel: viewModel, timerPulse: $timerPulse)
            boardGrid
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: board

    private var boardGrid: some View {
        GeometryReader { geo in
            let totalCards = viewModel.cards.count
            let cols = columnCount(for: geo.size)
            let rows = Int(ceil(Double(totalCards) / Double(cols)))
            let spacing = gridSpacing
            let hPad: CGFloat = 12
            let vPad: CGFloat = 8
            let cardSize = computeCardSize(available: geo.size, cols: cols, rows: rows,
                                           spacing: spacing, hPad: hPad, vPad: vPad)
            let gridCols = Array(
                repeating: GridItem(.fixed(cardSize), spacing: spacing),
                count: cols
            )
            VStack {
                Spacer(minLength: 0)
                LazyVGrid(columns: gridCols, spacing: spacing) {
                    ForEach(viewModel.cards) { card in
                        cardCell(card)
                            .frame(width: cardSize, height: cardSize)
                    }
                }
                .padding(.horizontal, hPad)
                .padding(.vertical, vPad)
                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func cardCell(_ card: MemoryCard) -> some View {
        let soundOn = settings.efeitosSonorosAtivos
        return Button {
            viewModel.flip(card, efeitosSonorosAtivos: soundOn)
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

    // MARK: end sheet

    private var endSheet: some View {
        let isVictory = viewModel.phase == .victory
        return VictoryView(
            state: isVictory ? .victory : .timeUp,
            difficultyTitle: viewModel.difficulty.titulo,
            themeTitle: viewModel.theme.titulo,
            movesText: "\(viewModel.moves)",
            timeTitle: isVictory ? "Tempo restante" : "Tempo gasto",
            timeText: isVictory
                ? timeString(viewModel.timeRemaining)
                : timeString(viewModel.difficulty.tempoTotal),
            onPlayAgain: { showEndState = false; viewModel.newGame() },
            onGoHome: { showEndState = false; dismiss() }
        )
    }

    // MARK: helpers

    private var isPad: Bool { hSizeClass == .regular }

    private var gridSpacing: CGFloat { isPad ? 12 : 8 }

    private func columnCount(for size: CGSize) -> Int {
        let isLandscape = size.width > size.height
        switch viewModel.difficulty {
        case .facil:   return isLandscape ? 5 : 4   // 2 rows / 3 rows
        case .medio:   return isLandscape ? 6 : 4   // 3 rows / 4 rows
        case .dificil: return isLandscape ? 5 : 5   // 4 rows / 4 rows
        }
    }

    private func computeCardSize(available: CGSize, cols: Int, rows: Int,
                                  spacing: CGFloat, hPad: CGFloat, vPad: CGFloat) -> CGFloat {
        let usableW = available.width  - 2 * hPad - CGFloat(cols - 1) * spacing
        let usableH = available.height - 2 * vPad - CGFloat(rows - 1) * spacing
        return max(44, min(usableW / CGFloat(cols), usableH / CGFloat(rows)))
    }

    private var timeLow: Bool {
        let threshold: Int
        switch viewModel.difficulty {
        case .facil:   threshold = 20
        case .medio:   threshold = 45
        case .dificil: threshold = 60
        }
        return viewModel.timeRemaining > 0
            && viewModel.timeRemaining <= threshold
            && viewModel.phase == .playing
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }

    private var bgGradient: some View {
        DS.background.ignoresSafeArea()
    }
}

// MARK: - TopBarView

private struct TopBarView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MemoryGameViewModel
    @Binding var timerPulse: Bool

    var body: some View {
        VStack(spacing: 10) {
            navRow
            pillsRow
            scoreLine
                .padding(.horizontal, 16)
        }
    }

    // MARK: nav row

    private var navRow: some View {
        HStack(spacing: 12) {
            backButton
            subtitleStack
            Spacer()
            restartButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.headline.weight(.bold))
                .frame(width: 44, height: 44)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 3)
        }
        .accessibilityLabel("Voltar")
    }

    private var restartButton: some View {
        Button(action: { viewModel.newGame() }) {
            Image(systemName: "arrow.counterclockwise")
                .font(.headline.weight(.bold))
                .frame(width: 44, height: 44)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 3)
        }
        .accessibilityLabel("Recomeçar")
    }

    private var subtitleStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.theme.titulo + " • " + viewModel.difficulty.titulo)
                .font(.headline.weight(.semibold))
                .foregroundStyle(DS.textPrimary)
        }
    }

    // MARK: pills row

    private var pillsRow: some View {
        HStack(spacing: 12) {
            StatPill(title: "Jogadas",
                     value: "\(viewModel.moves)",
                     icon: "arrow.left.arrow.right")
            TimerPillView(viewModel: viewModel, timerPulse: $timerPulse)
            pairsPill
        }
        .padding(.horizontal, 16)
    }

    private var pairsPill: some View {
        let total = viewModel.difficulty.numeroDeCartas / 2
        let matched = viewModel.matchedPairs
        return StatPill(title: "Pares",
                        value: "\(matched)/\(total)",
                        icon: "checkmark.circle.fill")
    }

    // MARK: score line

    private var scoreLine: some View {
        Text(scoreText)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DS.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }

    private var scoreText: String {
        let score = ScoreStore.load(difficulty: viewModel.difficulty,
                                   theme: viewModel.theme)
        let m = score.bestMoves.map { "\($0) jogadas" }
        let t = score.bestTimeSeconds.map { timeString($0) }
        if let m, let t { return "Melhor: \(m) • Melhor tempo: \(t)" }
        if let m         { return "Melhor: \(m)" }
        if let t         { return "Melhor tempo: \(t)" }
        return " "
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - StatPill

private struct StatPill: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DS.accent)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DS.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.3)
                Text(value)
                    .font(.body.weight(.bold))
                    .foregroundStyle(DS.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - TimerPillView

private struct TimerPillView: View {
    @ObservedObject var viewModel: MemoryGameViewModel
    @Binding var timerPulse: Bool

    var body: some View {
        pillContent
            .scaleEffect(isLow && timerPulse ? 1.015 : 1.0)
            .animation(pillAnimation, value: timerPulse)
            .onAppear { if isLow { timerPulse = true } }
            .onChange(of: isLow) { _, v in timerPulse = v }
    }

    private var pillContent: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isLow ? Color.orange : DS.accent)
            VStack(alignment: .leading, spacing: 1) {
                Text("Tempo")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DS.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.3)
                Text(timeString(viewModel.timeRemaining))
                    .font(.system(.body, design: .monospaced).weight(.bold))
                    .foregroundStyle(isLow ? Color.orange : DS.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(pillBackground)
    }

    private var pillBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(DS.surface)
            .shadow(color: isLow ? Color.orange.opacity(0.15) : .black.opacity(0.05),
                    radius: 8, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isLow ? Color.orange.opacity(0.45) : Color.clear,
                                  lineWidth: 1.5)
            )
    }

    private var pillAnimation: Animation {
        isLow ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default
    }

    private var isLow: Bool {
        let threshold: Int
        switch viewModel.difficulty {
        case .facil:   threshold = 20
        case .medio:   threshold = 45
        case .dificil: threshold = 60
        }
        return viewModel.timeRemaining > 0
            && viewModel.timeRemaining <= threshold
            && viewModel.phase == .playing
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - CardView

private struct CardView: View {
    let card: MemoryCard
    let isMismatched: Bool
    let isJustMatched: Bool

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                cardBackground
                cardFace(side: side)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .opacity(card.isMatched ? 0.55 : 1.0)
        .scaleEffect(isJustMatched ? 1.045 : (card.isMatched ? 0.985 : 1.0))
        .rotation3DEffect(.degrees(card.isFaceUp || card.isMatched ? 0 : 180),
                          axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: card.isFaceUp)
        .animation(.spring(response: 0.28, dampingFraction: 0.85), value: card.isMatched)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isJustMatched)
        .animation(.easeInOut(duration: 0.18), value: isMismatched)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityAddTraits(.isButton)
    }

    private var cardFill: AnyShapeStyle {
        if card.isFaceUp || card.isMatched {
            return AnyShapeStyle(Color.white)
        }
        return AnyShapeStyle(LinearGradient(
            colors: [Color(red: 1.0, green: 0.50, blue: 0.44),
                     Color(red: 0.93, green: 0.28, blue: 0.24)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(borderColor.opacity(0.70), lineWidth: borderWidth)
            )
            .shadow(
                color: card.isFaceUp || card.isMatched
                    ? .black.opacity(0.06)
                    : DS.accent.opacity(0.20),
                radius: 10, x: 0, y: 5
            )
    }

    @ViewBuilder
    private func cardFace(side: CGFloat) -> some View {
        if card.isFaceUp || card.isMatched {
            Text(card.face)
                .font(.system(size: max(54, side * 0.68), weight: .heavy))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .transition(.scale.combined(with: .opacity))
        } else {
            Image(systemName: "sparkles")
                .font(.system(size: max(24, side * 0.24), weight: .bold))
                .foregroundStyle(Color.white.opacity(0.92))
        }
    }

    private var borderColor: Color {
        if isMismatched              { return .orange }
        if card.isMatched || isJustMatched { return .green }
        return .white
    }

    private var borderWidth: CGFloat {
        (isMismatched || card.isMatched || isJustMatched) ? 4 : 2
    }
}
