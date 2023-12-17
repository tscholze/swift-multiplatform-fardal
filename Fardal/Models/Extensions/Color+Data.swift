//
//  Color+Data.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI
import Foundation

extension Color {
    // MARK: - Properties -

    /// Gets a int mask that represents self in hexadecimal.
    var hexValue: UInt {
        // 1. Get color components
        let components = UIColor(self).cgColor.components

        guard let redComponent = components?[0],
              let greenComponent = components?[1],
              let blueComponent = components?[2],
              let alphaComponent = components?[3] else {
            fatalError("Invalid color components found.")
        }

        // Bit shift it into one mask
        let red = UInt(redComponent * 0xFF) << 24
        let green = UInt(greenComponent * 0xFF) << 16
        let blue = UInt(blueComponent * 0xFF) << 8
        let alpha = UInt(alphaComponent * 0xFF)

        // Return mask
        return red | green | blue | alpha
    }

    // MARK: - Init -

    /// Initializes a [Color] instance with given hex value and alpha component.
    ///
    /// - Parameter hex: Hex value that shall be converted to a color
    /// - Parameter alpha: Alpha (Opactiy) value. Default value: 1
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 24) & 0xFF) / 255,
            green: Double((hex >> 16) & 0xFF) / 255,
            blue: Double((hex >> 8) & 0xFF) / 255,
            opacity: alpha
        )
    }
}
