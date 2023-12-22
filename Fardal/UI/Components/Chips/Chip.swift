//
//  Chip.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import SwiftUI

/// Represents a deleteable Chip (Tag).
/// Mostly used in combination with `ChipsView`.
struct Chip: View {
    // MARK: - Properties -

    /// Model data source
    let model: ChipModel

    /// Binding to set the chip's view mode
    @Binding var viewMode: ViewMode

    /// On delete trigger
    let onDelete: () -> Void

    // MARK: - UI -

    var body: some View {
        Group {
            if viewMode == .read {
                Text(model.title)
                    .applyChipStyle()
            }
            else {
                Button(action: onDelete) {
                    // Label(model.title, systemImage: "xmark")
                    HStack {
                        Text(model.title)
                        Image(systemName: "xmark")
                    }
                    .applyChipStyle()
                }
                .tint(.primary)
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    @State var viewMode = ViewMode.read
    return Chip(model: .init(title: "Mocked"), viewMode: $viewMode, onDelete: {})
}

// MARK: - Styling -

extension View {
    fileprivate func applyChipStyle() -> some View {
        font(.caption)
            .foregroundStyle(.primary)
            .padding(6)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(.tertiary.opacity(0.6))
            }
    }
}
