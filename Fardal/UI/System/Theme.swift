//
//  Theme.swift
//  Fardal
//
//  Created by Tobias Scholze on 24.12.23.
//

import SwiftUI

enum Theme {
    enum Colors {
        static let pastelColors: [Color] = [.pastelRed, .pastelBlue, .pastelPink, .pastelBrown, .pastelGreen, .pastelOrange, .pastelPurple, .pastelYellow]
    }

    enum Shape {
        static let roundedRectangle1 = RoundedRectangle(cornerRadius: Theme.cornerRadius1)
        static let roundedRectangle2 = RoundedRectangle(cornerRadius: Theme.cornerRadius2)
    }

    static let cornerRadius1: CGFloat = 8
    static let cornerRadius2: CGFloat = 4
}
