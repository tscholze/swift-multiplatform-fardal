//
//  ItemListItem.swift
//  Fardal
//
//  Created by Tobias Scholze on 28.12.23.
//

import SwiftUI

struct ItemNavigationLink: View {
    // MARK: - Properties -
    
    /// Item that shall be rendered.
    let item: ItemModel
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(initialState: .read(item))) {
            VStack(alignment: .leading) {
                Text(item.title)
                Text(item.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    ItemListItem(
        item: .init(
            title: "My title",
            summary: "and my awesome summary!"
        )
    )
}
