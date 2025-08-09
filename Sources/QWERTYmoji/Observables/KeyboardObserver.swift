//
//  KeyboardObserver.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/8/25.
//

import SwiftUI
import Combine

/// An observable object that “publishes” key tap events.
@Observable
final class KeyboardObserver {
    /// A subject that emits every key tap as an event.
    let keyTapSubject = PassthroughSubject<EmojiKey, Never>()
    var scale: CGFloat = 1.0

    /// Call this to send a tap event.
    func tap(key: EmojiKey) {
        keyTapSubject.send(key)
    }
}
