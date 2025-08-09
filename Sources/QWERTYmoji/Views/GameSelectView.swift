//
//  GameSelectView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

/// View where users select the game mode to play, navigating to GameView with the selection
struct GameSelectView: View {

    @Binding var path: [Destination]

    var body: some View {
        DismissableVStack(showMenuBackground: true) {
            KeyCapRowsView(rows: [
                "SELECT".map { String($0) },
                "GAME".map { String($0) }
            ])

            Spacer()

            VStack(spacing: 50) {
                GameSelectButton(
                    title: "ALIEN INVASION",
                    color: .green,
                    action: navigateToGame
                )

                GameSelectButton(
                    title: "COMING SOON",
                    color: .customCyan,
                    action: {}
                )
                .disabled(true)
            }
            .padding(.bottom, 150)

            HStack {
                Spacer()
            }
        }
        .toolbar(.hidden)
        .statusBarHidden(true)
    }

    private func navigateToGame() {
        path.append(.gameStart)
    }
}

private struct GameSelectButton: View {

    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                ForEach(title.components(separatedBy: " "), id: \.self) { string in
                    Text(string)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 4)
                }
            }
            .padding(75)
            .background(color)
            .clipShape(Circle())
            .background(color.brightness(-0.5).clipShape(Circle()).offset(x: 1, y: 3))
        }
    }
}

#Preview {
    GameSelectView(path: .constant([]))
}
