//
//  ProfileAvatar.swift
//  Fardal
//
//  Created by Tobias Scholze on 29.12.23.
//

import SwiftUI

struct ProfileAvatar: View {
    // MARK: - Properties -

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

                    Text("Premium")
                        .font(style.font)
                        .fontWeight(style.fontWeight)
                        .lineLimit(1)
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.1)
                        .padding(style.fontPadding)
                        .background(Color.pastelYellow)
                        .overlay {
                            Theme.Shape.roundedRectangle2
                                .stroke(.pastelGreenDark, lineWidth: style.borderWidth)
                        }
                }
        }
        .frame(width: style.dimension, height: style.dimension)
        .padding()
    }
}

enum ProfileAvatarStyle {
    case button
    case header

    var dimension: CGFloat {
        switch self {
        case .button: 50
        case .header: 100
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .button: 1
        case .header: 4
        }
    }

    var photoOffsetTop: CGFloat {
        switch self {
        case .button: 2
        case .header: 10
        }
    }

    var showTierBanner: Bool {
        switch self {
        case .button: true
        case .header: true
        }
    }
    
    
    var fontWeight: Font.Weight {
        switch self {
        case .button: Font.Weight.regular
        case .header: Font.Weight.bold
        }
    }
    
    var font: Font {
        switch self {
        case .button: Font.caption2
        case .header: Font.body
        }
    }
    
    var fontPadding: CGFloat {
        switch self {
        case .button: 2
        case .header: 4
        }
    }
}

#Preview {
    ProfileAvatar(style: .button)
}
