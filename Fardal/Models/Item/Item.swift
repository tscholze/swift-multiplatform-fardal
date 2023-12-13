//
//  Item.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
//

import Foundation
import SwiftData
import SwiftUI

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
    
    /// List of custom attributes
    var customAttributes: [ItemCustomAttribute]
    
    /// Last updated at timestamp
    var updatedAt: Date
    
    /// Created timestamp
    var createdAt: Date = Date.now
    
    // MARK: - Init -
    
    internal init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        color: Color = Color.clear,
        customAttributes: [ItemCustomAttribute] = [],
        updatedAt: Date,
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.hexColor = color.hexValue
        self.customAttributes = customAttributes
        
        print(self.hexColor)
    }
}

// MARK: - Mocked -

extension Item {
    /// Gets a static mocked item entry to be used on Previews
    static let mocked: Item = .init(
        title: "Mocked",
        summary: "My Mocked Foo",
        color: .orange,
        customAttributes: [.mockedDateAttribute, .mockedPriceAttribute, .mockedLinkAttribute],
        updatedAt: .now
    )
}
