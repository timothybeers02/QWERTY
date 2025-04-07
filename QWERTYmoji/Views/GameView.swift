//
//  ContentView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/4/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {

    @Environment(\.keyboardObserver) var keyboardObserver
    @Binding var path: [Destination]
    @State private var scene: UFOTypingScene?
    @State private var gameEnded = false

    var body: some View {
        ZStack {
            VStack {
                SpriteView(scene: scene ?? UFOTypingScene())
                    .ignoresSafeArea()

                KeyboardView()
                    .onKeyTap { key in
                        scene?.handleEmojiInput(key.emoji)
                        print("Key tapped \(key.emoji)")
                    }
            }
            .onAppear {
                let newScene = UFOTypingScene()
                newScene.scaleMode = .resizeFill
                newScene.onGameOver = { gameEnded = true }
                scene = newScene
            }

            if gameEnded {
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
        }
        .toolbar(.hidden)
    }
}
