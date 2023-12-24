//
//  ChipModel.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import Foundation

/// Model representation of a `Chip`
struct ChipModel: Identifiable, Equatable {
    /// Unique id
    let id = UUID()

    /// Human-readable title
    let title: String
}
