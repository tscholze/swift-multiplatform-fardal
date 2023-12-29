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
        let images1: [ImageModel] = [
            .mocked(forImage: .mockPiMicro, withTags: ["Zero", "Rasbperry", "Pi", "Tinkering", "2020"]),
        ]

        let images2: [ImageModel] = [
            .mocked(forImage: .mockPi1, withTags: ["Rasbperry", "Pi", "Tinkering", "2020"]),
        ]

        let customAttributes1: [ItemCustomAttribute] = [
            .mockedDateAttribute,
            .mockedPriceAttribute,
            .mockedLinkAttribute,
            .mockedNoteAttribute,
        ]

        // 2. Make items
        let item1 = ItemModel(
            title: "Raspberry Pi Zero",
            summary: "Low voltage SPC, used for camera"
        )

        item1.imagesData = images1
        item1.customAttributes = customAttributes1

        let item2 = ItemModel(title: "Raspberry Pi 3B", summary: "512 MB Memory")
        item2.imagesData = images2

        // 3. Make collection
        let collection = CollectionModel(
            title: "Raspberry Pis",
            summary: "Container with Pis that date prior 2020"
        )

        let content = InitialAvatarView(name: collection.title, dimension: 256)
        let coverImageData = await ImageGenerator.fromContentToData(content: content)
        collection.coverImageData = .init(data: coverImageData, source: .icon)
        collection.items = [item1, item2]

        // Returned mocked data
        return collection
    }
}
