//
//  CollectionDetailLinkItemView.swift
//  Fardal
//
//  Created by Tobias Scholze on 23.12.23.
//

import SwiftUI
import SwiftData

struct CollectionDetailLinkItemView: View {
    
    // MARK: - Properties -
    
    @Binding var selectedItems: [ItemModel]
    
    // MARK: - Private Properties -
    
    @Query(
        filter: #Predicate<ItemModel> { $0.collection == nil },
        sort: \.title
    ) private var items: [ItemModel]
    
    @State private var __selectedItems = [ItemModel]()
    
    // MARK: - UI -
    
    var body: some View {
        NavigationView {
            ForEach(items) { item in
                HStack {
                    Text(item.title)
                    if __selectedItems.contains(item) {
                        Button(action: { onUnlinkItemTapped(item) }) {
                            Image(systemName: "x.circle")
                        }
                    } else {
                        Button(action: { onLinkItemTapped(item) }) {
                            Image(systemName: "link")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save", action: onSaveButtonTapped)
                }
            }
        }
    }
}

// MARK: - Actions -

extension CollectionDetailLinkItemView {
    private func onUnlinkItemTapped(_ item: ItemModel) {
        __selectedItems.removeAll(where: { $0.id == item.id })
    }
    
    private func onLinkItemTapped(_ item: ItemModel) {
        __selectedItems.append(item)
    }
    
    private func onSaveButtonTapped() {
        selectedItems = __selectedItems
    }
}

// MARK: - Preview -

#Preview {
    @State var selectedItems = [ItemModel]()
    return CollectionDetailLinkItemView(selectedItems: $selectedItems)
}
