//
//  UFOTypingSceneTests.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 7/26/25.
//

import Foundation
import Testing
import SwiftUI
import SpriteKit
@testable import QWERTYmoji

@MainActor
struct UFOTypingSceneTests {

    @Test("UFOTypingScene has correct friendly name")
    func friendlyName() async throws {
        #expect(UFOTypingScene.friendlyName == "Alien Invasion")
    }

    @Test("UFOTypingScene has correct keyboard background color")
    func keyboardBackgroundColor() async throws {
        let scene = UFOTypingScene()

        #expect(scene.keyboardBackgroundColor == Color.invasionBackground)
    }

    @Test("UFOTypingScene initializes with default values")
    func initialization() async throws {
        let scene = UFOTypingScene()

        #expect(scene.remainingTargets == 0)
        #expect(scene.totalMistypes == 0)
        #expect(scene.rampUpEnabled == true)
        #expect(scene.rampUpThreshold == 1)
    }

    @Test("UFOTypingScene can modify ramp up settings")
    func rampUpSettings() async throws {
        let scene = UFOTypingScene()
        scene.rampUpEnabled = false
        scene.rampUpThreshold = 3

        #expect(scene.rampUpEnabled == false)
        #expect(scene.rampUpThreshold == 3)
    }

    @Test("UFOTypingScene roundStats initializes with correct game mode")
    func roundStats() async throws {
        let scene = UFOTypingScene()

        #expect(scene.roundStats.gameMode == "Alien Invasion")
        #expect(scene.roundStats.keyStrokeStats.isEmpty)
    }

    @Test("UFOTypingScene pause and resume methods exist")
    func pauseAndResume() async throws {
        let scene = UFOTypingScene()

        // These methods should not throw
        scene.pause()
        scene.resume()

        // If we get here without throwing, the test passes
        #expect(true)
    }
} 
