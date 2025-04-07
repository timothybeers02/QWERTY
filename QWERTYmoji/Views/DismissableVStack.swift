//
//  DismissableVStack.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

struct DismissableVStack<Content: View>: View {

    var showMenuBackground: Bool = false
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                content()
            }

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.backward")
                    .foregroundStyle(Color.navigationBlue)
                    .font(.system(size: 65))
                    .padding(.leading, 40)
                    .padding(.top, 150)
            }
        }.menuBackground(if: showMenuBackground)
    }
}

extension View {
    @ViewBuilder
    func menuBackground(if condition: Bool) -> some View {
        if condition {
            self.background {
                Image("homeScreenBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.5)
            }
        } else {
            self
        }
    }
}
