//
//  SelectableColor.swift
//  Fardal
//
//  Created by Tobias Scholze on 27.12.23.
//

import SwiftUI

/// Describes an identifiable `Color`
struct SelectableColor: Identifiable {
    /// Unique id
    let id = UUID()

    /// Color payload
    let color: Color
}
