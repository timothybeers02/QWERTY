//
//  EmojiKey.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/4/25.
//

import Foundation

/// Represents a single key on the emoji keyboard.
struct EmojiKey: Identifiable, Equatable {
    /// A unique identifier (here we use a generated UUID).
    let id = UUID()
    
    /// The letter (or “value”) associated with this key.
    let letter: String
    
    /// The emoji to display for this key.
    let emoji: String
}
