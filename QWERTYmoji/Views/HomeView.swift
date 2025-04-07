//
//  HomeView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/5/25.
//

import SwiftUI

enum Destination: Hashable {
    case play
    case gameStart
    case stats
    case settings
    case keyboardSizer
}

struct HomeView: View {

    @State private var path: [Destination] = []
    @State var keyboardObserver = KeyboardObserver()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 40) {
                // Title
                KeyCapRowsView(rows: [
                    "QWERTY".map { String($0) },
                    "m😮ji".map { String($0) }
                ])

                Spacer()

                // Buttons
                VStack(spacing: 40) {
                    MainContentButton(title: "PLAY", systemImage: "play.fill", color: .customCyan, iconOffset: -3) {
                        path.append(.play)
                    }
                    MainContentButton(title: "STATS", systemImage: "chart.bar.fill", color: .customTeal, iconOffset: 5) {
                        path.append(.stats)
                    }
                    MainContentButton(title: "SETTINGS", systemImage: "gearshape.fill", color: .customRose) {
                        path.append(.settings)
                    }
                }
                .padding(.bottom, 150)
                .padding(.horizontal, 210)
            }
            .navigationDestination(for: Destination.self) { route in
                switch route {
                case .play:
                    GameSelectView(path: $path)
                        .environment(\.keyboardObserver, keyboardObserver)
                case .gameStart:
                    GameView(path: $path)
                        .environment(\.keyboardObserver, keyboardObserver)
                case .stats:
                    StatsView()
                        .environment(\.keyboardObserver, keyboardObserver)
                case .settings:
                    SettingsView(path: $path)
                        .environment(\.keyboardObserver, keyboardObserver)
                case .keyboardSizer:
                    KeyboardSizingView()
                        .environment(\.keyboardObserver, keyboardObserver)
                }
            }
            .padding()
            .background {
                Image("homeScreenBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.5)
            }
//            .environment(\.keyboardObserver, keyboardObserver)
        }
    }
}

// MARK: - Reusable Components
struct KeycapText: View {

    init(_ letter: String) {
        self.letter = letter
    }

    let letter: String
    // TODO: adjust font for top and bottom row

    var body: some View {
        Text(letter)
            .foregroundStyle(Color.tileOutline)
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(width: 60, height: 62.5)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .stroke(Color.charcoalBlue.opacity(0.2), lineWidth: 4)

                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.charcoalBlue.opacity(0.4), lineWidth: 4)
                        .offset(x: -1, y: -2)
                }
            }
            .cornerRadius(6)
    }
}

struct MainContentButton: View {
    let title: String
    let systemImage: String
    let color: Color
    var iconOffset: CGFloat = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 24) {

                Text(title)
                    .font(.title)
                    .kerning(1.1)
                    .fontWeight(.bold)
                    .scaleEffect(1.1)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: systemImage)
                    .font(.title)
                    .offset(x: iconOffset)
            }
            .padding(.horizontal, 50)
        }
        .buttonStyle(Pressed3DButtonStyle(color: color))
    }
}

struct Pressed3DButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.charcoalBlue)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .brightness(configuration.isPressed ? -0.3 : -0.2)
                        .offset(x: configuration.isPressed ? -0.5 : 2.5,
                                y: configuration.isPressed ? -1 : 5)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .brightness(configuration.isPressed ? -0.025 : 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: configuration.isPressed ? [Color.clear, Color.white.opacity(0.1)] : [Color.white.opacity(0.2), Color.clear]),
                                        startPoint: configuration.isPressed ? .center : .top,
                                        endPoint: configuration.isPressed ? .bottom : .center
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                }
            )
    }
}

extension EnvironmentValues {
    @Entry var keyboardObserver = KeyboardObserver()
}

#Preview {
    HomeView()
}
