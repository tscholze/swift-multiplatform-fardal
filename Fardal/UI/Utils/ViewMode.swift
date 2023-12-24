//
//  ViewMode.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import Foundation

/// Describes the mode in which the view currently is
/// Mostly used in CRUD-related context
enum ViewMode {
    /// Read only
    case read

    /// Create an element
    case create

    /// Edit an element
    case edit
}
