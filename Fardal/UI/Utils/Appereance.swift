//
//  Appereance.swift
//  Fardal
//
//  Created by Tobias Scholze on 15.12.23.
//

import SwiftUI

/// List of all available app appereances.
enum Appereance: Int {
    // MARK: - Values -

    /// The system's appereance should be used.
    case system

    /// The light appereance should be used.
    case light

    /// The dark appereance should be used.
    case dark

    // MARK: - Internal properties -

    /// Gets the scheme for appereance item.
    var scheme: ColorScheme? {
        switch self {
        case .system: return .none
        case .light: return .light
        case .dark: return .dark
        }
    }
}
