//
//  MockGenerator.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import SwiftUI
import Foundation
import SFSafeSymbols

enum MockGenerator {
    @MainActor static func makeMockSquareImageData() -> Data {
        let content = SquareTemplate()
        guard let cgImage = ImageRenderer(content: content).cgImage else {
            fatalError("Error: Could not create CGImage.")
        }

        guard let data = UIImage(cgImage: cgImage).pngData() else {
            fatalError("Error: Could not create data from UIImage from CGImage")
        }

        return data
    }
}

private struct SquareTemplate: View {
    // MARK: - Properties -

    let dimension: CGFloat = 256

    // MARK: - UI -

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 4)
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
        AppColors.pastelColors.randomElement() ?? .cyan
    }

    private func makeRandomSymbolName() -> String {
        SFSymbol.allSymbols.randomElement()?.rawValue ?? SFSymbol.questionmark.rawValue
    }
}
