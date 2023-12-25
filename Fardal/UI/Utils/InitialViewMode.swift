//
//  InitialViewMode.swift
//  Fardal
//
//  Created by Tobias Scholze on 25.12.23.
//

import Foundation

/// Defines the initial view mode in for CRUD operations
enum ViewInitalState<T> {
    /// Create a new object
    case create

    /// Read-only representation of given object
    case read(T)

    /// Editable representation of given object
    case edit(T)
}
