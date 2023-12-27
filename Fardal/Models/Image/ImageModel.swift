//
//  ImageModel.swift
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
@Model final class ImageModel {
    // MARK: - Properties -

    /// Unique id of the stored image
    @Attribute(.unique) var id = UUID()

    /// [Data] representation of the image
    var data: Data

    var item: ItemModel?

    /// Source of the image.
    /// E.g. icon or photo
    var source: ImageModelSource

    /// List of tags that describes the content of the image
    var tags: [String]

    /// Timestamp at which the image was initially created
    let createdAt = Date.now

    // MARK: - Init -

    /// Initnalizes a new image model with given data.
    ///
    /// - Parameters:
    ///   - data: Data representation of the image
    ///   - source: Source type of the image (photo, icon, etc.)
    ///   - tags: List of tags that describes the content of the image
    init(data: Data, source: ImageModelSource = .photo, item: ItemModel? = nil, tags: [String] = []) {
        self.data = data
        self.item = item
        self.source = source
        self.tags = tags
    }
}

// MARK: - Computed properties -

extension ImageModel {
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

extension ImageModel: Equatable {
    public static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Mock -

extension ImageModel {
    static var mockedPhoto: ImageModel = .init(
        data: MockGenerator.makeMockSquarePhotoData(inContextOf: .tradingcards),
        source: .photo
    )

    static func mocked(forImage image: UIImage) -> ImageModel {
        guard let data = image.jpegData(compressionQuality: 1) else {
            fatalError("Failed to convert data to jpeg data.")
        }

        return .init(data: data, source: .photo)
    }

    static func mockedRaspberryPisPhotos() -> [ImageModel] {
        MockGenerator.makeMockSquarePhotosData(inContextOf: .pi)
            .map { .init(data: $0, source: .photo, item: nil, tags: ["Raspberry", "Pi"]) }
    }

    static func mockedElectronicPhotos() -> [ImageModel] {
        MockGenerator.makeMockSquarePhotosData(inContextOf: .electronic)
            .map { .init(data: $0, source: .photo, item: nil, tags: ["Mocked", "Image"]) }
    }
}

// MARK: - ImageModelSource-

/// Origin source of an `ImageModel`
enum ImageModelSource: String, Codable {
    /// Icon, Symbol or other non photographical images
    case icon

    /// Photo taken by a camera
    case photo
}
