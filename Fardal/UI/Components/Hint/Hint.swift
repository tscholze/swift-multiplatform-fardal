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

    /// Size
    /// Default value: .medium
    var size: HintSize = .medium

    /// Style
    /// Default value: .default
    var style: HintStyle = .default

    // MARK: - Body -

    var body: some View {
        VStack(alignment: .center, spacing: Theme.Spacing.medium) {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size.height * 0.4)

            Text(titleKey)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: false)
        }
        .foregroundStyle(style.foregroundStyle)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: size.height)
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
enum HintSize {
    /// Medium
    case medium

    /// Large
    case large

    // MARK: - Computed properties -

    /// Height
    var height: CGFloat {
        switch self {
        case .medium: 60
        case .large: 80
        }
    }
}
