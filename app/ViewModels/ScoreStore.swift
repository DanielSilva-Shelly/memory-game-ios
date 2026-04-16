import Foundation

enum ScoreStore {
    private static let defaults = UserDefaults.standard

    static func key(difficulty: Difficulty, theme: Theme) -> String {
        "scores.\(difficulty.rawValue).\(theme.rawValue)"
    }

    static func load(difficulty: Difficulty, theme: Theme) -> Score {
        let k = key(difficulty: difficulty, theme: theme)
        guard let data = defaults.data(forKey: k),
              let score = try? JSONDecoder().decode(Score.self, from: data) else {
            return Score(bestMoves: nil, bestTimeSeconds: nil)
        }
        return score
    }

    static func save(_ score: Score, difficulty: Difficulty, theme: Theme) {
        let k = key(difficulty: difficulty, theme: theme)
        guard let data = try? JSONEncoder().encode(score) else { return }
        defaults.set(data, forKey: k)
    }

    static func updateIfBetter(difficulty: Difficulty, theme: Theme, moves: Int?, timeSeconds: Int?) {
        var current = load(difficulty: difficulty, theme: theme)

        if let moves {
            if current.bestMoves == nil || moves < current.bestMoves! {
                current.bestMoves = moves
            }
        }

        if let timeSeconds {
            if current.bestTimeSeconds == nil || timeSeconds < current.bestTimeSeconds! {
                current.bestTimeSeconds = timeSeconds
            }
        }

        save(current, difficulty: difficulty, theme: theme)
    }

    static func resetAll() {
        for d in Difficulty.allCases {
            for t in Theme.allCases {
                defaults.removeObject(forKey: key(difficulty: d, theme: t))
            }
        }
    }
}

