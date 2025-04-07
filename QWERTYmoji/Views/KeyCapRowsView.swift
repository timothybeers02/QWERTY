//
//  KeyCapRowsView.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 4/6/25.
//

import SwiftUI

struct KeyCapRowsView: View {
    var rows: [[String]]
    var withTopPadding: Bool = true

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 4) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { letterIndex in
                        KeycapText(rows[rowIndex][letterIndex])
                    }
                }
            }
        }
        .scaleEffect(1.5) // TODO: TB - Update fonts and stuff instead
        .padding(.top, withTopPadding ? 150 : 0)
    }
}
