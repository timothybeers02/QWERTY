//
//  KeyboardView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

/// A custom keyboard view that lays out the emoji keys in QWERTY order.
struct KeyboardView: View {
    // Get the observer from the environment.
    @Environment(\.keyboardObserver) var keyboardObserver
    let verticalSpacing = 8.0
    let horizontalSpacing = 8.0
    var overrideScale: CGFloat? = nil

    var body: some View {
        VStack(spacing: verticalSpacing) {
            rowView(for: KeyboardLayout.topRow)
            rowView(for: KeyboardLayout.middleRow)
            rowView(for: KeyboardLayout.bottomRow)
            rowView(for: KeyboardLayout.spaceRow)
        }
        .background {
            Color.black.opacity(0.1).background(Material.regularMaterial.opacity(0.2)).ignoresSafeArea()
        }
        .scaleEffect(overrideScale ?? keyboardObserver.scale)
    }

    @ViewBuilder
    func rowView(for row: [EmojiKey]) -> some View {
        HStack(spacing: horizontalSpacing) {
            Spacer()
            ForEach(row) { key in
                KeyButton(key: key)
            }
            Spacer()
        }
    }
}

/// A reusable view that renders an individual key.
extension KeyboardView {

    struct KeyButton: View {

        let key: EmojiKey
        @Environment(\.keyboardObserver) var keyboardObserver

        var body: some View {
            Button(action: {
                // Notify the observer when the key is tapped.
                keyboardObserver.tap(key: key)
            }) {
                Text(key.emoji)
                    .font(.title)
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}

/// A view modifier that listens for key tap events and calls the provided closure.
struct KeyTapModifier: ViewModifier {

    @Environment(\.keyboardObserver) var keyboardObserver
    let perform: (EmojiKey) -> Void

    func body(content: Content) -> some View {
        content
            // Every time a key tap event is published, call `perform`.
            .onReceive(keyboardObserver.keyTapSubject) { key in
                perform(key)
            }
    }
}

extension View {
    func onKeyTap(_ perform: @escaping (EmojiKey) -> Void) -> some View {
        self.modifier(KeyTapModifier(perform: perform))
    }
}
