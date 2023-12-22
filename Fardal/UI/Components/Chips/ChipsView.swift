//
//  ChipsView.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import SwiftUI

/// Renderes a list of `Chip` views in which each row
/// of chips is as wide as possbile.
struct ChipsView: View {
    // MARK: - Properties -

    /// List of chips that shall be rendered.
    @Binding var chips: [ChipModel]

    /// Binding to set the chip's view mode
    @Binding var viewMode: ViewMode

    @State private var newTagText = ""
    @State private var isValid = false

    // MARK: - UI -

    var body: some View {
        ScrollView {
            VStack {
                ChipsViewLayout {
                    ForEach(chips) { chip in
                        Chip(
                            model: chip,
                            viewMode: $viewMode,
                            onDelete: { onDeleteRequested(model: chip) }
                        )
                    }
                }
            }

            if viewMode != .read {
                HStack {
                    TextField("Add new tag", text: $newTagText)
                        .font(.caption)
                        .onChange(of: newTagText, onNewTagTextChanged(oldValue:newValue:))

                    Button(action: { onSaveButtonTapped() }) {
                        Image(systemName: "checkmark")
                    }.disabled(isValid == false)
                }
            }
        }
    }
}

// MARK: - Actions -

extension ChipsView {
    private func onNewTagTextChanged(oldValue _: String, newValue: String) {
        if newTagText.isEmpty || chips.map(\.title).contains(newValue) {
            isValid = false
        }
        else {
            isValid = true
        }
    }

    private func onSaveButtonTapped() {
        chips.append(.init(title: newTagText))
        newTagText = ""
    }

    private func onDeleteRequested(model: ChipModel) {
        withAnimation {
            chips.removeAll(where: { $0.title == model.title })
        }
    }
}

// MARK: - Preview -

#Preview {
    @State var viewMode = ViewMode.read
    @State var chips: [ChipModel] = [.init(title: "Chip #1"), .init(title: "Chip #2"), .init(title: "Chip #3"), .init(title: "Chip #4"), .init(title: "Chip #5"), .init(title: "Chip #6")]

    return ChipsView(chips: $chips, viewMode: $viewMode)
}

// MARK: - Layout -

/// Custom layout to place `Chip` items in the `ChipView`.
///
/// Inspired by:
///     - https://www.youtube.com/watch?v=FzL11vRhzs8
private struct ChipsViewLayout: Layout {
    // MARK: - Properties -

    /// Vertical and horizontal spacing
    /// Default value 8.
    var spacing: CGFloat = 8

    // MARK: - Layout implementation -

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = makeRows(maxWidth: maxWidth, in: proposal, with: subviews)
        var height: CGFloat = 0

        for (index, row) in rows.enumerated() {
            height += row.maxHeight(in: proposal)

            if index != rows.count - 1 {
                height += spacing
            }
        }

        return .init(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var origin = bounds.origin
        let rows = makeRows(maxWidth: bounds.width, in: proposal, with: subviews)

        for row in rows {
            origin.x = 0

            for subview in row {
                let viewSize = subview.sizeThatFits(proposal)
                subview.place(at: origin, proposal: proposal)
                origin.x += viewSize.width + spacing
            }

            origin.y += row.maxHeight(in: proposal) + spacing
        }
    }

    // MARK: - Helper -

    private func makeRows(
        maxWidth: CGFloat,
        in proposal: ProposedViewSize,
        with subviews: Subviews
    )
        -> [[LayoutSubview]] {
        var row = [LayoutSubviews.Element]()
        var rows = [[LayoutSubviews.Element]]()
        var origin = CGRect.zero.origin

        // Iterate over all subviws and split it into rows
        // that fits into the max width.
        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            let fitsInRow = (origin.x + size.width + spacing) <= maxWidth

            if fitsInRow {
                row.append(subview)
                origin.x += size.width + spacing
            }
            else {
                rows.append(row)
                row = [subview]
                origin.x = 0
            }
        }

        // Check if there is a not fully filled row at the end.
        // Append it anyway
        if row.isEmpty == false {
            rows.append(row)
            row.removeAll()
        }

        return rows
    }
}

// MARK: - Fileprivate extensions

extension [LayoutSubviews.Element] {
    fileprivate func maxHeight(in proposal: ProposedViewSize) -> CGFloat {
        self.compactMap { $0.sizeThatFits(proposal).height }
            .max() ?? 0
    }
}
