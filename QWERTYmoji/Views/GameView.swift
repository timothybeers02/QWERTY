//
//  ContentView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/4/25.
//

import SwiftUI
import SpriteKit

/// View where the game occurs
struct GameView: View {

    @Environment(\.keyboardObserver) var keyboardObserver
    @Environment(\.statsRepository) var statsRepository
    @Environment(\.userSettings) var userSettings
    @Binding var path: [Destination]
    @State private var scene: UFOTypingScene?
    @State private var gameEnded = false

    private var totalMistypes: Int {
        scene?.totalMistypes ?? 0
    }

    private var targetsLeft: String {
        guard let targets = scene?.remainingTargets
        else { return "--" }

        return "\(targets)"
    }

    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                SpriteView(scene: scene ?? UFOTypingScene())
                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) { roundHUD }

                Rectangle().fill(.black).frame(height: 1.0)

                KeyboardView(backgroundColor: scene?.keyboardBackgroundColor)
                    .onKeyTap { key in
                        scene?.handleEmojiInput(key.emoji)
                        print("Key tapped \(key.emoji)")
                    }
            }
            .onAppear(perform: setupScene)

            if gameEnded {
                gameOverPopup
            }
        }
        .toolbar(.hidden)
    }

    private var roundHUD: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Text(targetsLeft + " more targets")// TODO: TB - fix targetsLeft to match max amount minus destroyed number since they spawn throughout the round instead of all spawning at beginning
            HStack {
                if totalMistypes <= 3 {
                    ForEach(0..<totalMistypes, id: \.self) { _ in
                        Text("❌")
                    }
                } else {
                    Text("\(totalMistypes) ❌")
                }
            }
        }
        .font(.title2)
        .fontWeight(.bold)
        .padding()
        .foregroundStyle(Color.white)
        .background {
            Color.black.opacity(0.4).blur(radius: 20).ignoresSafeArea()
        }
    }

    private var gameOverPopup: some View {
        VStack(spacing: 20) {
            KeyCapRowsView(rows: [
                "GAME OVER".map { String($0) },
            ], withTopPadding: false)
            .scaleEffect(0.75)
            .padding(50)

            Text("Nice Work! You beat all the aliens, for now.")
                .font(.title)

            // TODO: TB - play again button
            MainContentButton(title: "GO BACK", systemImage: "arrowshape.turn.up.backward.fill", color: .gray) {
                path = []
            }
            .scaleEffect(0.75)
            .padding(.horizontal, 75)
            .padding(.bottom, 50)
        }
        .cardBackground()
        .padding(.horizontal, 150)
    }

    private func setupScene() {
        let newScene = UFOTypingScene()
        newScene.rampUpEnabled = userSettings.difficultyRampUpEnabled
        newScene.scaleMode = .resizeFill
        newScene.onGameOver = { roundStats in
            do {
                try statsRepository.save(roundStats)
            } catch {
                print("error saving stats: \(error)")
            }
            gameEnded = true
        }
        scene = newScene
    }
}
