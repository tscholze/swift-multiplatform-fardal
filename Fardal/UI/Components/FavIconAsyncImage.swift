//
//  FavIconAsyncImage.swift
//  Fardal
//
//  Created by Tobias Scholze on 13.12.23.
//

import SwiftUI

struct FavIconAsyncImage<Content>: View where Content: View {
    
    let url: URL?
    let placeholder: () -> Content
    
    var body: some View {
        AsyncImage(url: url?.appending(path: "/favicon.ico")) { image in
            image.resizable()
        } placeholder: {
            placeholder()
        }
        .frame(width: 16, height: 16)
    }
}

#Preview {
    FavIconAsyncImage(
        url: URL(string: "https://www.apple.de"),
        placeholder: { EmptyView() }
    )
}
