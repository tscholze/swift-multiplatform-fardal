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
