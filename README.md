# Jogo da Memória Kids — iOS & iPadOS

Jogo da memória simples e intuitivo para crianças (4–10 anos), desenvolvido em SwiftUI. 
**Offline**, **sem anúncios**, **sem login**, **sem tracking**. Idioma: **Português (PT-PT)**.

## Estrutura de pastas

O código vive em `app/`:

- `app/`: código fonte principal
- `app/Models/`: `Difficulty`, `Theme`, `MemoryCard`, `Score`
- `app/ViewModels/`: `MemoryGameViewModel`, `SettingsStore`, `ScoreStore`
- `app/Views/`: `HomeView`, `GameView`, `SettingsView`, `VictoryView`
- `app/JogoDaMemoriaKidsApp.swift`: entry point da app

## Como correr no Xcode

1. No Xcode: **File → New → Project → iOS App** (Interface: **SwiftUI**, Language: **Swift**)
2. Copia a pasta `app/` para dentro do target (grupos “Sources/App”, como preferires), mantendo a estrutura.
3. Confirma **Target Membership** de todos os `.swift`.
4. Build & Run em iPhone/iPad (simulador ou dispositivo).
5. Seleciona um simulador (ex.: iPhone 15) e carrega em Run ▶️

## Definições e pontuações (UserDefaults)

- **Definições**
  - `Definições → Efeitos sonoros`: liga/desliga apenas os **efeitos sonoros** (sons do sistema).
- **Pontuações**
  - Guardadas localmente em `UserDefaults`, por **por combinação de dificuldade e tema**.
  - Em **Médio/Difícil (sem tempo)**: guarda o **melhor nº de jogadas** (menos é melhor).
  - Em **Difícil (com tempo)**: guarda o **melhor tempo** (menos é melhor).
  - `Definições → Repor pontuações`: apaga todas as pontuações.

## Próximas melhorias (v2)

- Mais temas (ex.: “Transportes”, “Formas”, “Cores”)
- Ecrã de “Setup” dedicado + pré-visualização do tabuleiro
- Sons `.wav` próprios (offline) + toggle separado para vibração
- Acessibilidade extra: VoiceOver labels por emoji e modo alto contraste
- Estatísticas simples (vitórias por modo/tema) sem tracking externo
