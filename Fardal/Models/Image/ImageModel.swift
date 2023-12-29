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

    /// Parent
    var item: ItemModel?

    /// Source of the image.
    /// E.g. icon or photo
    var source: ImageModelSource

    /// List of tags that describes the content of the image
    @Relationship(deleteRule: .cascade)
    var tags: [TagModel]

    /// Timestamp at which the image was initially created
    let createdAt = Date.now

    // MARK: - Init -

    /// Initnalizes a new image model with given data.
    ///
    /// - Parameters:
    ///   - data: Data representation of the image
    ///   - item: Parent `ItemModel`
    ///   - source: Source type of the image (photo, icon, etc.)
    ///   - tags: List of tags that describes the content of the image
    init(data: Data, source: ImageModelSource = .photo, item: ItemModel? = nil, tags: [TagModel] = []) {
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
    /// Returns new randomized and mocked `ImageModel` in given content.
    ///
    /// - Parameter context: Informal context of the mocked image
    /// - Returns: Mocked model
    static func makeMockedPhoto(inContextOf context: MockGenerator.Context) -> ImageModel {
        return .init(
            data: MockGenerator.makeMockSquareRandomizedPhotoData(inContextOf: context),
            source: .photo
        )
    }

    /// Returns new  mocked `ImageModel` for givin original image
    ///
    /// - Parameter image: Original image on which the model shall be created
    /// - Parameter tags: List of string-based tags. Defaulr value: empty list
    /// - Returns: Mocked model
    static func mocked(forImage image: UIImage, withTags tags: [String] = []) -> ImageModel {
        guard let data = image.jpegData(compressionQuality: 1) else {
            fatalError("Failed to convert data to jpeg data.")
        }
        
        let tagModels = tags.map { tag in
            TagModel(title: tag, mlConfidence: Double.random(in: 0.01...0.99))
        }.sorted(by: { $0.mlConfidence > $1.mlConfidence })

        return .init(data: data, source: .photo, tags: tagModels)
    }

    /// Returns list of new  mocked `ImageModel` in context of Raspberry Pi
    ///
    /// - Returns: List if mocked models
    static func mockedRaspberryPisPhotos() -> [ImageModel] {
        MockGenerator.makeMockSquarePhotosData(inContextOf: .pi)
            .map { .init(data: $0, source: .photo, item: nil, tags: [.init(title: "Raspberry", mlConfidence: 0.45), .init(title: "Pi", mlConfidence: 0.12)]) }
    }

    /// Returns list of new  mocked `ImageModel` in context of electronics
    ///
    /// - Returns: List if mocked models
    static func mockedElectronicPhotos() -> [ImageModel] {
        MockGenerator.makeMockSquarePhotosData(inContextOf: .electronic)
            .map { .init(data: $0, source: .photo, item: nil, tags: [.init(title: "Mocked", mlConfidence: 0.87), .init(title: "Electric", mlConfidence: 0.74)]) }
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
