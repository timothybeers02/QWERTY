//
//  StatsView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

/// Convenience methods for statistics display
extension StatsRepository {
    var sortedRecentRounds: [RoundStats] {
        allStats.sorted { $0.endDate > $1.endDate }
    }

    var troubleKeys: [EmojiKey] {
        let strokes = allStats.flatMap { $0.keyStrokeStats }
        let grouped = Dictionary(grouping: strokes, by: { $0.actualEmoji })
        let averages = grouped.mapValues { list in
            list.map(\.timeToType).reduce(0, +) / Double(list.count)
        }
        return averages
            .sorted { $0.value > $1.value }
            .prefix(4)
            .compactMap { emoji, _ in
                KeyboardLayout.allKeys.first(where: { $0.emoji == emoji })
            }
    }

    func averageTimeString(for key: EmojiKey) -> String {
        let times = allStats
            .flatMap { $0.keyStrokeStats }
            .filter { $0.actualEmoji == key.emoji }
            .map(\.timeToType)
        guard !times.isEmpty else { return "--" }
        let avg = times.reduce(0, +) / Double(times.count)
        return String(format: "%.1fs", avg)
    }

    func timeAgoString(for round: RoundStats) -> String {
        let sec = Date().timeIntervalSince(round.endDate)
        if sec < 60 { return "\(Int(sec))s ago" }
        if sec < 3600 { return "\(Int(sec/60))m ago" }
        return "\(Int(sec/3600))h ago"
    }

    func averageTimeString(for round: RoundStats) -> String {
        let times = round.keyStrokeStats.map(\.timeToType)
        guard !times.isEmpty else { return "--" }
        let avg = times.reduce(0, +) / Double(times.count)
        return String(format: "%.1fs", avg)
    }

    func troubleKeys(for round: RoundStats) -> [EmojiKey] {
        let counts = Dictionary(grouping: round.keyStrokeStats, by: { $0.actualEmoji })
            .mapValues(\.count)
        return counts
            .sorted { $0.value > $1.value }
            .prefix(2)
            .compactMap { emoji, _ in
                KeyboardLayout.allKeys.first(where: { $0.emoji == emoji })
            }
    }
}

/// Shows recent round stats to the user
struct StatsView: View {

    @Environment(\.statsRepository) var statsRepository

    var body: some View {
        DismissableVStack(showMenuBackground: true) {

            KeyCapRowsView(rows: [
                "STATS".map { String($0) }
            ])

            ScrollView {
                VStack(alignment: .leading) {
                    Spacer()

                    HStack(spacing: 20) {
                        Image(systemName: "chart.bar.fill")

                        Text("Needs More Practice")
                    }
                    .font(.title)

                    HStack(spacing: 30) {
                        ForEach(statsRepository.troubleKeys, id: \.self) { key in
                            TimeToTypeRow(key: key, timeToType: statsRepository.averageTimeString(for: key))
                        }
                    }

                    HStack(spacing: 20) {
                        Image(systemName: "clock.badge.checkmark.fill")

                        Text("Recent Games")
                    }
                    .font(.title)
                    .padding(.top, 40)

                    VStack(spacing: 30) {
                        ForEach(statsRepository.sortedRecentRounds.prefix(5), id: \.endDate) { round in
                            RecentGameRow(
                                sceneType: UFOTypingScene.self,
                                timeAgo: statsRepository.timeAgoString(for: round),
                                averageTimeToType: statsRepository.averageTimeString(for: round),
                                troubleKeys: statsRepository.troubleKeys(for: round)
                            )
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 150)
                .padding(.top, 60)
            }
            .padding(.top, 40)
        }
        .toolbar(.hidden)
        .statusBarHidden(true)
    }
}

struct TimeToTypeRow: View {

    let key: EmojiKey
    let timeToType: String

    var body: some View {
        VStack(spacing: 40) {
            Text(key.emoji)
                .font(.system(size: 50))

            VStack(spacing: 4) {
                Text("Average Time")
                    .font(.caption)
                    .fontWeight(.thin)

                Text(timeToType)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cardBackground()
    }
}

struct RecentGameRow: View {

    let sceneType: any TypingScene.Type
    let timeAgo: String
    let averageTimeToType: String
    let troubleKeys: [EmojiKey]

    var body: some View {
        HStack(alignment: .top) {
            Image(sceneType.thumbnail)
                .resizable()
                .frame(width: 100, height: 60)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(sceneType.friendlyName)
                        .font(.title2)

                    Spacer()

                    Text("Avg. Per Emoji:")
                        .font(.headline)
                        .foregroundStyle(Color.secondary)

                    Text(averageTimeToType)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.leading, 4)
                }
                .fontWeight(.medium)

                HStack(alignment: .firstTextBaseline) {
                    Text(timeAgo)
                        .font(.headline)

                    Spacer()

                    Text("Needs More Practice:")
                        .font(.headline)
                        .foregroundStyle(Color.secondary)

                    Text(troubleKeysString)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.leading, 4)
                }
            }
        }
        .padding()
        .cardBackground()
    }

    var troubleKeysString: String {
        troubleKeys.map { $0.emoji }.joined()
    }
}

extension View {
    @ViewBuilder
    func cardBackground() -> some View {
        self
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.charcoalBlue.opacity(0.4), lineWidth: 4)
                        .offset(x: 1, y: 2)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.cardBackground)
                        .stroke(Color.charcoalBlue.opacity(0.2), lineWidth: 1)
                }
            }
    }
}

#Preview {
    StatsView()
}
