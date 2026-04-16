import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Som") {
                    Toggle("Efeitos sonoros", isOn: $settings.efeitosSonorosAtivos)
                        .accessibilityLabel("Efeitos sonoros")
                }

                Section("Pontuações") {
                    Button(role: .destructive) {
                        settings.resetarPontuacoes()
                    } label: {
                        Text("Repor pontuações")
                    }
                }

                Section {
                    Text("Offline. Sem anúncios. Sem login. Sem tracking.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Definições")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsStore())
}

