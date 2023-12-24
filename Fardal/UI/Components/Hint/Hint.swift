//
//  Hint.swift
//  Fardal
//
//  Created by Tobias Scholze on 24.12.23.
//

import SwiftUI

/// Shows a vertical hin with an icon and a text.
struct Hint: View {
    // MARK: - Properties -

    /// Title key
    let titleKey: LocalizedStringKey

    /// System image name
    let systemName: String

    /// Dimension
    /// Default value: .medium
    var dimension: HintDimension = .medium

    /// Style
    /// Default value: .default
    var style: HintStyle = .default

    // MARK: - Body -

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()

            Text(titleKey)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .foregroundStyle(style.foregroundStyle)
        .frame(maxWidth: .infinity)
        .frame(height: dimension.height)
    }
}

// MARK: - Preview -

#Preview {
    Hint(titleKey: "Amazing hint", systemName: "questionmark")
}

/// Available styles  of a `Hint`
enum HintStyle {
    /// Default styling
    case `default`

    var foregroundStyle: Color {
        switch self {
        case .default: Color.secondary.opacity(0.6)
        }
    }
}

/// Available dimensions of a `Hint`
enum HintDimension {
    /// Medium
    case medium

    var height: CGFloat {
        switch self {
        case .medium: 60
        }
    }
}
