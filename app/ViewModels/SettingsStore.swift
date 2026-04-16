import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SettingsStore: ObservableObject {
    @AppStorage("efeitosSonorosAtivos") var efeitosSonorosAtivos: Bool = true

    func resetarPontuacoes() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys

        for key in keys where key.hasPrefix("scores.") {
            defaults.removeObject(forKey: key)
        }
    }
}
