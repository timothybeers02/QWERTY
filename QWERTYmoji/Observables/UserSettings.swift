//
//  UserSettings.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 7/13/25.
//

import SwiftUI

/// Defines user configurable settings and stores them in UserDefaults
@Observable
class UserSettings {
    var difficultyRampUpEnabled: Bool {
        didSet {
            UserDefaults.standard.set(difficultyRampUpEnabled, forKey: "difficultyRampUpEnabled")
        }
    }

    init() {
        self.difficultyRampUpEnabled = UserDefaults.standard.object(forKey: "difficultyRampUpEnabled") as? Bool ?? true
    }
}
