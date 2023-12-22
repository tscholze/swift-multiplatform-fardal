//
//  ItemDetailViewInitalState.swift
//  Fardal
//
//  Created by Tobias Scholze on 21.12.23.
//

import Foundation

/// Defines all states the `ItemDetailView` could have
enum ItemDetailViewInitalState {
    /// Create a new item
    case create

    /// Read-only representation of given `Item`
    case read(ItemModel)

    /// Editable representation of given `Item`
    case edit(ItemModel)
}
