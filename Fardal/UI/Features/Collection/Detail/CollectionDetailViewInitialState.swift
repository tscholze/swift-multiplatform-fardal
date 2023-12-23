//
//  CollectionDetailViewInitialState.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import Foundation

import Foundation

/// Defines all states the `CollectionDetailView` could have
enum CollectionDetailViewInitalState {
    /// Create a new collection
    case create

    /// Read-only representation of given `CollectionModel`
    case read(CollectionModel)

    /// Editable representation of given `CollectionModel`
    case edit(CollectionModel)
}
