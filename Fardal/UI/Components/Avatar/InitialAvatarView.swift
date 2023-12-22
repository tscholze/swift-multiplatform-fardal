//
//  InitialAvatarView.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import SwiftUI

/// Creates an initial avatar view based on given name.
/// It will split it by spaces and join it together.
///
/// It uses randomized Colors to create the background.
struct InitialAvatarView: View {
    // MARK: - Properties -

    /// Name that shall be converted to initials.
    let name: String

    /// Square dimensions of the view
    let dimension: CGFloat

    // MARK: - Private properties -

    private var compressedInitials: String {
        name.split(separator: " ")
            .compactMap(\.first)
            .map { "\($0)" }
            .joined(separator: "")
    }

    private let randomizeabledBackgroundColors = [
        Color.blue, Color.red, Color.green, Color.orange,
    ]

    // MARK: - UI -

    var body: some View {
        Text(compressedInitials)
            .opacity(0.75)
            .font(.system(size: dimension))
            .minimumScaleFactor(0.01)
            .padding()
            .frame(width: dimension, height: dimension)
            .background(randomizeabledBackgroundColors.randomElement())
    }
}

// MARK: - Preview -

#Preview {
    InitialAvatarView(name: "Raspberry Pis", dimension: 256)
}
