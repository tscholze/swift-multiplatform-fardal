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
    var coverImageData: ImageDataModel

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
        coverImageData: ImageDataModel,
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

// MARK: - Mock -

extension CollectionModel {
    static func makeMockedCollections() async -> [CollectionModel] {
        
        let title = "Electronic Building materials"
        let summary = "A set of modules to build other stuff"
        let data = await ImageGenerator.fromContentToData(content: InitialAvatarView(name: title, dimension: 256))
        
        return [
            .init(
                coverImageData: .init(data: data, source: .collection),
                title: title,
                summary: summary,
                items: [.mocked]
            ),
        ]
    }
}
