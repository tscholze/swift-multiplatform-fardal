//
//  ItemModel.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
//

import SwiftUI
import SwiftData
import Foundation

@Model
final class ItemModel {
    /// Unique id of the item
    @Attribute(.unique)
    let id: UUID

    /// Parent collection
    @Relationship(inverse: \CollectionModel.items)
    var collection: CollectionModel?

    /// Human read-able title
    var title: String

    /// Identifiying color
    var hexColor: UInt?

    /// List of tags for the item
    var tags: [String]

    /// Short summary
    var summary: String

    /// List of data objects that represents attached images.
    /// Could be photos or icons.
    //  @Relationship(deleteRule: .cascade)
    var imagesData: [ImageModel]?

    /// List of custom attributes
    //  @Relationship(deleteRule: .cascade)
    var customAttributes: [ItemCustomAttribute]?

    /// Last updated at timestamp
    var updatedAt: Date?

    /// Created timestamp
    let createdAt: Date = Date.now

    // MARK: - Init -

    init(
        collection: CollectionModel? = nil,
        title: String,
        summary: String,
        hexColor: UInt? = nil,
        tags: [String] = [],
        updatedAt: Date? = nil,
        createdAt: Date = Date.now
    ) {
        id = UUID()
        self.collection = collection
        self.title = title
        self.summary = summary
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.hexColor = hexColor
        self.tags = tags
        imagesData = []
        customAttributes = []
    }
}

// MARK: - Mocked -

extension ItemModel {
    /// Gets a static mocked item entry to be used on Previews
    static func makeMockedItem(with context: ModelContext) -> ItemModel {
        let item = ItemModel(title: "Mocked", summary: "Mocked", updatedAt: .now)
        context.insert(item)

        item.imagesData = [] // <-- Crash

        return item
    }
}
