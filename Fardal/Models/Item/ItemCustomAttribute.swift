//
//  ItemCustomAttribute.swift
//  Fardal
//
//  Created by Tobias Scholze on 11.12.23.
//

import Foundation
import SwiftData

@Model
class ItemCustomAttribute {
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
    internal init(layout: String, payload: [String : String]) {
        self.layout = layout
        self.payload = payload
    }
}

// MARK: - Empty / Init states -

extension ItemCustomAttribute {
    /// Gets an empty (initial) empty price attribute.
    static var emptyPriceAttribute: ItemCustomAttribute = .init(
        layout: "price",
        payload: ["title": "Price", "currencyCode":"EUR", "price":"00.00"]
    )
}

// MARK: - Mock -

extension ItemCustomAttribute {
    /// Mocked `ItemCustomAttribute` representing a price
    static var mockedPriceAttribute: ItemCustomAttribute = .init(
        layout: "price", 
        payload: ["title": "Bought for", "currencyCode":"EUR", "price":"20.00"]
    )
}
