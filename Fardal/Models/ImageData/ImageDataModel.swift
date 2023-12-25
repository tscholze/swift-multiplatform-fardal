//
//  ImageDataModel.swift
//  Fardal
//
//  Created by Tobias Scholze on 25.12.23.
//

import UIKit
import SwiftUI
import SwiftData
import Foundation

/// Model representation of an image.
///
/// Access the `data`, `image` or `uiImage` to have access to
/// the image.
///
/// Use the .init(data: data) intializer to create a new model
/// instance.
@Model final class ImageDataModel {
    // MARK: - Properties -

    /// Unique id of the stored image
    @Attribute(.unique) let id = UUID()

    /// [Data] representation of the image
    let data: Data

    /// Source of the image.
    /// E.g. icon or photo
    let source: ImageDataModelSource

    /// List of tags that describes the content of the image
    let tags: [String]

    /// Timestamp at which the image was initially created
    let createdAt = Date.now

    // MARK: - Init -

    /// Initnalizes a new image model with given data.
    ///
    /// - Parameters:
    ///   - data: Data representation of the image
    ///   - source: Source type of the image (photo, icon, etc.)
    ///   - tags: List of tags that describes the content of the image
    init(data: Data, source: ImageDataModelSource = .photo, tags: [String] = []) {
        self.data = data
        self.source = source
        self.tags = tags
    }
}

// MARK: - Computed properties -

extension ImageDataModel {
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
}

// MARK: - Equatable -

extension ImageDataModel: Equatable {
    public static func == (lhs: ImageDataModel, rhs: ImageDataModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Mock -

extension ImageDataModel {
    static var mockedPhoto: ImageDataModel = .init(
        data: MockGenerator.makeMockSquarePhotoData(inContextOf: .tradingcards),
        source: .photo
    )

    static var mockedElectronicPhotos: [ImageDataModel] {
        MockGenerator.makeMockSquarePhotosData(inContextOf: .electronic)
            .map { .init(data: $0, source: .photo, tags: ["Mocked", "Image"]) }
    }
}

// MARK: - ImageDataModelSource-

/// Origin source of an `ImageDataModel`
enum ImageDataModelSource: String, Codable {
    /// Icon, Symbol or other non photographical images
    case icon

    /// Photo taken by a camera
    case photo
}
