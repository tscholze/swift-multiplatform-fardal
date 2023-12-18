//
//  MockGenerator.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import Foundation
import SwiftUI
import SFSafeSymbols

struct MockGenerator {
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
    
    // MARK: - Internal properties -
    
    private let availableColors: [Color] = [.red, .gray, .green, .yellow, .blue, .purple, .orange, .mint, .indigo, .cyan]
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(makeRandomColor())
            
            Image(systemName: makeRandomSymbolName())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(makeRandomColor())
                .padding()
                .frame(width: dimension * 0.90)
        }
        .frame(width: dimension, height: dimension)
    }
    
    private func makeRandomColor() -> Color {
        availableColors.randomElement() ?? .cyan
    }
    
    private func makeRandomSymbolName() -> String {
        SFSymbol.allSymbols.randomElement()?.rawValue ?? SFSymbol.questionmark.rawValue
    }
    
}

