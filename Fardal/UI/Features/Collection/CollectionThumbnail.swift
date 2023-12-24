//
//  CollectionThumbnail.swift
//  Fardal
//
//  Created by Tobias Scholze on 24.12.23.
//

import SwiftUI

/// Thumbnail representation of a `CollectionModel`
struct CollectionThumbnail: View {
    // MARK: - Properties -

    /// Collection to show
    let collection: CollectionModel

    /// Square size of the thumbnail
    /// Default value: .medium
    var size: CollectionThumbnailSize = .medium

    /// On tap action block
    let action: () -> Void

    // MARK: - UI -

    var body: some View {
        Button { action() } label: {
            collection.coverImageData.image
                .resizable()
                .scaledToFill()
                .clipShape(Theme.Shape.roundedRectangle2)
                .frame(width: size.dimension, height: size.dimension)
        }
    }
}

/// Available size of a `CollectionThumbnail`.
enum CollectionThumbnailSize {
    // MARK: - Values -

    /// Medium
    case medium

    /// Large
    case large

    // MARK: - computed properties -

    /// Square dimension
    var dimension: CGFloat {
        switch self {
        case .medium: return 60
        case .large: return 80
        }
    }
}

// TODO: Create Collection mock
// #Preview {
// CollectionThumbnail(collection: , action: () -> Void)
// }
