//
//  UserSettingsTests.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 7/26/25.
//

import Foundation
import Testing
@testable import QWERTYmoji

@Suite(.serialized)
struct UserSettingsTests {

    @Test("UserSettings initializes with default difficulty ramp up enabled")
    func userSettingsInit() async throws {
        UserDefaults.standard.removeObject(forKey: "difficultyRampUpEnabled")

        let settings = UserSettings()
        #expect(settings.difficultyRampUpEnabled == true)
    }

    @Test("UserSettings saves difficulty ramp up setting to UserDefaults")
    func saveToUserDefaults() async throws {
        let settings = UserSettings()
        settings.difficultyRampUpEnabled = false

        let savedValue = UserDefaults.standard.bool(forKey: "difficultyRampUpEnabled")
        #expect(savedValue == false)
    }

    @Test("UserSettings loads saved difficulty ramp up setting from UserDefaults")
    func loadFromUserDefaults() async throws {
        UserDefaults.standard.set(false, forKey: "difficultyRampUpEnabled")

        let settings = UserSettings()
        #expect(settings.difficultyRampUpEnabled == false)
    }
}
