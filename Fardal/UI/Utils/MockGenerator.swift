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

    /// Defines the context of mocked information
    enum Context {
        // MARK: - Cases -

        /// Eletronical collection with cabels, modules, etc.
        case electronic

        /// Homelab / Raspberry Pis
        case pi

        /// Trading cards
        case tradingcards

        // MARK: - Computed properties -

        /// Gets mocked images for context
        var mockedPhotos: [UIImage] {
            switch self {
            case .electronic:
                return [.mockElectronics1, .mockElectronics2, .mockElectronics3, .mockElectronics4]
            case .pi:
                return [.mockPi1, .mockPiMicro]
            case .tradingcards:
                return [.mockTradingCard1, .mockElectronics2, .mockElectronics3]
            }
        }
    }

    /// Makes a square photo for mocking porpose.
    ///
    /// - Parameter context: Defines the context of the items on the photo
    /// - Returns: `Data` of the mocked image
    static func makeMockSquarePhotoData(
        inContextOf context: Context
    ) -> Data {
        return context.mockedPhotos
            .randomElement()
            .map { $0.toJpegData() }!
    }

    /// Makes a square photos in `Data` representation for mocking porpose.
    ///
    /// - Parameter context: Defines the context of the items on the photo
    /// - Returns: `List<Data>` of the mocked photos.
    static func makeMockSquarePhotosData(
        inContextOf context: Context)
        -> [Data] {
        return context.mockedPhotos
            .map { $0.toJpegData() }
    }

    /// Makes a square image for mocking porpuse
    /// It will create a square image with randomized colors and symbol as content.
    @MainActor static func makeMockSquareSymbol() -> Data {
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
                .foregroundStyle(Color.white.opacity(0.7))
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

extension UIImage {
    fileprivate func toJpegData() -> Data {
        guard let data = jpegData(compressionQuality: 1) else {
            fatalError("Not possible")
        }

        return data
    }
}
