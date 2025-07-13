//
//  StatsRepository.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 7/6/25.
//

import Foundation

protocol StatsRepository {
    var allStats: [RoundStats] { get }
    func save(_ stats: RoundStats) throws
}

class FileStatsRepository: StatsRepository {

    let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    var allStats: [RoundStats] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            return fileURLs.compactMap { url in
                guard url.pathExtension == "json" else { return nil }
                do {
                    let data = try Data(contentsOf: url)
                    return try JSONDecoder().decode(RoundStats.self, from: data)
                } catch {
                    print("Error decoding stats from \(url):", error)
                    return nil
                }
            }
        } catch {
            print("Error listing stats directory:", error)
            return []
        }
    }

    func save(_ stats: RoundStats) throws {
        let fileURL = folderURL.appendingPathComponent("stats_\(UUID()).json")
        let data = try JSONEncoder().encode(stats)
        try data.write(to: fileURL)
    }
}
