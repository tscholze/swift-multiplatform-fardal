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
    var coverImageData: ImageData

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
        coverImageData: ImageData,
        title: String,
        summary: String,
        items: [ItemModel]
    ) {
        self.coverImageData = coverImageData
        self.title = title
        self.summary = summary
        self.items = items
    }
}

// MARK: - Asset generators -

import UIKit
extension CollectionModel {
    static func makeSystemCoverImageData() -> ImageData {
        guard let data = UIImage(named: "AppLogiLarge")?.pngData() else {
            fatalError("Internal data generation failure")
        }

        return .init(data: data)
    }
}
