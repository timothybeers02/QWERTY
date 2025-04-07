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
    @State private var scene: UFOTypingScene?

    var body: some View {
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
            scene = newScene
        }
    }
}

#Preview {
    GameView()
}
