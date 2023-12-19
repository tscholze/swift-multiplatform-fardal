//
//  Item.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
//

import SwiftUI
import SwiftData
import Foundation

@Model
final class Item {
    /// Unique id of the item
    @Attribute(.unique)
    var id = UUID()

    /// Human read-able title
    var title: String

    /// Identifiying color
    var hexColor: UInt

    /// Short summary
    var summary: String

    var imageDatas: [ImageData]

    /// List of custom attributes
    var customAttributes: [ItemCustomAttribute]

    /// Last updated at timestamp
    var updatedAt: Date

    /// Created timestamp
    var createdAt: Date = Date.now

    // MARK: - Init -

    init(
        title: String,
        summary: String,
        hexColor: UInt = Color.clear.hexValue,
        imagesData: [ImageData] = [],
        customAttributes: [ItemCustomAttribute] = [],
        updatedAt: Date,
        createdAt: Date = Date.now
    ) {
        self.title = title
        self.summary = summary
        imageDatas = imagesData
        self.customAttributes = customAttributes
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.hexColor = hexColor
    }
}

// MARK: - Mocked -

extension Item {
    /// Gets a static mocked item entry to be used on Previews
    static let mocked: Item = .init(
        title: "Mocked",
        summary: "My Mocked Foo",
        hexColor: Color.orange.hexValue,
        customAttributes: [],
        updatedAt: .now
    )
}

// MARK: - Mocked -

extension Item {
    static let empty: Item = .init(title: "", summary: "", updatedAt: .now)
}
