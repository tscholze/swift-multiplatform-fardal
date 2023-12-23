//
//  ItemDetailLinkCollectionView.swift
//  Fardal
//
//  Created by Tobias Scholze on 23.12.23.
//

import SwiftUI
import SwiftData

struct ItemDetailLinkCollectionView: View {
    // MARK: - Properties -

    @Binding var selectedCollection: CollectionModel?

    // MARK: - Private Properties -

    @Query private var collections: [CollectionModel]
    @State private var __selectedCollection: CollectionModel?
    @State private var searchQuery = ""
    @Environment(\.dismiss) var dismiss

    // MARK: - UI -

    var body: some View {
        NavigationView {
            List(collections) { collection in
                HStack {
                    // Title
                    Text(collection.title)

                    Spacer()

                    // Action
                    Button(action: { onSetCollectionTapped(collection: collection) }) {
                        if __selectedCollection == collection {
                            Image(systemName: "checkmark")
                        }
                        else {
                            EmptyView()
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
            .navigationTitle("ItemLinkCollection.Title")
        }
    }
}

// MARK: - Actions -

extension ItemDetailLinkCollectionView {
    private func onSetCollectionTapped(collection: CollectionModel) {
        if collection == __selectedCollection {
            __selectedCollection = nil
        }
        else {
            __selectedCollection = collection
        }
    }

    private func onSaveButtonTapped() {
        selectedCollection = __selectedCollection
        dismiss()
    }
}

// MARK: - Preview -

#Preview {
    @State var selectedCollection: CollectionModel?
    return ItemDetailLinkCollectionView(selectedCollection: $selectedCollection)
}
