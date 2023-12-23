//
//  ImageData.swift
//  Fardal
//
//  Created by Tobias Scholze on 15.12.23.
//

import UIKit
import SwiftUI
import SwiftData
import Foundation

/// Model representation of an image.
///
/// Access the `data` or `uiImage` to have access to
/// the image.
///
/// Use the .init(data: data) intializer to create a new model
/// instance.
@Model final class ImageData {
    // MARK: - Properties -

    /// Unique id of the stored image
    @Attribute(.unique) let id = UUID()

    /// [Data] representation of the image
    var data: Data

    /// Timestamp at which the image was initially created
    let createdAt = Date.now

    // MARK: - Computed properties -

    /// Calculated `UIImage` from given data.
    var uiImage: UIImage {
        guard let image = UIImage(data: data) else {
            fatalError("Corrupt image")
        }

        return image
    }

    /// Calculated `SwiftUI.Image` from given `uiImage`.
    var image: Image {
        .init(uiImage: uiImage)
    }

    // MARK: - Init -

    /// Initnalizes a new image model with given data.
    ///
    /// - Parameter: Data of the image that shall be stored.
    init(data: Data) {
        self.data = data
    }
}

// MARK: - Equatable -

extension ImageData: Equatable {
    public static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        return lhs.id == rhs.id
    }
}
