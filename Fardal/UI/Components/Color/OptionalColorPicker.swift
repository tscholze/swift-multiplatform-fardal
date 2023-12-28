//
//  OptionalColorPicker.swift
//  Fardal
//
//  Created by Tobias Scholze on 27.12.23.
//

import Flow
import SwiftUI

/// A color picker that provides a circle based selection with the
/// possibility to set it to nil.
///
/// Listen to `selectedColor` to be informed which color
/// the user has ben selected.
struct OptionalColorPicker: View {
    // MARK: - Properties -

    /// User selected color
    @Binding var selectedColor: Color?

    /// Colors that are selectable
    let selectableColors: [Color]

    /// Circle dimension
    /// Default value: 24
    var circleDimension: CGFloat = 24

    // MARK: - Private properties -

    @State var __selectedColor: Color? = nil

    // MARK: - Private properties -

    @State private var __selectableColors = [SelectableColor]()

    // MARK: - UI -

    var body: some View {
        HFlow {
            // Empty value
            Button(action: { __selectedColor = nil }) {
                Image(systemName: "circle.slash")
                    .resizable()
                    .foregroundStyle(__selectedColor == nil ? .black : .secondary)
                    .frame(width: circleDimension, height: circleDimension)
                    .padding(4)
            }

            // Color values
            ForEach(__selectableColors) { item in
                Button(action: { __selectedColor = item.color }) {
                    Group {
                        if __selectedColor == item.color {
                            Image(systemName: "circle.circle.fill")
                                .resizable()
                                .foregroundStyle(item.color)
                                .frame(width: circleDimension, height: circleDimension)
                        }
                        else {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .foregroundStyle(item.color)
                                .frame(width: circleDimension, height: circleDimension)
                        }
                    }
                    .padding(4)
                }
            }
        }
        .buttonStyle(.borderless)
        .onChange(of: __selectedColor) { _, _ in
            selectedColor = __selectedColor
        }
        .onAppear {
            __selectableColors = selectableColors
                .map { .init(color: $0) }

            __selectedColor = selectedColor
        }
    }
}

// MARK: - Preview -

#Preview {
    @State var selectedColor: Color?

    return HStack {
        OptionalColorPicker(selectedColor: $selectedColor, selectableColors: Theme.Colors.pastelColors)
    }
}
