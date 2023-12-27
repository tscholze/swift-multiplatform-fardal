//
//  CollectionModel.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import SwiftData
import Foundation

@Model final class CollectionModel {
    // MARK: - Properties -

    /// Unique id of the item
    @Attribute(.unique)
    var id = UUID()

    /// Cover image as data
    @Relationship(deleteRule: .cascade)
    var coverImageData: ImageModel?

    /// Human read-able title
    var title: String

    /// Human read-able summary
    var summary: String

    /// List of attached items of the collection
    var items: [ItemModel]

    /// Timestamp at which the image was initially created
    let createdAt = Date.now

    // MARK: - Init -

    init(
        coverImageData: ImageModel? = nil,
        title: String,
        summary: String,
        items: [ItemModel] = []
    ) {
        self.coverImageData = coverImageData
        self.title = title
        self.summary = summary
        self.items = items
    }
}

// MARK: - Mock -

extension CollectionModel {
    static func makeMockedCollections() async -> CollectionModel {
        // 1. Make images
        let images = [ImageModel.mocked(forImage: .mockPiMicro)]

        // 2. Make items
        let item = ItemModel(
            title: "Raspberry Pi Zero",
            summary: "Low voltage SPC, used for camera"
        )

        item.imagesData = images

        // 3. Make collection
        let collection = CollectionModel(
            title: "Raspberry Pis < 2020",
            summary: "Container with Pis that date prior 2020"
        )

        let coverImageData = await ImageGenerator.fromContentToData(content: InitialAvatarView(name: "RPis", dimension: 256))
        collection.coverImageData = .init(data: coverImageData, source: .icon)
        collection.items = [item]

        // Returned mocked data
        return collection
    }
}
