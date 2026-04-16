import SwiftUI

@main
struct JogoDaMemoriaKidsApp: App {
    @StateObject private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(settings)
        }
    }
}

