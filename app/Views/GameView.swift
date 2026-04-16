import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: MemoryGameViewModel

    init(viewModel: MemoryGameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GameScreen(viewModel: viewModel)
    }
}

#Preview {
    NavigationStack {
        GameView(viewModel: MemoryGameViewModel(difficulty: .medio, theme: .animais))
            .environmentObject(SettingsStore())
    }
}

