//
//  ItemDraft.swift
//  Fardal
//
//  Created by Tobias Scholze on 17.12.23.
//

import Foundation
import SwiftUI

/// Represents a editable non database model for
/// an `Item`.
///
/// Use static helper to create an empty or prefilled draft.
final class ItemDraft: ObservableObject {
    // MARK: - Properties -

    /// Unique id of the drafting item
    let existingId: UUID?

    /// Human read-able title
    var title: String {
        didSet { validate() }
    }

    /// Identifiying color
    var hexColor: UInt

    /// Tags
    var tags: [String]

    /// Short summary
    var summary: String

    /// Image assets
    var imagesData: [ImageData]

    /// List of custom attributes
    var customAttributes: [ItemCustomAttribute]

    var isValid = false

    // MARK: - Init -

    init(
        existingId: UUID?,
        title: String,
        summary: String,
        hexColor: UInt,
        tags: [String],
        imagesData: [ImageData],
        customAttributes: [ItemCustomAttribute]
    ) {
        self.existingId = existingId
        self.title = title
        self.summary = summary
        self.imagesData = imagesData
        self.customAttributes = customAttributes
        self.hexColor = hexColor
        self.tags = tags
    }

    private func validate() {
        if title.isEmpty {
            isValid = false
        }
        else {
            isValid = true
        }
    }
}

// MARK: - Factories -

extension ItemDraft {
    /// Creates a new and empty draft.
    /// Shall be used for `create`wizard of an item.
    ///
    /// - Returns: Empty draft.
    static func new() -> ItemDraft {
        return .init(
            existingId: nil,
            title: "",
            summary: "",
            hexColor: Color.clear.hexValue,
            tags: [],
            imagesData: [],
            customAttributes: []
        )
    }

    /// Creates a new draft from given item.
    ///
    /// - Parameter item: Underlying item. Used for edit an item but with cancel option
    /// - Returns: Created item draft.
    static func from(item: ItemModel) -> ItemDraft {
        return .init(
            existingId: item.id,
            title: item.title,
            summary: item.summary,
            hexColor: item.hexColor,
            tags: item.tags,
            imagesData: item.imagesData,
            customAttributes: item.customAttributes
        )
    }
}
