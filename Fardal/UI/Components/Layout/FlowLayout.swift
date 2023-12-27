//
//  FlowLayout.swift
//  Fardal
//
//  Created by Tobias Scholze on 27.12.23.
//

import SwiftUI
import Foundation

/// Custom layout to place as much of it's children as possible
/// in a row
///
/// Inspired by:
///     - https://www.youtube.com/watch?v=FzL11vRhzs8
struct FlowRowLayout: Layout {
    // MARK: - Properties -

    /// Vertical and horizontal spacing
    /// Default value Theme.Spacing.tiny.
    var spacing: CGFloat = Theme.Spacing.tiny

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
