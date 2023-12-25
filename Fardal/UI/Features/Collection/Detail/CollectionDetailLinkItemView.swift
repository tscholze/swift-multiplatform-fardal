//
//  CollectionDetailLinkItemView.swift
//  Fardal
//
//  Created by Tobias Scholze on 23.12.23.
//

import SwiftUI
import SwiftData

/// Provides the possibility to the user to link or unlink the list of
/// attached `Item` models.
///
/// Listen to `selectedItems` for changes.
struct CollectionDetailLinkItemView: View {
    // MARK: - Properties -

    /// User-selected items of the collection
    @Binding var selectedItems: [ItemModel]

    // MARK: - Private Properties -

    @Query(filter: #Predicate<ItemModel> { $0.collection == nil }, sort: \.title)
    private var items: [ItemModel]

    @State private var __selectedItems = [ItemModel]()
    @State private var searchQuery = ""
    @Environment(\.dismiss) var dismiss

    // MARK: - UI -

    var body: some View {
        NavigationView {
            List(items) { item in
                HStack {
                    // Title
                    Text(item.title)

                    Spacer()

                    // Actions
                    if __selectedItems.contains(item) {
                        Button(action: { onUnlinkItemTapped(item) }) {
                            Image(systemName: "xmark")
                        }
                    }
                    else {
                        Button(action: { onLinkItemTapped(item) }) {
                            Image(systemName: "link")
                        }
                    }
                }
            }
            .searchable(text: $searchQuery)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Misc.Cancel", action: { dismiss() })
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Misc.Save", action: onSaveButtonTapped)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("CollectionDetailLinkItem.Title")
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
