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
    // MARK: - DB properties -

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
    @Relationship(deleteRule: .cascade)
    var imagesData: [ImageModel]?

    /// List of custom attributes
    var customAttributes: [ItemCustomAttribute]?

    /// Last updated at timestamp
    var updatedAt: Date?

    /// Created timestamp
    let createdAt: Date = Date.now

    // MARK: - Computed properties -

    var numberOfImages: Int {
        return imagesData?.count ?? 0
    }

    var numberOfAttributes: Int {
        return customAttributes?.count ?? 0
    }

    var color: Color? {
        get {
            return if let hexColor {
                .init(hex: hexColor)
            }
            else {
                nil
            }
        }

        set {
            hexColor = newValue?.hexValue
        }
    }

    // MARK: - Init -

    init(
        collection: CollectionModel? = nil,
        title: String,
        summary: String,
        imagesData: [ImageModel] = [],
        customAttributes: [ItemCustomAttribute] = [],
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
        self.imagesData = imagesData
        self.customAttributes = customAttributes
    }
}
