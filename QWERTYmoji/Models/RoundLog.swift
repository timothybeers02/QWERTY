//
//  RoundLog.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/16/25.
//

import Foundation

//struct RoundLog {
//    var attempts: [KeyAttempt] = []
//
//    var weakestKey: EmojiKey? {
//        attempts.filter { $0.wasCorrect == false }.mode?.actual
//    }
//
//    mutating func recordAttempt(_ attempt: KeyAttempt) {
//        attempts.append(attempt)
//    }
//}
//
//struct KeyAttempt: Hashable {
//    let expected: EmojiKey
//    let actual: EmojiKey
//
//    var wasCorrect: Bool {
//        expected == actual
//    }
//}
//
//extension Array where Element: Hashable {
//    var mode: Element? {
//        let counts = self.reduce(into: [Element: Int]()) { counts, element in
//            counts[element, default: 0] += 1
//        }
//
//        return counts.max { $0.value < $1.value }?.key
//    }
//}
