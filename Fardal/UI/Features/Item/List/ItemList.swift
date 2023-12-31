//
//  ItemList.swift
//  Fardal
//
//  Created by Tobias Scholze on 14.12.23.
//

import SwiftUI
import SwiftData

/// Renders a list of stored items
/// in context of a tab item "list".
struct ItemListView: View {
    // MARK: - Properties -

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemModel]

    // MARK: - UI -

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(initialState: .read(item))
                    } label: {
                        Text(item.title)
                    }
                }
                .onDelete(perform: onDeleteItems)
            }
            .navigationTitle("Item.List.Title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    NavigationLink("Item.List.Action.Add") {
                        ItemDetailView(initialState: .create)
                    }
                }
            }
        } detail: {
            Text("Item.List.Detail.Empty")
        }
        .tabItem {
            Image(systemName: "list.bullet.rectangle")
            Text("Item.List.Title")
        }
        .navigationSplitViewStyle(.automatic)
    }
}

// MARK: - Actions -

extension ItemListView {
    private func onDeleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    ItemListView()
        .modelContainer(for: ItemModel.self, inMemory: true)
}
