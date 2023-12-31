//
//  TagModel.swift
//  Fardal
//
//  Created by Tobias Scholze on 29.12.23.
//

import SwiftData
import Foundation

@Model final class TagModel {
    // MARK: - Properties -

    /// Unique id of the stored image
    @Attribute(.unique) var id = UUID()

    /// Title of the tag
    var title: String

    /// ML Confidence
    /// 0 = not AI tagged
    var mlConfidence: Double = 0

    /// Timestamp at which the image was initially created
    var createdAt = Date.now

    // MARK: - Init -

    init(title: String, mlConfidence: Double) {
        self.title = title
        self.mlConfidence = mlConfidence
    }

    var imageModel: ImageModel?
}
