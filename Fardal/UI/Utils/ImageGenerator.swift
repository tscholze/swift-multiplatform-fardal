//
//  ImageGenerator.swift
//  Fardal
//
//  Created by Tobias Scholze on 23.12.23.
//

import SwiftUI
import Foundation

/// Convenient helper for generating images.
enum ImageGenerator {
    /// Creates png data from given view content
    ///
    /// - Parameter content: View that shall be transformed to `Data`
    /// - Returns: Png data representation of given vontent
    @MainActor static func fromContentToData(content: some View) -> Data {
        guard let cgImage = ImageRenderer(content: content).cgImage else {
            fatalError("Error: Could not create CGImage.")
        }

        guard let data = UIImage(cgImage: cgImage).pngData() else {
            fatalError("Error: Could not create data from UIImage from CGImage")
        }

        return data
    }
}
