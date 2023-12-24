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

    // MARK: - UI -

    var body: some View {
        Text(compressedInitials)
            .opacity(0.4)
            .font(.system(size: dimension))
            .minimumScaleFactor(0.01)
            .padding()
            .frame(width: dimension, height: dimension)
            .opacity(1)
            .background(Theme.Colors.pastelColors.randomElement())
    }
}

// MARK: - Preview -

#Preview {
    InitialAvatarView(name: "Raspberry Pis", dimension: 256)
}
