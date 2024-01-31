//
//  CollectionThumbnail.swift
//  Fardal
//
//  Created by Tobias Scholze on 24.12.23.
//

import SwiftUI

/// Thumbnail representation of a `CollectionModel`.
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
            collection.coverImage
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

    // MARK: - Computed properties -

    /// Square dimension
    var dimension: CGFloat {
        switch self {
        case .medium: return 60
        case .large: return 80
        }
    }
}

// MARK: - Preview -

#Preview {
    struct AsyncTestView: View {
        @State var collection: CollectionModel? = nil

        var body: some View {
            Group {
                if let collection {
                    CollectionThumbnail(collection: collection, action: {})
                }
            }
            .task {
                collection = await CollectionModel.makeMockedCollections()
            }
        }
    }

    return AsyncTestView()
}
