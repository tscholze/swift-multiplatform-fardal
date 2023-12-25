//
//  Theme.swift
//  Fardal
//
//  Created by Tobias Scholze on 24.12.23.
//

import SwiftUI

/// App-wide theming proeprties
enum Theme {
    /// Convinient helper to access colors
    /// Use default `Image(:resources)` if a simple color access is required
    enum Colors {
        static let pastelColors: [Color] = [.pastelRed, .pastelBlue, .pastelPink, .pastelBrown, .pastelGreen, .pastelOrange, .pastelPurple, .pastelYellow]
    }

    /// Unified spacings
    enum Spacing {
        /// No spacing
        static let none: CGFloat = 0

        /// Tiny spacing
        static let tiny: CGFloat = 4

        /// Small spacing
        static let small: CGFloat = 8

        /// Medium  spacing
        static let medium: CGFloat = 12

        /// Large spacing
        static let large: CGFloat = 24
    }

    /// Unified shapes
    enum Shape {
        /// Level 1 rounded rectangle
        static let roundedRectangle1 = RoundedRectangle(cornerRadius: Theme.cornerRadius1)

        /// Level 2 rounded rectangle. Use it if parent has `roundedRectangle1`
        static let roundedRectangle2 = RoundedRectangle(cornerRadius: Theme.cornerRadius2)
    }

    // MARK: - Private properties -

    static let cornerRadius1: CGFloat = 8
    static let cornerRadius2: CGFloat = 4
}

extension [Color] {
    /// Gets a random color
    /// If `self` does not contain any color, it
    /// fallsback to `.cyan`.
    var random: Color {
        self.randomElement() ?? .cyan
    }
}
