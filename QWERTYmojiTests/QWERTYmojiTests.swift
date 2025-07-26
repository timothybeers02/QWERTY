//
//  QWERTYmojiTests.swift
//  QWERTYmojiTests
//
//  Created by Timothy Beers on 7/26/25.
//

import Testing
import SwiftUI
import Combine
import SpriteKit
@testable import QWERTYmoji

struct QWERTYmojiTests {
    
    // MARK: - KeyboardObserver Tests
    
    @Test("KeyboardObserver initializes with default scale of 1.0")
    func testKeyboardObserverInitialization() async throws {
        let observer = KeyboardObserver()
        #expect(observer.scale == 1.0)
    }
    
    @Test("KeyboardObserver tap method sends key through subject")
    func testKeyboardObserverTap() async throws {
        let observer = KeyboardObserver()
        let expectation = Expectation(description: "Key tap received")
        var receivedKey: EmojiKey?
        
        let cancellable = observer.keyTapSubject
            .sink { key in
                receivedKey = key
                expectation.fulfill()
            }
        
        let testKey = EmojiKey(letter: "A", emoji: "🚀")
        observer.tap(key: testKey)
        
        await expectation.await()
        #expect(receivedKey == testKey)
        
        cancellable.cancel()
    }
    
    @Test("KeyboardObserver scale can be modified")
    func testKeyboardObserverScaleModification() async throws {
        let observer = KeyboardObserver()
        observer.scale = 2.0
        #expect(observer.scale == 2.0)
    }
    
    // MARK: - StatsRepository Tests
    
    @Test("FileStatsRepository allStats returns empty array when no files exist")
    func testFileStatsRepositoryEmptyStats() async throws {
        let repository = FileStatsRepository()
        
        // Clear existing stats files for this test
        try clearStatsFiles(repository: repository)
        
        let stats = repository.allStats
        #expect(stats.isEmpty)
    }
    
    @Test("FileStatsRepository save creates a file and allStats can read it")
    func testFileStatsRepositorySaveAndLoad() async throws {
        let repository = FileStatsRepository()
        
        // Clear existing stats files for this test
        try clearStatsFiles(repository: repository)
        
        let testStats = RoundStats(
            gameMode: "Test Game",
            endDate: Date(),
            keyStrokeStats: [
                KeyStrokeStat(
                    actualEmoji: "🚀",
                    enteredEmoji: "🚀",
                    timeToType: 1.5
                )
            ]
        )
        
        try repository.save(testStats)
        
        let loadedStats = repository.allStats
        #expect(loadedStats.count == 1)
        #expect(loadedStats.first?.gameMode == "Test Game")
        #expect(loadedStats.first?.keyStrokeStats.count == 1)
        #expect(loadedStats.first?.keyStrokeStats.first?.actualEmoji == "🚀")
    }
    
    @Test("FileStatsRepository ignores non-json files")
    func testFileStatsRepositoryIgnoresNonJsonFiles() async throws {
        let repository = FileStatsRepository()
        
        // Create a non-json file in the stats directory
        let nonJsonURL = repository.folderURL.appendingPathComponent("test.txt")
        try "test content".write(to: nonJsonURL, atomically: true, encoding: .utf8)
        
        defer {
            try? FileManager.default.removeItem(at: nonJsonURL)
        }
        
        let stats = repository.allStats
        // Should not include the .txt file
        #expect(stats.allSatisfy { $0.gameMode != "test.txt" })
    }
    
    // MARK: - UFOTypingScene Tests
    
    @Test("UFOTypingScene has correct friendly name")
    func testUFOTypingSceneFriendlyName() async throws {
        #expect(UFOTypingScene.friendlyName == "Alien Invasion")
    }
    
    @Test("UFOTypingScene has correct keyboard background color")
    func testUFOTypingSceneKeyboardBackgroundColor() async throws {
        let scene = UFOTypingScene()
        #expect(scene.keyboardBackgroundColor == Color.invasionBackground)
    }
    
    @Test("UFOTypingScene initializes with default values")
    func testUFOTypingSceneInitialization() async throws {
        let scene = UFOTypingScene()
        #expect(scene.remainingTargets == 0)
        #expect(scene.totalMistypes == 0)
        #expect(scene.rampUpEnabled == true)
        #expect(scene.rampUpThreshold == 1)
    }
    
    @Test("UFOTypingScene can modify ramp up settings")
    func testUFOTypingSceneRampUpSettings() async throws {
        let scene = UFOTypingScene()
        scene.rampUpEnabled = false
        scene.rampUpThreshold = 3
        
        #expect(scene.rampUpEnabled == false)
        #expect(scene.rampUpThreshold == 3)
    }
    
    @Test("UFOTypingScene roundStats initializes with correct game mode")
    func testUFOTypingSceneRoundStats() async throws {
        let scene = UFOTypingScene()
        #expect(scene.roundStats.gameMode == "Alien Invasion")
        #expect(scene.roundStats.keyStrokeStats.isEmpty)
    }
    
    @Test("UFOTypingScene pause and resume methods exist")
    func testUFOTypingScenePauseResume() async throws {
        let scene = UFOTypingScene()
        
        // These methods should not throw
        scene.pause()
        scene.resume()
        
        // If we get here without throwing, the test passes
        #expect(true)
    }
    
    // MARK: - Helper Methods
    
    private func clearStatsFiles(repository: FileStatsRepository) throws {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: repository.folderURL, includingPropertiesForKeys: nil)
        for url in fileURLs {
            if url.pathExtension == "json" {
                try FileManager.default.removeItem(at: url)
            }
        }
    }
}
