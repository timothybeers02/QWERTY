//
//  StatsRepositoryTests.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 7/26/25.
//

import Foundation
import Testing
@testable import QWERTYmoji

struct StatsRepositoryTests {

    @Test("FileStatsRepository allStats returns empty array when no files exist")
    func emptyStats() async throws {
        let repository = FileStatsRepository()

        try? clearStatsFiles(repository: repository)

        let stats = repository.allStats
        #expect(stats.isEmpty)
    }

    @Test("FileStatsRepository save creates a file and allStats can read it")
    func saveAndLoad() async throws {
        let repository = FileStatsRepository()

        try? clearStatsFiles(repository: repository)

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
    func ignoresNonJsonFiles() async throws {
        let repository = FileStatsRepository()

        let nonJsonURL = repository.folderURL.appendingPathComponent("test.txt")
        try "test content".write(to: nonJsonURL, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: nonJsonURL)
        }

        let stats = repository.allStats
        // Should not include the .txt file
        #expect(stats.allSatisfy { $0.gameMode != "test.txt" })
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
