//
//  NoteCustomAttributeView.swift
//  Fardal
//
//  Created by Tobias Scholze on 21.12.23.
//

import SwiftUI

/// Represents a custom item attribute which contains
/// a multiline note text.
struct NoteCustomAttributeView: View {
    // MARK: - Properties -

    /// View mode for the view
    let mode: ViewMode

    /// Underlying data source
    let store: NoteCustomAttributeStore

    // MARK: - States -

    @State private var title: String = ""
    @State private var text: String = ""
    @State private var isValid = true

    // MARK: - UI -

    var body: some View {
        if mode == .read {
            VStack(alignment: .leading) {
                // Title
                Text(store.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Note
                if store.text.isEmpty {
                    HStack(alignment: .center, spacing: Theme.Spacing.tiny) { Text("Misc.EmptyValue").foregroundStyle(.secondary)
                    }
                }
                else {
                    Text(store.text)
                        .multilineTextAlignment(.leading)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        else {
            VStack(spacing: Theme.Spacing.none) {
                // Title
                TextField(
                    "Item.Detail.Attribute.Note.Title.Placeholder",
                    text: $title
                )
                .font(.caption)
                .onChange(
                    of: title,
                    onTitleChanged(oldValue:newValue:)
                )

                // Input
                TextEditor(text: $text)
                    .foregroundStyle(isValid ? .primary : Color.red)
                    .onChange(
                        of: text,
                        onNoteChanged(oldValue:newValue:)
                    )

                // Validation info
                HStack {
                    Spacer()

                    Text("Item.Detail.Attribute.Note.Validation.Format \(text.count) / \(FardalConstants.Item.maxLengthOfNoteText)")
                        .font(.caption2)
                        .foregroundStyle(.secondary.opacity(0.6))
                }
            }
            .onAppear {
                title = store.title
                text = store.text
            }
        }
    }
}

// MARK: - Events -

extension NoteCustomAttributeView {
    private func onTitleChanged(oldValue _: String, newValue: String) {
        store.title = newValue
    }

    private func onNoteChanged(oldValue _: String, newValue: String) {
        if newValue.count <= FardalConstants.Item.maxLengthOfNoteText {
            isValid = true
            store.text = newValue
        }
        else {
            isValid = false
            store.text = "\(newValue.prefix(FardalConstants.Item.maxLengthOfNoteText))"
        }
    }
}

// MARK: - Store -

class NoteCustomAttributeStore {
    // MARK: - Properties -

    /// Raw data source of the attribute
    private(set) var attribute: ItemCustomAttribute

    /// Title of the price attribute.
    /// E.g. "Keep in mind".
    var title: String {
        didSet { attribute.payload["title"] = title }
    }

    /// Target url
    var text: String {
        didSet { attribute.payload["text"] = text }
    }

    // MARK: - Init -

    init(attribute: ItemCustomAttribute) {
        // Validate payload
        guard let title = attribute.payload["title"],
              let text = attribute.payload["text"] else {
            fatalError("Invalid payload: \(attribute.payload)")
        }

        // Set properties
        self.attribute = attribute
        self.title = title
        self.text = text
    }
}

// MARK: - Preview -

#Preview {
    NoteCustomAttributeView(
        mode: .edit,
        store: .init(attribute: .mockedNoteAttribute)
    )
}
