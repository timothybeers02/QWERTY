//
//  SettingsView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

struct SettingsView: View {

    @Binding var path: [Destination]

    var body: some View {
        DismissableVStack(showMenuBackground: true) {
            KeyCapRowsView(rows: [
                "SETTINGS".map { String($0) }
            ])

            Spacer()

            MainContentButton(title: "KEYBOARD SIZE", systemImage: "keyboard.fill", color: .customRose) {
                path.append(.keyboardSizer)
            }
            .padding(.horizontal, 210)
            .padding(.bottom, 150)
        }
        .toolbar(.hidden)
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

            KeyboardView()
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
