//
//  LabelStyles.swift
//  Fardal
//
//  Created by Tobias Scholze on 24.12.23.
//

import SwiftUI
import Foundation

/// Horizontal label style
///
/// Caution: Do not use for any large hint. Use instead Hint(titleKey:systemImage)
struct HorizonalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: Theme.Spacing.tiny) {
            configuration.icon

            configuration.title
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
        .padding(8)
        .foregroundStyle(.secondary.opacity(0.6))
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
