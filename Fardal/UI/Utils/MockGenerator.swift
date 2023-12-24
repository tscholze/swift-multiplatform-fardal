//
//  MockGenerator.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import SwiftUI
import Foundation
import SFSafeSymbols

/// Convenient helper for mocking content.
enum MockGenerator {
    // MARK: - Images -

    /// Makes a square image for mocking porpuse
    /// It will create a square image with randomized colors and symbol as content.
    @MainActor static func makeMockSquareImageData() -> Data {
        let content = SquareTemplate()
        return ImageGenerator.fromContentToData(content: content)
    }
}

// MARK: - Private views -

private struct SquareTemplate: View {
    // MARK: - Properties -

    let dimension: CGFloat = 256

    // MARK: - UI -

    var body: some View {
        ZStack(alignment: .center) {
            Theme.Shape.roundedRectangle2
                .foregroundStyle(makeRandomColor())

            Image(systemName: makeRandomSymbolName())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.black.opacity(0.6))
                .padding()
                .frame(width: dimension * 0.90)
        }
        .frame(width: dimension, height: dimension)
    }

    private func makeRandomColor() -> Color {
        Theme.Colors.pastelColors.randomElement() ?? .cyan
    }

    private func makeRandomSymbolName() -> String {
        SFSymbol.allSymbols.randomElement()?.rawValue ?? SFSymbol.questionmark.rawValue
    }
}
