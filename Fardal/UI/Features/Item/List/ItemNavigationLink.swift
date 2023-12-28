//
//  ItemListItem.swift
//  Fardal
//
//  Created by Tobias Scholze on 28.12.23.
//

import SwiftUI

/// A `NavigationLink` that renderes its label with
/// human-identifeable `Item` information.
struct ItemNavigationLink: View {
    // MARK: - Properties -
    
    /// Item that shall be rendered.
    let item: ItemModel
    
    // MARK: - UI -
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(initialState: .read(item))) {
            HStack(spacing: Theme.Spacing.medium) {
                if let image = item.imagesData?.first?.image {
                    image.resizable()
                        .frame(width: 36, height: 36)
                }
                
                VStack(alignment: .leading) {
                    Text(item.title)
                    Text(item.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
        }
    }
}

// MARK: - Preview -

#Preview {
    ItemNavigationLink(
        item: .init(
            title: "My title",
            summary: "and my awesome summary!"
        )
    )
}
