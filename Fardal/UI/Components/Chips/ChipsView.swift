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

    // MARK: - Private properties -

    @State private var newTagText = ""
    @State private var isValid = false

    // MARK: - UI -

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if chips.isEmpty {
                    Text("No tags assigned")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                else {
                    FlowRowLayout {
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
                        TextField("Chips.NewTag.Placeholder", text: $newTagText)
                            .font(.caption)
                            .onChange(of: newTagText, onNewTagTextChanged(oldValue:newValue:))
                            .onSubmit { onSaveButtonTapped() }

                        Button(action: { onSaveButtonTapped() }) {
                            Image(systemName: "checkmark")
                        }.disabled(isValid == false)
                    }
                }
            }
            .frame(maxWidth: .infinity)
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
        guard isValid else { return }
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
    // @State var chips: [ChipModel] = [.init(title: "Chip #1"), .init(title: "Chip #2"), .init(title: "Chip #3"), .init(title: "Chip #4"), .init(title: "Chip #5"), .init(title: "Chip #6")]
    @State var chips: [ChipModel] = []

    return ChipsView(chips: $chips, viewMode: $viewMode).padding()
}
