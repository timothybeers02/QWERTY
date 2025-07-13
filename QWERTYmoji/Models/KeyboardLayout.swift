//
//  KeyboardLayout.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/4/25.
//

/// Contains the QWERTY-style layout for the custom emoji keyboard.
struct KeyboardLayout {
    static let topRow: [EmojiKey] = [
        EmojiKey(letter: "Q", emoji: "👸🏼"),
        EmojiKey(letter: "W", emoji: "🍉"),
        EmojiKey(letter: "E", emoji: "🐘"),
        EmojiKey(letter: "R", emoji: "🌈"),
        EmojiKey(letter: "T", emoji: "🌮"),
        EmojiKey(letter: "Y", emoji: "🧶"),
        EmojiKey(letter: "U", emoji: "☂️"),
        EmojiKey(letter: "I", emoji: "🍦"),
        EmojiKey(letter: "O", emoji: "🍊"),
        EmojiKey(letter: "P", emoji: "🥞")
    ]
    
    static let middleRow: [EmojiKey] = [
        EmojiKey(letter: "A", emoji: "🍎"),
        EmojiKey(letter: "S", emoji: "🍓"),
        EmojiKey(letter: "D", emoji: "🐶"),
        EmojiKey(letter: "F", emoji: "🐸"),
        EmojiKey(letter: "G", emoji: "🍇"),
        EmojiKey(letter: "H", emoji: "🍯"),
        EmojiKey(letter: "J", emoji: "🪼"),
        EmojiKey(letter: "K", emoji: "🦘"),
        EmojiKey(letter: "L", emoji: "🦁")
    ]
    
    static let bottomRow: [EmojiKey] = [
        EmojiKey(letter: "Z", emoji: "🦓"),
        EmojiKey(letter: "X", emoji: "❎"),
        EmojiKey(letter: "C", emoji: "🌶"),
        EmojiKey(letter: "V", emoji: "🎻"),
        EmojiKey(letter: "B", emoji: "🥦"),
        EmojiKey(letter: "N", emoji: "🪺"),
        EmojiKey(letter: "M", emoji: "🐒")
    ]
    
    /// The space row is defined as several keys that all represent a space tap,
    /// but display different space-themed emojis.
    static let spaceRow: [EmojiKey] = [
        EmojiKey(letter: " ", emoji: "🚀🛰🌌☄️")
    ]

    static var allKeys: [EmojiKey] {
        topRow + middleRow + bottomRow + spaceRow
    }
}

extension EmojiKey {
    static let testKeyOne = EmojiKey(letter: "M", emoji: "🍈")
    static let testKeyTwo = EmojiKey(letter: "S", emoji: "🍓")
    static let testKeyThree = EmojiKey(letter: "N", emoji: "🍑")
    static let testKeyFour = EmojiKey(letter: "I", emoji: "🍦")
    static let testKeyFive = EmojiKey(letter: "H", emoji: "🍯")
}
