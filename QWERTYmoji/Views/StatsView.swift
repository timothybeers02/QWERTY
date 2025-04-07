//
//  StatsView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

struct StatsView: View {
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

                    // TODO: TB - ForEach ttt row
                    placeholderPracticeRow

                    HStack(spacing: 20) {
                        Image(systemName: "clock.badge.checkmark.fill")

                        Text("Recent Games")
                    }
                    .font(.title)
                    .padding(.top, 40)

                    // TODO: TB - ForEach recent game (up to 3-5)
                    placeholderRecentGamesRow

                    Spacer()
                }
                .padding(.horizontal, 150)
                .padding(.top, 60)
            }
            .padding(.top, 40)
        }
        .toolbar(.hidden)
    }

    var placeholderPracticeRow: some View {
        HStack(spacing: 30) {
            TimeToTypeRow(key: .testKeyOne, timeToType: "4.9s")

            TimeToTypeRow(key: .testKeyTwo, timeToType: "2.7s")

            TimeToTypeRow(key: .testKeyThree, timeToType: "2.3s")

            TimeToTypeRow(key: .testKeyFive, timeToType: "2.2s")
        }
    }

    var placeholderRecentGamesRow: some View {
        VStack(spacing: 30) {
            RecentGameRow(sceneType: UFOTypingScene.self, timeAgo: "1m ago", averageTimeToType: "1.7s", troubleKeys: [.testKeyFour, .testKeyOne])

            RecentGameRow(sceneType: UFOTypingScene.self, timeAgo: "7m ago", averageTimeToType: "2.3s", troubleKeys: [.testKeyOne, .testKeyFive])

            RecentGameRow(sceneType: UFOTypingScene.self, timeAgo: "1h ago", averageTimeToType: "2.1s", troubleKeys: [.testKeyThree, .testKeyTwo])
        }
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

                    Text("ATTT: \(averageTimeToType)")
                        .font(.headline)
                }
                .fontWeight(.medium)

                HStack(alignment: .firstTextBaseline) {
                    Text(timeAgo)
                        .font(.headline)

                    Spacer()

                    Text("NMPO: \(troubleKeysString)")
                        .font(.headline)
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
                        .fill(.white)
                        .stroke(Color.charcoalBlue.opacity(0.2), lineWidth: 1)
                }
            }
    }
}

#Preview {
    StatsView()
}
