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
    let backgroundColor: Color?

    var body: some View {
        VStack(spacing: verticalSpacing) {
            rowView(for: KeyboardLayout.topRow)
            rowView(for: KeyboardLayout.middleRow)
            rowView(for: KeyboardLayout.bottomRow)
            rowView(for: KeyboardLayout.spaceRow)
        }
        .scaleEffect(overrideScale ?? keyboardObserver.scale)
        .padding(.top, verticalSpacing)
        .background {
            (backgroundColor ?? Color.black.opacity(0.1)).ignoresSafeArea()
        }
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
                    .font(.largeTitle)
            }
            .buttonStyle(KeyStyle())
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


// MARK: - Custom Key Button Style
struct KeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                configuration.isPressed
                ? Color.keyBackgroundPressed.blur(radius: 1)
                : Color.keyBackground.blur(radius: 1)
            )
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
