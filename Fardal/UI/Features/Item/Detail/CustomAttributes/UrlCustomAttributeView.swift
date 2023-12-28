//
//  UrlCustomAttributeView.swift
//  Fardal
//
//  Created by Tobias Scholze on 13.12.23.
//

import SwiftUI

/// Represents a custom item attribute which contains
/// an `URL` value.
struct UrlCustomAttributeView: View {
    // MARK: - Properties -

    /// View mode for the view
    let mode: ViewMode

    /// Underlying data source
    let store: UrlCustomAttributeStore

    // MARK: - States -

    @State private var title: String = ""
    @State private var rawUrl: String = ""

    // MARK: - UI -

    var body: some View {
        if mode == .read {
            VStack(alignment: .leading) {
                // Title
                Text(store.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // URL
                if let url = store.url {
                    HStack(alignment: .center, spacing: Theme.Spacing.tiny) {
                        Link(url.host() ?? "", destination: url)

                        FavIconAsyncImage(
                            url: store.url,
                            placeholder: { EmptyView() }
                        )
                    }
                }
                else {
                    Text("Misc.NoContent.Indicator").foregroundStyle(.secondary)
                }
            }
        }
        else {
            VStack(spacing: Theme.Spacing.none) {
                // Title
                TextField("Item.Detail.Attribute.Url.Title.Placeholder", text: $title)
                    .font(.caption)
                    .onChange(
                        of: title,
                        onTitleChanged(oldValue:newValue:)
                    )

                HStack {
                    TextField("Item.Detail.Attribute.Url.Value.Placeholder", text: $rawUrl)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(
                            of: rawUrl,
                            onRawUrlChanged(oldValue:newValue:)
                        )

                    FavIconAsyncImage(
                        url: store.url,
                        placeholder: { EmptyView() }
                    )
                }
            }
            .onAppear {
                title = store.title
                rawUrl = store.url?.absoluteString ?? ""
            }
        }
    }
}

// MARK: - Events -

extension UrlCustomAttributeView {
    private func onTitleChanged(oldValue _: String, newValue: String) {
        store.title = newValue
    }

    private func onRawUrlChanged(oldValue _: String, newValue: String) {
        guard let url = URL(string: newValue) else { return }
        store.url = url
    }
}

// MARK: - Store -

class UrlCustomAttributeStore {
    // MARK: - Properties -

    /// Raw data source of the attribute
    private(set) var attribute: ItemCustomAttribute

    /// Title of the price attribute.
    /// E.g. "Bought at".
    var title: String {
        didSet { attribute.payload["title"] = title }
    }

    /// Target url
    var url: URL? {
        didSet { attribute.payload["url"] = url?.absoluteString }
    }

    // MARK: - Init -

    /// Creates a new store that shall be used in `UrlCustomAttributeView`.
    ///
    /// - Parameter attribute: Database model of the attribute
    init(attribute: ItemCustomAttribute) {
        guard attribute.layout == ItemCustomAttributeType.url.rawValue else {
            fatalError("Invalid layout for attribute.")
        }

        // Validate payload
        guard let title = attribute.payload["title"],
              let rawUrl = attribute.payload["url"] else {
            fatalError("Invalid payload: \(attribute.payload)")
        }

        // Set properties
        self.attribute = attribute
        self.title = title
        url = URL(string: rawUrl)
    }
}

// MARK: - Preview -

#Preview {
    UrlCustomAttributeView(mode: .create, store: .init(attribute: .mockedLinkAttribute))
}
