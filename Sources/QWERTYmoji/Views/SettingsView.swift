//
//  SettingsView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

/// Contains all configurable settings for the game
struct SettingsView: View {

    @Binding var path: [Destination]
    @Environment(\.userSettings) var userSettings

    var body: some View {
        DismissableVStack(showMenuBackground: true) {
            KeyCapRowsView(rows: [
                "SETTINGS".map { String($0) }
            ])

            Spacer()

            difficultyRampUpToggle

            MainContentButton(title: "KEYBOARD SIZE", systemImage: "keyboard.fill", color: .customRose) {
                path.append(.keyboardSizer)
            }
            .padding(.horizontal, 210)
            .padding(.bottom, 150)
        }
        .toolbar(.hidden)
        .statusBarHidden(true)
    }

    private var difficultyRampUpToggle: some View {
        MainContentButton(
            title: userSettings.difficultyRampUpEnabled
            ? "DISABLE FASTER ROUNDS"
            : "ENABLE FASTER ROUNDS",
            systemImage: userSettings.difficultyRampUpEnabled
            ? "x.circle.fill"
            : "checkmark.circle.fill",
            color: .customRose
        ) {
            withAnimation {
                userSettings.difficultyRampUpEnabled.toggle()
            }
        }
        .padding(.horizontal, 210)
        .padding(.bottom)
    }
}

struct KeyboardSizingView: View {

    @State var sliderValue: CGFloat = 1.0
    @Environment(\.keyboardObserver) var keyboardObserver

    var body: some View {
        DismissableVStack(showMenuBackground: true) {

            Spacer()

            Slider(value: $sliderValue, in: 0.5...1.0)
                .padding(.horizontal, 210)

            Spacer()

            KeyboardView(backgroundColor: nil)
        }
        .toolbar(.hidden)
        .onAppear {
            sliderValue = keyboardObserver.scale
        }
        .onChange(of: sliderValue) {
            keyboardObserver.scale = $0
        }
    }
}

//#Preview {
//    SettingsView()
//}
