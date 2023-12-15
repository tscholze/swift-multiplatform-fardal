//
//  FavIconAsyncImage.swift
//  Fardal
//
//  Created by Tobias Scholze on 13.12.23.
//

import SwiftUI

/// Renders a remotley requested fav icon image with given modifiers.
struct FavIconAsyncImage<Content>: View where Content: View {
    // MARK: - Properties -

    /// Base url of the domain that shall be checked.
    /// It must be the root like https://apple.com
    private let url: URL?

    /// Size of the rendered image.
    /// Keep in mind that fav icons are relativley small
    ///
    /// Default value: 16, 16
    private let size: CGSize

    /// Optional Placeholder that will de shown if
    /// the fav icon is requested or not available.
    ///
    /// Default: `EmptyView()`
    private let placeholder: () -> Content

    // MARK: - Init -

    /// Initializes a new `FavIconAsyncImage`.
    ///
    /// - Parameters:
    ///   - url: Base url of the domain that shall be checked.  It must be the root like https://apple.com.
    ///   - size: Size of the rendered image. Default value: 16,16
    ///   - placeholder: Optional Placeholder that will de shown if the fav icon is requested or not available.
    init(
        url: URL?,
        size: CGSize = .init(width: 16, height: 16),
        placeholder: @escaping () -> Content = { EmptyView() }
    ) {
        self.url = url?.appending(path: "/favicon.ico")
        self.size = size
        self.placeholder = placeholder
    }

    // MARK: - UI -

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable()
        } placeholder: {
            placeholder()
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Preview -

#Preview {
    FavIconAsyncImage(
        url: URL(string: "https://www.apple.de"),
        placeholder: { EmptyView() }
    )
}
