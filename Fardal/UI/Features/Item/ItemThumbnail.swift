//
//  ItemThumbnail.swift
//  Fardal
//
//  Created by Tobias Scholze on 24.12.23.
//

import SwiftUI

/// Thumbnail representation of an `Item`.
struct ItemThumbnail: View {
    // MARK: - Properties -

    /// Item to show
    let item: ItemModel

    /// Square size of the thumbnail
    /// Default value: .medium
    var size: CollectionThumbnailSize = .medium

    /// On tap action
    let action: () -> Void

    // MARK: - UI -

    var body: some View {
        Button { action() } label: {
            if let imageData = item.imagesData?.first {
                imageData.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
            }
            else {
                InitialAvatarView(name: item.title, dimension: size.dimension)
            }
        }
        .clipShape(Theme.Shape.roundedRectangle2)
    }
}

//
// #Preview {
//    ItemThumbnail()
// }
//

/// Available size of a `ItemThumbnail`.
enum ItemThumbnailSize {
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
