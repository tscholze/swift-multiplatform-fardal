//
//  ItemCustomAttribute.swift
//  Fardal
//
//  Created by Tobias Scholze on 11.12.23.
//

import SwiftUI
import SwiftData
import Foundation

/// Defines the type of an `ItemCustomAttribute`.|
enum ItemCustomAttributeType: String {
    // MARK: - Cases -

    /// Date information
    case date

    /// Pricining and currency information
    case price

    /// External url
    case url

    /// Multiline note
    case note

    // MARK: - Generators -

    /// Makes a vierw for self with given content and mode.
    ///
    /// - Parameters:
    ///   - attribute: Generic content of the type
    ///   - mode: Initial view mode in which the view shall be rendered
    /// - Returns: Created view for self.
    func makeView(
        for attribute: ItemCustomAttribute,
        with mode: ViewMode
    ) -> some View {
        Group {
            switch self {
            case .date:
                DateCustomAttributeView(mode: mode, store: .init(attribute: attribute))
            case .price:
                PriceCustomAttributeView(mode: mode, store: .init(attribute: attribute))
            case .url:
                UrlCustomAttributeView(mode: mode, store: .init(attribute: attribute))
            case .note:
                NoteCustomAttributeView(mode: mode, store: .init(attribute: attribute))
            }
        }
    }
}

/// Model data class of an `Item` custom attribute.
@Model class ItemCustomAttribute {
    // MARK: - Properties -

    /// Unique id of the attribute
    @Attribute(.unique)
    var id = UUID()

    /// Defines the resulted layout of the attribute.
    /// E.g.: "price"
    var layout: String

    /// Contains the dynamic payload of attribute.
    var payload: [String: String]

    // MARK: - Init -

    /// Initializes a new model for a custom attribute.
    /// An `id` will be automatically generated to be unique.
    ///
    /// - Parameter layout:Defines the resulted layout of the attribute.
    /// - Parameter payload:Contains the dynamic payload of attribute.
    init(layout: String, payload: [String: String]) {
        self.layout = layout
        self.payload = payload
    }
}

// MARK: - Empty / Init states -

extension ItemCustomAttribute {
    /// Gets an empty (initial) empty price attribute.
    static var emptyPriceAttribute: ItemCustomAttribute = .init(
        layout: "price",
        payload: ["title": "Price", "currencyCode": "EUR", "price": "00.00"]
    )

    /// Gets an empty (initial) empty date attribute.
    static var emptyDateAttribute: ItemCustomAttribute = .init(
        layout: "date",
        payload: ["title": "Date", "date": Date.now.formatted(.dateTime)]
    )

    /// Gets an empty (initial) empty url attribute.
    static var emptyUrlAttribute: ItemCustomAttribute = .init(
        layout: "url",
        payload: ["title": "Homepage", "url": ""]
    )

    /// Gets an empty (initial) empty note attribute.
    static var emptyNoteAttribute: ItemCustomAttribute = .init(
        layout: "note",
        payload: ["title": "Note", "text": ""]
    )
}

// MARK: - Mock -

extension ItemCustomAttribute {
    /// Mocked `ItemCustomAttribute` representing a price and currency
    static var mockedPriceAttribute: ItemCustomAttribute = .init(
        layout: "price",
        payload: ["title": "Bought for", "currencyCode": "EUR", "price": "20.00"]
    )

    /// Mocked `ItemCustomAttribute` representing a `Date`
    static var mockedDateAttribute: ItemCustomAttribute = .init(
        layout: "date",
        payload: ["title": "Bought at", "date": Date.now.formatted(.dateTime)]
    )

    /// Mocked `ItemCustomAttribute` representing an `URL`.
    static var mockedLinkAttribute: ItemCustomAttribute = .init(
        layout: "url",
        payload: ["title": "Homepage", "url": "https://tscholze.github.io"]
    )

    /// Mocked `ItemCustomAttribute` representing a note
    static var mockedNoteAttribute: ItemCustomAttribute = .init(
        layout: "note",
        payload: ["title": "Keep in mind", "text": "Always use Fardal!"]
    )
}
