//
//  KeyboardObserverTests.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 7/26/25.
//

import Foundation
import Testing
@testable import QWERTYmoji

struct KeyboardObserverTests {

    @Test("KeyboardObserver initializes with default scale of 1.0")
    func keyboardObserverInit() async throws {
        let observer = KeyboardObserver()
        #expect(observer.scale == 1.0)
    }

    @Test("KeyboardObserver tap method sends key through subject")
    func tapMethod() async throws {
        let observer = KeyboardObserver()
        let testKey = EmojiKey(letter: "A", emoji: "🚀")
        observer.tap(key: testKey)

        let receivedKey = await observer.keyTapSubject.values.first { _ in true }

        #expect(receivedKey == testKey)
    }

    @Test("KeyboardObserver scale can be modified")
    func scaleModification() async throws {
        let observer = KeyboardObserver()
        observer.scale = 0.5
        #expect(observer.scale == 0.5)
    }
} 
