//
//  ProfileAvatar.swift
//  Fardal
//
//  Created by Tobias Scholze on 29.12.23.
//

import SwiftUI

/// Renders the user's profile in a circlular shape
/// with a banner attached if the user  has bought a IAP.
struct ProfileAvatar: View {
    // MARK: - Properties -

    /// Defines the represented style of the component.
    let style: ProfileAvatarStyle

    // MARK: - UI -

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(Color.pastelGreen.opacity(0.8))
                .overlay {
                    Circle()
                        .stroke(.pastelGreenDark, lineWidth: style.borderWidth)
                }
                .aspectRatio(1, contentMode: .fit)

            Image(.mockUserAvatar)
                .resizable()
                .scaledToFit()

            if style.showTierBanner {
                Spacer()
                    .frame(height: style.photoOffsetTop)

                Text("Profile.Tier.Mock")
                    .font(style.font)
                    .fontWeight(style.fontWeight)
                    .lineLimit(1)
                    .foregroundStyle(.black)
                    .minimumScaleFactor(0.1)
                    .padding(style.fontPadding)
                    .background(Color.pastelYellow)
                    .overlay {
                        Theme.Shape.roundedRectangle2
                            .stroke(.pastelYellowDark, lineWidth: style.borderWidth)
                    }
            }
        }
        .frame(width: style.dimension, height: style.dimension)
        .padding()
    }
}

// MARK: - ProfileAvatarStyle -

/// Determines available styles for component
enum ProfileAvatarStyle {
    // MARK: - Cases -

    /// Used as a button content
    case button

    /// Used as a large scaled image
    case header

    // MARK: - Computed properties -

    /// Gets the dimension of the style
    fileprivate var dimension: CGFloat {
        switch self {
        case .button: 40
        case .header: 100
        }
    }

    /// Gets the borderwidth of the style
    fileprivate var borderWidth: CGFloat {
        switch self {
        case .button: 1
        case .header: 2
        }
    }

    /// Gets the off-center spacer of the avatar image
    fileprivate var photoOffsetTop: CGFloat {
        switch self {
        case .button: 1
        case .header: 10
        }
    }

    /// Determines if the tier banner should be shown
    fileprivate var showTierBanner: Bool {
        switch self {
        case .button: true
        case .header: true
        }
    }

    /// Gets the font weight of the tier banner
    fileprivate var fontWeight: Font.Weight {
        switch self {
        case .button: Font.Weight.regular
        case .header: Font.Weight.bold
        }
    }

    /// Gets the font  of the tier banner
    fileprivate var font: Font {
        switch self {
        case .button: Font.caption2
        case .header: Font.body
        }
    }

    /// Gets the text padding of the tier banner
    fileprivate var fontPadding: CGFloat {
        switch self {
        case .button: 2
        case .header: 4
        }
    }
}

// MARK: - Preview -

#Preview {
    ProfileAvatar(style: .header)
}
